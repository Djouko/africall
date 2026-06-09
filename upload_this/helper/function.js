const { ElevenLabsClient } = require("@elevenlabs/elevenlabs-js");
const { query } = require("../database/dbpromise");
const {
  getPlanDetails,
  getNumberOfDaysFromTimestamp,
} = require("../functions/function");

async function getVoicesWithSDK(apiKey) {
  try {
    const elevenlabs = new ElevenLabsClient({
      apiKey: apiKey,
    });
    const voices = await elevenlabs.voices.getAll();
    const voiceData = voices?.voices || [];
    return { success: true, data: voiceData };
  } catch (error) {
    console.error("Error fetching voices:");
    return { success: false, err: error, msg: error?.toString() };
  }
}

async function getDeviceId(deviceId) {
  try {
    const [device] = await query(`SELECT * FROM device WHERE device_id = ?`, [
      deviceId,
    ]);

    if (device?.voice_agent) {
      const voiceAgent = JSON.parse(device.voice_agent);

      let [flowData] = await query(
        `SELECT * FROM beta_flows WHERE flow_id = ?`,
        [voiceAgent?.flow?.flow_id]
      );

      if (flowData?.data) {
        flowData.data = JSON.parse(flowData.data);
      }

      device.voice_agent = {
        ...voiceAgent,
        flow: flowData || null,
      };
    }

    const [user] = await query(`SELECT * FROM user WHERE uid = ?`, [
      device?.uid,
    ]);
    if (!user) return null;
    const numOfDyaLeft = getNumberOfDaysFromTimestamp(user?.plan_expire);
    if (numOfDyaLeft < 1) return null;

    return device || null;
  } catch (err) {
    console.error(err);
    return null;
  }
}

function parseJson(data) {
  try {
    return JSON.parse(data);
  } catch (err) {
    return null;
  }
}

function getTwimlMsg(msg) {
  return `<?xml version="1.0" encoding="UTF-8"?>
                             <Response>
                                 <Say>${msg || "Message not found"}</Say>
                             </Response>`;
}

module.exports = {
  getVoicesWithSDK,
  getDeviceId,
  parseJson,
  getTwimlMsg,
};
