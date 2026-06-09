const randomstring = require("randomstring");
const twilio = require("twilio");
const { query } = require("../../database/dbpromise");
const { getDeviceId } = require("../../helper/function");

// Simple in-memory queue per device (to ensure one call at a time per device)
const deviceQueues = {}; // { device_id: [{ contact_mobile, campaign_id, uid }] }
const processingDevices = new Set(); // Devices currently processing a call

// Function to queue and process calls for a campaign
async function processCampaign(campaign) {
  const { campaign_id, device_id, uid } = campaign;

  try {
    // Get contacts from phonebook
    const contacts = await query(
      "SELECT mobile FROM contact WHERE uid = ? AND phonebook_id = ?",
      [uid, campaign.phonebook_id]
    );

    if (contacts.length === 0) {
      await query(
        "UPDATE beta_campaign SET status = ?, completed_contacts = ?, total_contacts = ? WHERE campaign_id = ?",
        ["COMPLETED", 0, 0, campaign_id]
      );
      return;
    }

    // Update total_contacts first
    await query(
      "UPDATE beta_campaign SET total_contacts = ? WHERE campaign_id = ?",
      [contacts.length, campaign_id]
    );

    // Queue all contacts for this device
    if (!deviceQueues[device_id]) deviceQueues[device_id] = [];

    contacts.forEach((contact) => {
      deviceQueues[device_id].push({
        contact_mobile: contact.mobile,
        campaign_id,
        uid,
      });
    });

    // console.log(
    //   `Queued ${contacts.length} contacts for device ${device_id}, campaign ${campaign_id}`
    // );

    // Start processing if not already
    processDeviceQueue(device_id);
  } catch (error) {
    console.error(`Error processing campaign ${campaign_id}:`, error);
    await query("UPDATE beta_campaign SET status = ? WHERE campaign_id = ?", [
      "FAILED",
      campaign_id,
    ]);
  }
}

// Process queue for a specific device (one call at a time with proper delays)
async function processDeviceQueue(device_id) {
  if (processingDevices.has(device_id)) {
    // console.log(`Device ${device_id} is already being processed`);
    return;
  }

  if (!deviceQueues[device_id] || deviceQueues[device_id].length === 0) {
    // console.log(`No queue items for device ${device_id}`);
    return;
  }

  processingDevices.add(device_id);
  // console.log(
  //   `Starting to process queue for device ${device_id}, ${deviceQueues[device_id].length} items remaining`
  // );

  while (deviceQueues[device_id] && deviceQueues[device_id].length > 0) {
    const queueItem = deviceQueues[device_id].shift();
    const { contact_mobile, campaign_id, uid } = queueItem;

    // console.log(
    //   `Processing call to ${contact_mobile} for campaign ${campaign_id}`
    // );

    let callSid = null;
    try {
      // Get device details
      const device = await getDeviceId(device_id);
      const voiceAgent = device?.voice_agent;

      if (!device?.sid || !device?.token || !voiceAgent?.active) {
        throw new Error("Invalid device or no active voice agent");
      }

      const accountSid = device.sid;
      const authToken = device.token;
      const client = new twilio(accountSid, authToken);

      // Initiate Twilio call with proper error handling
      const call = await client.calls.create({
        to: contact_mobile,
        from: device.number,
        url: `${process.env.BACKURI}/api/vagent/outgoing-connect/${device_id}`,
        statusCallback: `${process.env.BACKURI}/api/vagent_route/call-status-callback`,
        statusCallbackEvent: ["initiated", "ringing", "answered", "completed"],
        statusCallbackMethod: "POST",
        timeout: 30, // 30 second timeout
        record: false, // Set to true if you want recordings
      });

      callSid = call.sid;
      // console.log(
      //   `Call initiated successfully: ${callSid} to ${contact_mobile}`
      // );

      // Log the call initiation
      await query(
        "INSERT INTO beta_campaign_log (uid, campaign_id, contact_mobile, twilio_sid, status) VALUES (?, ?, ?, ?, ?)",
        [uid, campaign_id, contact_mobile, call.sid, "INITIATED"]
      );
    } catch (err) {
      console.error(`Error calling ${contact_mobile}:`, err.message);

      // Log error
      await query(
        "INSERT INTO beta_campaign_log (uid, campaign_id, contact_mobile, status, error) VALUES (?, ?, ?, ?, ?)",
        [uid, campaign_id, contact_mobile, "FAILED", err.message]
      );
    }

    // Increment completed_contacts (counts success OR failure as processed)
    try {
      await query(
        "UPDATE beta_campaign SET completed_contacts = completed_contacts + 1 WHERE campaign_id = ?",
        [campaign_id]
      );

      // Check if this campaign is now complete
      const [campaign] = await query(
        "SELECT completed_contacts, total_contacts FROM beta_campaign WHERE campaign_id = ?",
        [campaign_id]
      );

      if (campaign && campaign.completed_contacts >= campaign.total_contacts) {
        await query(
          "UPDATE beta_campaign SET status = ? WHERE campaign_id = ?",
          ["COMPLETED", campaign_id]
        );
        // console.log(`Campaign ${campaign_id} completed`);
      }
    } catch (updateError) {
      console.error(`Error updating campaign progress:`, updateError);
    }

    // CRITICAL: Wait between calls to respect Twilio rate limits
    // Twilio allows 1 call per second per account
    // console.log(`Waiting 2 seconds before next call...`);
    await new Promise((resolve) => setTimeout(resolve, 2000)); // 2 second delay between calls
  }

  processingDevices.delete(device_id);
  // console.log(`Finished processing queue for device ${device_id}`);
}

// Background worker to check for new campaigns every 30 seconds
function startCampaignWorker() {
  // console.log("Starting campaign worker...");

  setInterval(async () => {
    try {
      const pendingCampaigns = await query(
        "SELECT * FROM beta_campaign WHERE status = ?",
        ["PENDING"]
      );

      if (pendingCampaigns.length > 0) {
        // console.log(`Found ${pendingCampaigns.length} pending campaigns`);
      }

      for (const campaign of pendingCampaigns) {
        // console.log(`Starting campaign ${campaign.campaign_id}`);

        // Mark as running first
        await query(
          "UPDATE beta_campaign SET status = 'RUNNING' WHERE campaign_id = ?",
          [campaign.campaign_id]
        );

        // Process the campaign
        processCampaign(campaign);
      }
    } catch (error) {
      console.error("Error in campaign worker:", error);
    }
  }, 10000); // Check every 30 seconds instead of 10
}

module.exports = { startCampaignWorker, processDeviceQueue };
