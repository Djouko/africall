const router = require("express").Router();
const { query } = require("../database/dbpromise.js");
const validateUser = require("../middlewares/user.js");
const { ElevenLabs } = require("elevenlabs");
const { getVoicesWithSDK } = require("../helper/function.js");
const randomstring = require("randomstring");
const twilio = require("twilio");
const axios = require("axios");

// get elevenlabs voice id
router.post("/get_voice_el", async (req, res) => {
  try {
    const { apiKeys } = req.body;
    if (!apiKeys) {
      return res.json({ msg: "Please enter API keys" });
    }
    const voices = await getVoicesWithSDK(apiKeys);
    res.json(voices);
  } catch (err) {
    res.json({
      success: false,
      msg: "something went wrong",
    });
    console.log(err);
  }
});

// saving flow
router.post("/add_flow", validateUser, async (req, res) => {
  try {
    const { name, data } = req.body;
    if (!name || !data) {
      return res.json({ msg: "Please enter flow title and the nodes" });
    }
    const flow_id = randomstring.generate(6);
    await query(
      `INSERT INTO beta_flows (uid, flow_id, name, data) VALUES (?,?,?,?)`,
      [req.decode.uid, flow_id, name, JSON.stringify(data)]
    );

    res.json({ success: true, msg: "Flow was added" });
  } catch (err) {
    res.json({
      success: false,
      msg: "something went wrong",
    });
    console.log(err);
  }
});

// get all flows list
router.get("/get_flows", validateUser, async (req, res) => {
  try {
    let data = await query(`SELECT * FROM beta_flows WHERE uid = ?`, [
      req.decode.uid,
    ]);
    data = data.map((x) => {
      return {
        ...x,
        data: JSON.parse(x.data),
      };
    });
    res.json({ data, success: true });
  } catch (err) {
    res.json({
      success: false,
      msg: "something went wrong",
    });
    console.log(err);
  }
});

router.post("/update_flow", validateUser, async (req, res) => {
  try {
    const { flow_id, name, data } = req.body;
    if (!flow_id || !name || !data) {
      return res.json({ success: false, msg: "Missing required fields" });
    }

    // Check if the flow exists and belongs to the user
    const existingFlow = await query(
      `SELECT * FROM beta_flows WHERE flow_id = ? AND uid = ?`,
      [flow_id, req.decode.uid]
    );

    if (existingFlow.length === 0) {
      return res.json({
        success: false,
        msg: "Flow not found or unauthorized",
      });
    }

    // Update the flow
    await query(
      `UPDATE beta_flows SET name = ?, data = ? WHERE flow_id = ? AND uid = ?`,
      [name, JSON.stringify(data), flow_id, req.decode.uid]
    );

    res.json({ success: true, msg: "Flow updated successfully" });
  } catch (err) {
    console.error(err);
    res.json({
      success: false,
      msg: "Something went wrong",
    });
  }
});

router.post("/delete_flow", validateUser, async (req, res) => {
  try {
    const { flow_id } = req.body;
    if (!flow_id) {
      return res.json({ success: false, msg: "Flow ID is required" });
    }

    // Check if the flow exists and belongs to the user
    const existingFlow = await query(
      `SELECT * FROM beta_flows WHERE flow_id = ? AND uid = ?`,
      [flow_id, req.decode.uid]
    );

    if (existingFlow.length === 0) {
      return res.json({
        success: false,
        msg: "Flow not found or unauthorized",
      });
    }

    await query(`DELETE FROM beta_flows WHERE flow_id = ? AND uid = ?`, [
      flow_id,
      req.decode.uid,
    ]);

    res.json({ success: true, msg: "Flow deleted successfully" });
  } catch (err) {
    console.error(err);
    res.json({
      success: false,
      msg: "Something went wrong",
    });
  }
});

// get all devices
router.get("/get_devices", validateUser, async (req, res) => {
  try {
    const data = await query(`SELECT * FROM device WHERE uid = ?`, [
      req.decode.uid,
    ]);
    const parseDevice = data.map((x) => {
      return {
        ...x,
        voice_agent: x?.voice_agent ? JSON.parse(x?.voice_agent) : {},
        webhookUrl: `${process.env.BACKURI}/api/vagent/incoming/${x.device_id}`,
      };
    });
    res.json({ data: parseDevice, success: true });
  } catch (err) {
    console.error(err);
    res.json({
      success: false,
      msg: "Something went wrong",
    });
  }
});

router.post("/update_vagent", validateUser, async (req, res) => {
  try {
    const { deviceId, voiceAgent } = req.body;

    // Validate required fields
    if (!deviceId) {
      return res.json({
        success: false,
        msg: "Device ID is required",
      });
    }

    if (!voiceAgent || typeof voiceAgent !== "object") {
      return res.json({
        success: false,
        msg: "Voice agent configuration is required",
      });
    }

    // If voice agent is active, flow data is required
    if (voiceAgent.active && (!voiceAgent.flow || !voiceAgent.flow.id)) {
      return res.json({
        success: false,
        msg: "Flow data is required when voice agent is active",
      });
    }

    // Validate route field if present
    if (
      voiceAgent.active &&
      voiceAgent.route &&
      !["incoming", "outgoing"].includes(voiceAgent.route)
    ) {
      return res.json({
        success: false,
        msg: "Route must be either 'incoming' or 'outgoing'",
      });
    }

    // First check if the device belongs to the user
    const deviceCheck = await query(
      `SELECT id FROM device WHERE id = ? AND uid = ?`,
      [deviceId, req.decode.uid]
    );

    if (deviceCheck.length === 0) {
      return res.json({
        success: false,
        msg: "Device not found or you don't have permission to update it",
      });
    }

    // Prepare voice agent data with just the required fields
    const voiceAgentData = {
      active: voiceAgent.active,
      flow: voiceAgent.flow,
      route: voiceAgent.route || "incoming", // Default to incoming if not specified
    };

    // Stringify the voice agent configuration for MySQL storage
    const voiceAgentJSON = JSON.stringify(voiceAgentData);

    // Update the voice agent configuration in MySQL
    await query(`UPDATE device SET voice_agent = ? WHERE id = ? AND uid = ?`, [
      voiceAgentJSON,
      deviceId,
      req.decode.uid,
    ]);

    // Get the updated device
    const updatedDevice = await query(`SELECT * FROM device WHERE id = ?`, [
      deviceId,
    ]);

    if (updatedDevice.length === 0) {
      return res.json({
        success: false,
        msg: "Failed to retrieve updated device",
      });
    }

    // Parse the voice_agent field for the response
    const deviceData = {
      ...updatedDevice[0],
      voice_agent: updatedDevice[0]?.voice_agent
        ? JSON.parse(updatedDevice[0].voice_agent)
        : {},
    };

    // Return success response
    res.json({
      success: true,
      msg: "Voice agent updated successfully",
      device: deviceData,
    });
  } catch (err) {
    console.error(err);
    res.json({
      success: false,
      msg: "Something went wrong",
    });
  }
});

// delete selected call logs
router.post("/delete_call_logs", validateUser, async (req, res) => {
  try {
    const { logIds } = req.body;
    if (!logIds || !Array.isArray(logIds) || logIds.length === 0) {
      return res.json({ success: false, msg: "Please provide valid log IDs" });
    }

    // Convert IDs to a comma-separated string for the SQL query
    const placeholders = logIds.map(() => "?").join(",");

    await query(
      `DELETE FROM beta_call_log WHERE id IN (${placeholders})`,
      logIds
    );

    res.json({
      success: true,
      msg: `Successfully deleted ${logIds.length} log(s)`,
    });
  } catch (err) {
    console.error(err);
    res.json({
      success: false,
      msg: "Something went wrong while deleting logs",
    });
  }
});

// get call logs by flow id
router.post("/call_logs", validateUser, async (req, res) => {
  try {
    const { flowId } = req.body;
    if (!flowId) return res.json({ msg: "Please provide flow id" });
    console.log(flowId);
    const data = await query(`SELECT * FROM beta_call_log WHERE flow_id = ?`, [
      flowId,
    ]);
    res.json({ data, success: true });
  } catch (err) {
    console.error(err);
    res.json({
      success: false,
      msg: "Something went wrong",
    });
  }
});

router.post("/get_recording", validateUser, async (req, res) => {
  try {
    const { deviceId, sid } = req.body; // sid here is callSid
    if (!deviceId || !sid)
      return res.json({
        success: false,
        msg: "Please provide deviceId and sid",
      });

    const [device] = await query(
      `SELECT * FROM device WHERE device_id = ? AND uid = ?`,
      [deviceId, req.decode.uid]
    );

    if (!device || !device?.sid || !device?.token) {
      return res.json({
        success: false,
        msg: "The device looks deleted from the system",
      });
    }

    const client = twilio(device?.sid, device?.token);

    // List recordings using client.recordings.list with callSid (matching reference)
    const recordings = await client.recordings.list({
      callSid: sid,
      limit: 5,
    });

    if (recordings.length === 0) {
      // console.log(`No recordings found for callSid: ${sid}`);
      return res.json({
        success: false,
        msg: "No recording found for this call",
      });
    }

    // Sort by dateCreated descending to get the latest one (added for robustness, not in reference but useful)
    recordings.sort(
      (a, b) => new Date(b.dateCreated) - new Date(a.dateCreated)
    );

    // Pick the first (latest) recording (reference picks recordings[0] without sorting)
    const recording = recordings[0];

    // Fetch full recording details (includes mediaUrl, matching reference)
    const fullDetails = await client.recordings(recording.sid).fetch();

    // Return the full recording details, sid, and token (matching reference)
    res.json({
      success: true,
      data: fullDetails,
      sid: device.sid,
      token: device.token,
    });
  } catch (err) {
    console.error(err);
    res.json({
      success: false,
      msg: "Something went wrong",
    });
  }
});

// CREATE Campaign (POST /campaign)
router.post("/campaign", validateUser, async (req, res) => {
  try {
    const { title, phonebook_id, device_id } = req.body; // uid from auth middleware
    const uid = req.decode.uid;

    if (!title || !phonebook_id || !device_id) {
      return res.json({ msg: "Missing required fields" });
    }

    // Validate phonebook and device belong to user
    const [phonebook] = await query(
      "SELECT * FROM phonebook WHERE uid = ? AND phonebook_id = ?",
      [uid, phonebook_id]
    );
    if (!phonebook) return res.json({ msg: "Phonebook not found" });

    const [device] = await query(
      "SELECT * FROM device WHERE uid = ? AND device_id = ?",
      [uid, device_id]
    );
    const voiceAgent = device.voice_agent
      ? JSON.parse(device.voice_agent)
      : { active: false };
    if (!device || !voiceAgent?.active)
      return res.json({ msg: "Device not found or no active voice agent" });

    const campaign_id = randomstring.generate(8);
    await query(
      "INSERT INTO beta_campaign (uid, campaign_id, title, phonebook_id, device_id) VALUES (?, ?, ?, ?, ?)",
      [uid, campaign_id, title, phonebook_id, device_id]
    );

    res.json({ success: true, campaign_id });
  } catch (err) {
    console.log(err);
    res.json({ err, msg: "Something went wrong", success: false });
  }
});

// LIST Campaigns for User (GET /campaigns)
router.get("/campaigns", validateUser, async (req, res) => {
  try {
    const uid = req.decode.uid; // Or from auth
    const campaigns = await query(
      "SELECT * FROM beta_campaign WHERE uid = ? ORDER BY createdAt DESC",
      [uid]
    );
    res.json(campaigns);
  } catch (err) {
    console.log(err);
    res.json({ err, msg: "Something went wrong", success: false });
  }
});

// GET Logs for a Campaign (GET /campaign/logs/:campaign_id)
router.get("/campaign/logs/:campaign_id", validateUser, async (req, res) => {
  try {
    const { campaign_id } = req.params;
    const { uid } = req.decode; // Validate ownership

    const [campaign] = await query(
      "SELECT * FROM beta_campaign WHERE campaign_id = ? AND uid = ?",
      [campaign_id, uid]
    );
    if (!campaign) return res.json({ msg: "Campaign not found" });

    const logs = await query(
      "SELECT * FROM beta_campaign_log WHERE campaign_id = ? ORDER BY createdAt DESC",
      [campaign_id]
    );
    res.json(logs);
  } catch (err) {
    console.log(err);
    res.json({ err, msg: "Something went wrong", success: false });
  }
});

router.post("/call-status-callback", async (req, res) => {
  try {
    const { CallSid, CallStatus, CallDuration } = req.body;

    // Find the log entry
    const [log] = await query(
      "SELECT * FROM beta_campaign_log WHERE twilio_sid = ?",
      [CallSid]
    );
    if (!log) return res.status(404).send();

    // Update status and duration
    await query(
      "UPDATE beta_campaign_log SET status = ?, duration = ? WHERE twilio_sid = ?",
      [
        CallStatus.toUpperCase(),
        CallDuration ? `00:${CallDuration.padStart(2, "0")}:00` : null,
        CallSid,
      ] // Format duration as HH:MM:SS
    );

    res.status(200).send();
  } catch (err) {
    console.log(err);
    res.json({ err, msg: "Something went wrong", success: false });
  }
});

module.exports = router;
