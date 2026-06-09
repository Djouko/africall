const router = require("express").Router();
const { handleIncomingCall } = require("../voiceAgent/websocketHandlers");
const { setupMediaStream } = require("../voiceAgent/websocketHandlers");
const twilio = require("twilio");
const { VoiceResponse } = require("twilio").twiml;

router.all("/outgoing-connect/:device_id", handleIncomingCall);

// Route for Twilio to handle incoming calls
router.all("/incoming/:device_id", handleIncomingCall);

// WebSocket route for media-stream
router.ws("/media-stream", setupMediaStream);

router.post("/conference-status", (req, res) => {
  const { StatusCallbackEvent, ConferenceSid, CallSid } = req.body;

  // console.log(
  //   `Conference event: ${StatusCallbackEvent} for conference ${ConferenceSid}`
  // );

  // Handle conference events as needed
  if (StatusCallbackEvent === "participant-leave") {
    // Could implement logic to end conference when one party leaves
  }

  res.status(200).send("OK");
});

module.exports = router;
