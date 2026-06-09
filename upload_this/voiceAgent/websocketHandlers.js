const WebSocket = require("ws");
const { query } = require("../database/dbpromise");
const { getDeviceId, getTwimlMsg } = require("../helper/function");
const { functionRegistry } = require("./functionRegistry");
const {
  substituteVariables,
  getValueByPath,
  evaluateCondition,
} = require("./utils");
const twilio = require("twilio");
const { getNumberOfDaysFromTimestamp } = require("../functions/function");

async function startRecordingAndAddLog({
  callSid,
  device,
  incoming = true,
  voiceAgent,
  enableRecording,
  other,
}) {
  try {
    if (callSid) {
      // Delay to allow call to connect (adjust based on testing; e.g., 1000-2000ms)
      setTimeout(async () => {
        try {
          if (enableRecording) {
            const client = twilio(device?.sid, device?.token);
            const recording = await client.calls(callSid).recordings.create({
              // Optional: Customize (e.g., dual channels for separate caller/AI tracks)
              channels: "dual", // 'mono' or 'dual' (dual separates directions)
            });
            // console.log(`Recording started: ${recording.sid}`);
          }

          const routeType =
            other?.Direction === "outbound-api" ||
            other?.direction === "outbound-api"
              ? "outgoing"
              : "incoming";

          await query(
            `INSERT INTO beta_call_log (uid, sid, source, flow_id, device_id, other) VALUES (?,?,?,?,?,?)`,
            [
              device?.uid,
              callSid,
              routeType,
              voiceAgent?.flow?.flow_id,
              device?.device_id,
              JSON.stringify(other),
            ]
          );
        } catch (err) {
          console.error(
            `Error starting recording for CallSid ${callSid}:`,
            err
          );
        }
      }, 1500);
    }
  } catch (err) {
    console.log(err);
  }
}

async function handleIncomingCall(req, res) {
  try {
    const deviceId = req.params.device_id;
    const device = await getDeviceId(deviceId);

    if (!device) {
      // console.log("No device found");
      return res.type("text/xml").send(getTwimlMsg("No device found"));
    }

    // checking for plan expire
    const [user] = await query(`SELECT * FROM user WHERE uid = ?`, [
      device?.uid,
    ]);
    if (!user) return null;
    const numOfDyaLeft = getNumberOfDaysFromTimestamp(user?.plan_expire);
    if (numOfDyaLeft < 1) return null;
    // checking for plan expire end

    if (!device?.sid || !device?.token) {
      // console.log("Device SID or token missing");
      return res
        .type("text/xml")
        .send(getTwimlMsg("Device SID or token missing"));
    }

    const voiceAgent = device.voice_agent;

    if (!voiceAgent || !voiceAgent.active) {
      console.log("No active agent found for this device");
      return res
        .type("text/xml")
        .send(getTwimlMsg("No active agent found for this device"));
    }

    const nodes = voiceAgent?.flow?.data?.nodes || [];
    const edges = voiceAgent?.flow?.data?.edges || [];

    if (nodes?.length < 1 || edges?.length < 1) {
      console.log("Nodes or edges are not enough to run this flow");
      return res
        .type("text/xml")
        .send(
          getTwimlMsg("The automation flow is not enough to run the agent")
        );
    }

    const twimlResponse = `<?xml version="1.0" encoding="UTF-8"?>
                          <Response>
                              <Connect>
                                      <Stream url="wss://${req.headers.host}/api/vagent/media-stream">
                                          <Parameter name="device_id" value="${deviceId}" />
                                      </Stream>
                              </Connect>
                          </Response>`;

    res.type("text/xml").send(twimlResponse);

    // NEW: Load flow config to check enableRecording (from AI Start node)
    // NEW: Load flow config to check enableRecording (from AI Start node)
    const aiStartNode = nodes.find((node) => node.id === "1"); // Assuming AI Start is node "1"
    const flowConfig = aiStartNode?.data || {};
    const enableRecording = flowConfig.enableRecording || false;

    // NEW: If recording is enabled, start it asynchronously after a short delay (to ensure call is connected)

    const callSid = req?.body?.CallSid;
    if (callSid) {
      startRecordingAndAddLog({
        callSid,
        device,
        voiceAgent,
        enableRecording,
        other: req?.body,
        incoming: true,
      });
    }
  } catch (err) {
    console.error("Error handling incoming call:", err);
    res.status(500).send("Internal Server Error");
  }
}

function setupMediaStream(ws, req) {
  // console.log("Client connected", { url: req.originalUrl });

  let streamSid = null;
  let latestMediaTimestamp = 0;
  let lastAssistantItem = null;
  let markQueue = [];
  let responseStartTimestampTwilio = null;
  let loadedFlow = null;
  let flowConfig = null;
  let openAiWs = null;
  let elevenWs = null;
  let textQueue = [];
  let voiceAgentData = null;

  const sendMark = (connection, streamSid) => {
    if (streamSid) {
      const markEvent = {
        event: "mark",
        streamSid: streamSid,
        mark: { name: "responsePart" },
      };
      connection.send(JSON.stringify(markEvent));
      markQueue.push("responsePart");
    }
  };

  const initializeElevenLabsWs = () => {
    if (!flowConfig || flowConfig.voice_source !== "elevenlabs") return;

    const voiceId = flowConfig.el_voice?.voiceId || "H6QPv2pQZDcGqLwDTIJQ";
    // console.log({ voiceId: voiceId });
    const apiKey = flowConfig.elevenlabs_api_key || "";

    if (!apiKey) {
      console.error("Missing ElevenLabs API key. Cannot initialize WebSocket.");
      return;
    }

    elevenWs = new WebSocket(
      `wss://api.elevenlabs.io/v1/text-to-speech/${voiceId}/stream-input?model_id=${
        flowConfig.elevenlabs_model_id || "eleven_multilingual_v2"
      }&output_format=ulaw_8000`,
      { headers: { "xi-api-key": apiKey } }
    );

    elevenWs.on("open", () => {
      // console.log("Connected to ElevenLabs WebSocket");
      const bosMessage = {
        text: " ",
        voice_settings: {
          stability: flowConfig.elevenlabs_stability || 0.5,
          similarity_boost: flowConfig.elevenlabs_similarity_boost || 0.75,
          style: flowConfig.elevenlabs_style || 0.0,
          use_speaker_boost: flowConfig.elevenlabs_use_speaker_boost || true,
        },
        generation_config: { chunk_length_schedule: [50] },
        xi_api_key: apiKey,
      };
      elevenWs.send(JSON.stringify(bosMessage));

      while (textQueue.length > 0) {
        const queuedMsg = textQueue.shift();
        elevenWs.send(JSON.stringify(queuedMsg));
      }
    });

    elevenWs.on("message", (data) => {
      const response = JSON.parse(data);
      if (response.audio) {
        const audioDelta = {
          event: "media",
          streamSid: streamSid,
          media: { payload: response.audio },
        };
        ws.send(JSON.stringify(audioDelta));

        if (!responseStartTimestampTwilio) {
          responseStartTimestampTwilio = latestMediaTimestamp;
          // if (flowConfig.show_timing_math)
          //   console.log(
          //     `Setting start timestamp for new response: ${responseStartTimestampTwilio}ms`
          //   );
        }

        sendMark(ws, streamSid);
      }
    });

    elevenWs.on("error", (error) =>
      console.error("ElevenLabs WebSocket error:", error)
    );
    elevenWs.on("close", () => {
      // console.log("ElevenLabs WebSocket closed");
      elevenWs = null;
    });
  };

  const sendToEleven = (msg) => {
    if (elevenWs && elevenWs.readyState === WebSocket.OPEN) {
      elevenWs.send(JSON.stringify(msg));
    } else {
      textQueue.push(msg);
      if (!elevenWs) {
        initializeElevenLabsWs();
      }
    }
  };

  ws.on("message", async (message) => {
    try {
      const data = JSON.parse(message);

      switch (data.event) {
        case "start":
          streamSid = data.start.streamSid;
          // console.log("Incoming stream has started", streamSid);

          const deviceId = data?.start?.customParameters?.device_id;

          const device = await getDeviceId(deviceId);

          // SOTRING THE DEVICE AND CALLSID HERE
          currentDevice = device;
          currentCallSid = data?.start?.callSid;

          if (!device) {
            console.log("No device found");
            ws.close();
            return;
          }

          const voiceAgent = device.voice_agent;
          if (!voiceAgent || !voiceAgent.active) {
            console.log("No active agent found for this device");
            ws.close();
            return;
          }

          const nodes = voiceAgent?.flow?.data?.nodes || [];
          const edges = voiceAgent?.flow?.data?.edges || [];

          if (nodes?.length < 1 || edges?.length < 1) {
            console.log("Nodes or edges are not enough to run this flow");
            ws.close();
            return;
          }

          voiceAgentData = voiceAgent;
          loadedFlow = voiceAgent.flow.data;
          const aiStartNode = nodes.find((node) => node.id === "1");
          if (!aiStartNode) {
            console.error("AI Start node not found. Closing connection.");
            ws.close();
            return;
          }

          flowConfig = aiStartNode.data || {};
          // console.log({ flowConfig: JSON.stringify(flowConfig) });

          const openAiApiKey = flowConfig.apiKeys || "";
          if (!openAiApiKey) {
            console.error("Missing OpenAI API key. Closing connection.");
            ws.close();
            return;
          }

          openAiWs = new WebSocket(
            `wss://api.openai.com/v1/realtime?model=${
              flowConfig.openai_model || "gpt-4o-realtime-preview"
            }`,
            {
              headers: {
                Authorization: `Bearer ${openAiApiKey}`,
                "OpenAI-Beta": "realtime=v1",
              },
            }
          );

          setupOpenAiHandlers();
          responseStartTimestampTwilio = null;
          latestMediaTimestamp = 0;
          break;

        case "media":
          latestMediaTimestamp = data.media.timestamp;
          // if (flowConfig && flowConfig.show_timing_math)
          //   console.log(
          //     `Received media message with timestamp: ${latestMediaTimestamp}ms`
          //   );

          if (openAiWs && openAiWs.readyState === WebSocket.OPEN) {
            const audioAppend = {
              type: "input_audio_buffer.append",
              audio: data.media.payload,
            };
            openAiWs.send(JSON.stringify(audioAppend));
          }
          break;

        case "mark":
          if (markQueue.length > 0) {
            markQueue.shift();
          }
          break;

        case "dtmf":
          const pressedDigit = data.dtmf.digit;
          // console.log(`User pressed: ${pressedDigit}`);
          break;

        default:
          // console.log("Received non-media event:", data.event);
          break;
      }
    } catch (error) {
      console.error(
        "Error parsing message:",
        error,
        "Message:",
        message.toString()
      );
    }
  });

  ws.on("close", () => {
    if (openAiWs && openAiWs.readyState === WebSocket.OPEN) {
      openAiWs.close();
    }
    if (elevenWs && elevenWs.readyState === WebSocket.OPEN) {
      elevenWs.close();
    }
    console.log("Client disconnected.");
  });

  const setupOpenAiHandlers = () => {
    const initializeSession = () => {
      const modalities =
        flowConfig.voice_source === "openai" ? ["text", "audio"] : ["text"];

      let instructions =
        flowConfig.system_message || "You are an AI assistant.";
      if (
        flowConfig.welcome_message &&
        flowConfig.welcome_message.trim() !== ""
      ) {
        instructions += `\n\nStart the conversation by saying exactly: "${flowConfig.welcome_message}"`;
      }

      const sessionUpdate = {
        type: "session.update",
        session: {
          turn_detection: { type: "server_vad" },
          input_audio_format: "g711_ulaw",
          output_audio_format: "g711_ulaw",
          voice: flowConfig.openai_voice || "alloy",
          instructions: instructions,
          modalities: modalities,
          temperature: flowConfig.temperature || 0.9,
          tools: flowConfig.available_tools || [],
        },
      };
      openAiWs.send(JSON.stringify(sessionUpdate));

      if (
        flowConfig.welcome_message &&
        flowConfig.welcome_message.trim() !== ""
      ) {
        openAiWs.send(JSON.stringify({ type: "response.create" }));
      }
    };

    const handleSpeechStartedEvent = () => {
      if (markQueue.length > 0 && responseStartTimestampTwilio != null) {
        const elapsedTime = latestMediaTimestamp - responseStartTimestampTwilio;
        if (flowConfig.show_timing_math && lastAssistantItem) {
          const truncateEvent = {
            type: "conversation.item.truncate",
            item_id: lastAssistantItem,
            content_index: 0,
            audio_end_ms: elapsedTime,
          };
          openAiWs.send(JSON.stringify(truncateEvent));
        }

        ws.send(JSON.stringify({ event: "clear", streamSid: streamSid }));

        if (
          flowConfig.voice_source === "elevenlabs" &&
          elevenWs &&
          elevenWs.readyState === WebSocket.OPEN
        ) {
          elevenWs.send(JSON.stringify({ text: "" }));
          elevenWs.close();
          elevenWs = null;
          textQueue = [];
        }

        markQueue = [];
        lastAssistantItem = null;
        responseStartTimestampTwilio = null;
      }
    };

    openAiWs.on("open", () => {
      // console.log("Connected to the OpenAI Realtime API");
      setTimeout(initializeSession, 100);
    });

    openAiWs.on("message", async (data) => {
      try {
        const response = JSON.parse(data);

        if (response.type === "response.function_call_arguments.done") {
          // console.log(`🔧 Function call received: ${response.name}`);
          const functionName = response.name;
          const args = JSON.parse(response.arguments || "{}");
          const callId = response.call_id;

          let functionResult;
          const startingEdge = loadedFlow.edges.find(
            (edge) =>
              edge.source === "1" &&
              edge.sourceHandle === `function-${functionName}`
          );
          if (startingEdge) {
            functionResult = await executeFlowForFunction(
              functionName,
              args,
              currentDevice,
              currentCallSid
            );
          } else if (functionRegistry[functionName]) {
            functionResult = await functionRegistry[functionName](args);
          } else {
            functionResult = {
              instruct:
                "check the response if success or failed and act as per the response",
              data: { error: `Unknown function: ${functionName}` },
            };
          }

          const functionResponse = {
            type: "conversation.item.create",
            item: {
              type: "function_call_output",
              call_id: callId,
              output: JSON.stringify(functionResult),
            },
          };
          openAiWs.send(JSON.stringify(functionResponse));
          // console.log("✅ Function result sent to OpenAI");

          openAiWs.send(JSON.stringify({ type: "response.create" }));

          console.dir({ functionResult }, { depth: null });

          // After sending functionResponse
          if (functionResult?.data?.hangup || functionResult?.data[0]?.hangup) {
            // console.log("HANGING UP");
            // Optionally send farewell message via ElevenLabs or OpenAI
            if (
              flowConfig.voice_source === "elevenlabs" &&
              functionResult?.data[0]?.farewell
            ) {
              sendToEleven({ text: functionResult?.data[0]?.farewell + " " });
              setTimeout(() => {
                if (elevenWs) elevenWs.close();
                if (openAiWs) openAiWs.close();
                if (ws) ws.close();
              }, 2000); // Delay to allow farewell to play
            } else {
              // For OpenAI voice, you might need to trigger a final response
              // Then close connections
              openAiWs.close();
              ws.close();
            }
          }
        }

        if (flowConfig.log_event_types?.includes(response.type)) {
          // console.log(`Received event: ${response.type}`);
        }

        if (
          flowConfig.voice_source === "openai" &&
          response.type === "response.audio.delta" &&
          response.delta
        ) {
          const audioDelta = {
            event: "media",
            streamSid: streamSid,
            media: { payload: response.delta },
          };
          ws.send(JSON.stringify(audioDelta));

          if (!responseStartTimestampTwilio) {
            responseStartTimestampTwilio = latestMediaTimestamp;
            // if (flowConfig.show_timing_math)
            //   console.log(
            //     `Setting start timestamp for new response: ${responseStartTimestampTwilio}ms`
            //   );
          }

          if (response.item_id) lastAssistantItem = response.item_id;
          sendMark(ws, streamSid);
        } else if (
          flowConfig.voice_source === "elevenlabs" &&
          response.type === "response.text.delta" &&
          response.delta
        ) {
          const textMessage = {
            text: response.delta + " ",
            try_trigger_generation: true,
          };
          sendToEleven(textMessage);
        }

        if (
          response.type === "response.done" &&
          flowConfig.voice_source === "elevenlabs"
        ) {
          sendToEleven({ text: "" });
        }

        if (response.type === "input_audio_buffer.speech_started") {
          handleSpeechStartedEvent();
        }

        if (response.type === "response.created") {
          if (flowConfig.voice_source === "elevenlabs") {
            lastAssistantItem = response.response.id;
          } else {
            lastAssistantItem = response.response.id;
          }
        }
      } catch (error) {
        console.error(
          "Error processing OpenAI message:",
          error,
          "Raw message:",
          data.toString()
        );
      }
    });

    openAiWs.on("close", () =>
      console.log("Disconnected from the OpenAI Realtime API")
    );
    openAiWs.on("error", (error) =>
      console.error("Error in the OpenAI WebSocket:", error)
    );
  };

  const executeFlowForFunction = async (
    functionName,
    initialArgs,
    device,
    callSid
  ) => {
    if (!loadedFlow) {
      return {
        instruct:
          "check the response if success or failed and act as per the response",
        data: { error: "No flow loaded" },
      };
    }

    const startingEdge = loadedFlow.edges.find(
      (edge) =>
        edge.source === "1" && edge.sourceHandle === `function-${functionName}`
    );
    if (!startingEdge) {
      return {
        instruct:
          "check the response if success or failed and act as per the response",
        data: { error: `No flow connected for function: ${functionName}` },
      };
    }

    let currentNodeId = startingEdge.target;
    let params = initialArgs;
    const accumulatedData = [];
    const previousResponses = [];

    // console.log(
    //   `Initial OpenAI args for ${functionName}: ${JSON.stringify(initialArgs)}`
    // );
    if (Object.keys(initialArgs).length === 0) {
      console.warn("No arguments received from OpenAI function call.");
    }

    while (currentNodeId) {
      const currentNode = loadedFlow.nodes.find(
        (node) => node.id === currentNodeId
      );
      if (!currentNode) break;

      const nodeParams = {
        currentNode: currentNode?.data,
        paramsValue: params,
        previousResponses: [...previousResponses],
        ai: { ...initialArgs },
      };

      // console.log(
      //   `Node params for node ${currentNodeId} (${
      //     currentNode.type
      //   }): ${JSON.stringify(nodeParams)}`
      // );

      let nodeResponse;
      let nextEdge;

      // console.log({ functionType: currentNode.type });

      switch (currentNode.type) {
        case "sendMessage":
          nodeResponse = await functionRegistry.send_message(nodeParams);
          nextEdge = loadedFlow.edges.find(
            (edge) => edge.source === currentNodeId
          );
          break;

        case "sendEmail":
          nodeResponse = await functionRegistry.send_email(nodeParams);
          nextEdge = loadedFlow.edges.find(
            (edge) => edge.source === currentNodeId
          );
          break;

        case "conditional":
          // console.log(`🔀 Evaluating conditional node: ${currentNode.id}`);
          const pathToEvaluate = currentNode.data.variableName;
          let valueToEvaluate = getValueByPath(nodeParams, pathToEvaluate);

          valueToEvaluate =
            valueToEvaluate !== undefined && valueToEvaluate !== null
              ? String(valueToEvaluate)
              : valueToEvaluate;

          // console.log(`Path: ${pathToEvaluate}, Value: ${valueToEvaluate}`);

          let matchedCondition = null;
          for (const condition of currentNode.data.conditions || []) {
            if (condition.type === "default" || !condition.type) {
              // console.log(
              //   `Skipping condition: ${condition.name || condition.id} (type: ${
              //     condition.type || "undefined"
              //   })`
              // );
              continue;
            }
            const isMatch = evaluateCondition(valueToEvaluate, condition);
            // console.log(
            //   `Evaluating condition "${
            //     condition.name || condition.id
            //   }" (type: ${condition.type}, value: ${condition.value}): ${
            //     isMatch ? "Matched" : "Did not match"
            //   }`
            // );
            if (isMatch) {
              matchedCondition = condition;
              // console.log(
              //   `✅ Matched condition: ${condition.name || condition.id}`
              // );
              break;
            }
          }

          if (!matchedCondition) {
            matchedCondition = currentNode.data.conditions.find(
              (c) => c.type === "default"
            );
            if (matchedCondition) {
              // console.log(
              //   `⚠️ Using default condition: ${
              //     matchedCondition.name || "Default"
              //   }`
              // );
            } else {
              console.warn("No conditions matched and no default found.");
              nodeResponse = {
                instruct:
                  "check the response if success or failed and act as per the response",
                data: { error: "No matching condition or default found" },
              };
              break;
            }
          }

          nextEdge = loadedFlow.edges.find(
            (edge) =>
              edge.source === currentNodeId &&
              edge.sourceHandle === `condition-${matchedCondition?.id}`
          );

          if (!nextEdge) {
            console.warn(
              `No edge found for condition: ${matchedCondition?.id}`
            );
            nodeResponse = {
              instruct:
                "check the response if success or failed and act as per the response",
              data: { error: "No connected edge for matched condition" },
            };
            break;
          }

          nodeResponse = {
            instruct: "Condition evaluation result",
            data: {
              condition: matchedCondition?.name || "Unknown",
              value: valueToEvaluate,
            },
          };
          break;

        case "googleServices":
          nodeResponse = await functionRegistry.google_services(nodeParams);
          nextEdge = loadedFlow.edges.find(
            (edge) => edge.source === currentNodeId
          );
          break;

        case "apiCall":
          nodeResponse = await functionRegistry.api_call(nodeParams);
          nextEdge = loadedFlow.edges.find(
            (edge) => edge.source === currentNodeId
          );
          break;

        case "hangup":
          nodeResponse = await functionRegistry.hangup_call(nodeParams);
          // Since it's a terminal node, no nextEdge needed
          nextEdge = null; // Force loop exit
          break;

        case "sendWhatsapp":
          nodeResponse = await functionRegistry.send_whatsapp(nodeParams);
          nextEdge = loadedFlow.edges.find(
            (edge) => edge.source === currentNodeId
          );
          break;

        case "sendSms":
          nodeResponse = await functionRegistry.send_sms(nodeParams);
          nextEdge = loadedFlow.edges.find(
            (edge) => edge.source === currentNodeId
          );
          break;

        case "smtpEmail": // New case for the node
          nodeResponse = await functionRegistry.send_smtp_email(nodeParams);
          nextEdge = loadedFlow.edges.find(
            (edge) => edge.source === currentNodeId
          );
          break;

        case "playAudio":
          nodeResponse = await functionRegistry.play_audio(
            nodeParams,
            ws,
            streamSid
          );
          nextEdge = loadedFlow.edges.find(
            (edge) => edge.source === currentNodeId
          );
          break;

        case "mysqlQuery":
          nodeResponse = await functionRegistry.mysql_query(nodeParams);
          nextEdge = loadedFlow.edges.find(
            (edge) => edge.source === currentNodeId
          );
          break;

        case "callForward":
          // console.log(`📞 Processing call forward node: ${currentNode.id}`);

          try {
            const nodeData = currentNode.data || currentNode;
            const phoneNumber = nodeData.phoneNumber?.replace("+", "");

            if (!phoneNumber) {
              nodeResponse = {
                instruct: "Call forward failed - no phone number provided",
                data: {
                  success: false,
                  error: "Phone number is required",
                },
              };
              break;
            }

            const client = twilio(device?.sid, device?.token);

            // Stop media stream
            if (ws.readyState === WebSocket.OPEN) {
              ws.send(
                JSON.stringify({
                  event: "stop",
                  streamSid: streamSid,
                })
              );
            }

            // Create unique conference name
            const conferenceName = `transfer-${callSid}-${Date.now()}`;

            // Update current call to join conference
            const call = await client.calls(callSid).update({
              twiml: `<Response>
        <Dial>
          <Conference 
            waitUrl="http://twimlets.com/holdmusic?Bucket=com.twilio.music.ambient"
            statusCallback="${process.env.BACKURI}/api/vagent/conference-status"
            statusCallbackEvent="start end join leave"
            statusCallbackMethod="POST"
            endConferenceOnExit="true">
            ${conferenceName}
          </Conference>
        </Dial>
        <Hangup/>
      </Response>`,
            });

            // Create outbound call to target number and add to same conference
            setTimeout(async () => {
              try {
                const outboundCall = await client.calls.create({
                  to: phoneNumber,
                  from: device?.number,
                  twiml: `<Response>
            <Say>You have an incoming transfer.</Say>
            <Dial>
              <Conference endConferenceOnExit="true">${conferenceName}</Conference>
            </Dial>
            <Hangup/>
          </Response>`,
                });

                // console.log(`Outbound call created: ${outboundCall.sid}`);
              } catch (error) {
                console.error("Failed to create outbound call:", error);
              }
            }, 2000);

            // console.log(`Conference transfer initiated to ${phoneNumber}`);

            // Close WebSocket after a delay
            setTimeout(() => {
              if (ws.readyState === WebSocket.OPEN) {
                ws.close();
              }
            }, 1000);

            nodeResponse = {
              instruct:
                "Call forward initiated successfully using conference bridge",
              data: {
                success: true,
                conferenceName: conferenceName,
                targetNumber: phoneNumber,
              },
            };

            // Since callForward closes the WebSocket, we should return early
            if (nodeResponse?.data?.success) {
              return {
                instruct: nodeResponse.instruct,
                data: accumulatedData,
              };
            }
          } catch (error) {
            console.error("Conference transfer failed:", error);

            nodeResponse = {
              instruct: "Call forward failed - check error details",
              data: {
                success: false,
                error: error.message || "Unknown error",
              },
            };
          }

          nextEdge = loadedFlow.edges.find(
            (edge) => edge.source === currentNodeId
          );
          break;

        default:
          nodeResponse = {
            instruct:
              "check the response if success or failed and act as per the response",
            data: { error: `Unsupported node type: ${currentNode.type}` },
          };
          nextEdge = loadedFlow.edges.find(
            (edge) => edge.source === currentNodeId
          );
          break;
      }

      if (nodeResponse?.data) {
        accumulatedData.push(nodeResponse.data);
      }

      if (nodeResponse?.data) {
        previousResponses.push(nodeResponse.data);
      }

      if (!nextEdge) break;

      if (nodeResponse?.data) {
        params = nodeResponse.data || {};
      }

      currentNodeId = nextEdge.target;
    }

    return {
      instruct:
        "check the response if success or failed and act as per the response",
      data: accumulatedData,
    };
  };
}

module.exports = {
  handleIncomingCall,
  setupMediaStream,
};
