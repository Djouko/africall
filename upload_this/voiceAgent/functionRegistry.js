const {
  substituteVariables,
  getValueByPath,
  evaluateCondition,
} = require("./utils");
const axios = require("axios");
const { query } = require("../database/dbpromise");
const { google } = require("googleapis");
const twilio = require("twilio");
const nodemailer = require("nodemailer");
const ffmpeg = require("fluent-ffmpeg");
const ffmpegStatic = require("ffmpeg-static");
const wav = require("wav");
const fs = require("fs");
const path = require("path");
ffmpeg.setFfmpegPath(ffmpegStatic);
const mysql = require("mysql2/promise");

async function sendMessageFunc(params) {
  // console.log({ sendMsgg: params });
  const mobile = params.mobile || params.openAiArgs?.mobile || "default_mobile";
  // console.log(`Extracted mobile from params/OpenAI args: ${mobile}`);

  return new Promise((resolve) => {
    setTimeout(() => {
      resolve({ success: false, msg: "The number should be start from 44" });
    }, 2000);
  });
}

async function sendEmailFunc(params) {
  // console.log({ sendEmailParams: params });
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve({ success: true, msg: "Email was sent to the number" });
    }, 2000);
  });
}

async function makeApiCallFunc(params) {
  // console.log({ apiCallParams: params });

  try {
    const nodeData = params.currentNode.data || params.currentNode;
    const method = (nodeData.method || "GET").toUpperCase();
    const rawUrl = nodeData.url || "";
    const timeout = nodeData.timeout || 10000;

    // console.log("Raw URL before substitution:", rawUrl);
    const url = substituteVariables(rawUrl, params);
    // console.log("URL after substitution:", url);

    if (!url || url.trim() === "") {
      throw new Error("URL is required and cannot be empty");
    }

    try {
      new URL(url);
    } catch (urlError) {
      throw new Error(`Invalid URL format: ${url}`);
    }

    const headers = {};
    if (nodeData.headers && Array.isArray(nodeData.headers)) {
      nodeData.headers.forEach((header) => {
        if (header.key && header.value) {
          const key = substituteVariables(header.key, params);
          const value = substituteVariables(header.value, params);
          headers[key] = value;
        }
      });
    }

    const queryParams = {};
    if (nodeData.queryParams && Array.isArray(nodeData.queryParams)) {
      nodeData.queryParams.forEach((param) => {
        if (param.key && param.value) {
          const key = substituteVariables(param.key, params);
          const value = substituteVariables(param.value, params);
          queryParams[key] = value;
        }
      });
    }

    let requestBody = null;
    if (["POST", "PUT", "PATCH"].includes(method) && nodeData.body) {
      const bodyString = substituteVariables(nodeData.body, params);
      try {
        requestBody = JSON.parse(bodyString);
      } catch (e) {
        requestBody = bodyString;
      }
    }

    const axiosConfig = {
      method: method.toLowerCase(),
      url: url,
      headers: {
        "Content-Type": "application/json",
        ...headers,
      },
      params: queryParams,
      timeout: timeout,
      validateStatus: function (status) {
        return status >= 200 && status < 600;
      },
    };

    if (requestBody !== null) {
      axiosConfig.data = requestBody;
    }

    // console.log("Making API request with config:", {
    //   method: axiosConfig.method,
    //   url: axiosConfig.url,
    //   headers: axiosConfig.headers,
    //   params: axiosConfig.params,
    //   data: axiosConfig.data,
    // });

    const response = await axios(axiosConfig);
    let responseData;
    try {
      if (typeof response.data === "object" && response.data !== null) {
        responseData = response.data;
      } else {
        responseData = JSON.parse(response.data);
      }
    } catch (e) {
      responseData = {};
    }

    return {
      success: response.status >= 200 && response.status < 300,
      status: response.status,
      statusText: response.statusText,
      data: responseData,
      headers: response.headers,
      url: response.config.url,
      method: response.config.method?.toUpperCase(),
    };
  } catch (error) {
    console.error("API call error:", error);
    if (error.code === "ECONNABORTED") {
      return {
        success: false,
        error: "Request timeout",
        data: {},
        status: 0,
      };
    } else if (error.response) {
      let errorData;
      try {
        errorData =
          typeof error.response.data === "object"
            ? error.response.data
            : JSON.parse(error.response.data);
      } catch (e) {
        errorData = {};
      }

      return {
        success: false,
        status: error.response.status,
        statusText: error.response.statusText,
        error: error.message,
        data: errorData,
      };
    } else {
      return {
        success: false,
        error: error.message || "Unknown error",
        data: {},
        status: 0,
      };
    }
  }
}
async function googleServicesFunc(params) {
  // console.log({ googleServicesParams: params });

  try {
    const nodeData = params.currentNode || params.currentNode?.data;
    const serviceType = nodeData.serviceType || "sheets";
    const credentialId = nodeData.credentialId;

    if (!credentialId) {
      throw new Error("Google credential ID is required");
    }

    // Get credentials from database
    const credQuery = `SELECT service_account_json FROM google_credentials 
                      WHERE credential_id = ? AND is_active = 1`;
    const credResult = await query(credQuery, [credentialId]);

    if (credResult.length === 0) {
      throw new Error("Google credentials not found or inactive");
    }

    const serviceAccountJson = JSON.parse(credResult[0].service_account_json);

    // Create JWT client
    const jwtClient = new google.auth.JWT(
      serviceAccountJson.client_email,
      null,
      serviceAccountJson.private_key,
      serviceType === "sheets"
        ? ["https://www.googleapis.com/auth/spreadsheets"]
        : [
            "https://www.googleapis.com/auth/calendar",
            "https://www.googleapis.com/auth/calendar.events",
            "https://www.googleapis.com/auth/admin.directory.resource.calendar",
          ],
      null
    );

    await jwtClient.authorize();

    if (serviceType === "sheets") {
      return await handleSheetsOperation(jwtClient, nodeData, params);
    } else if (serviceType === "calendar") {
      return await handleCalendarOperation(jwtClient, nodeData, params);
    }

    throw new Error(`Unsupported service type: ${serviceType}`);
  } catch (error) {
    console.error("Google Services error:", error);
    return {
      success: false,
      error: error.message || "Unknown error",
      data: {},
    };
  }
}

async function handleSheetsOperation(jwtClient, nodeData, params) {
  const sheets = google.sheets({ version: "v4", auth: jwtClient });

  const spreadsheetId = substituteVariables(nodeData.spreadsheetId, params);
  const range = substituteVariables(nodeData.range, params);
  const action = nodeData.action || "writeSheet";

  if (action === "writeSheet") {
    let values;
    try {
      const valuesString = substituteVariables(nodeData.values, params);
      values = JSON.parse(valuesString);
    } catch (e) {
      throw new Error("Invalid values format. Must be valid JSON array.");
    }

    const response = await sheets.spreadsheets.values.update({
      spreadsheetId,
      range,
      valueInputOption: "RAW",
      resource: { values },
    });

    return {
      success: true,
      action: "writeSheet",
      updatedCells: response.data.updatedCells,
      updatedRows: response.data.updatedRows,
      spreadsheetId,
      range,
    };
  } else if (action === "readSheet") {
    const response = await sheets.spreadsheets.values.get({
      spreadsheetId,
      range,
    });

    return {
      success: true,
      action: "readSheet",
      values: response.data.values || [],
      range: response.data.range,
      spreadsheetId,
    };
  }

  throw new Error(`Unsupported sheets action: ${action}`);
}

async function handleCalendarOperation(jwtClient, nodeData, params) {
  const calendar = google.calendar({ version: "v3", auth: jwtClient });

  const calendarId = substituteVariables(
    nodeData.calendarId || "primary",
    params
  );
  const eventTitle = substituteVariables(nodeData.eventTitle, params);
  const eventDate = substituteVariables(nodeData.eventDate, params);
  const eventDescription = substituteVariables(
    nodeData.eventDescription || "",
    params
  );

  if (!eventTitle || !eventDate) {
    throw new Error("Event title and date are required");
  }

  // Parse the date - assuming ISO format or simple date
  let startDateTime, endDateTime;
  try {
    const date = new Date(eventDate);
    startDateTime = date.toISOString();
    // Default to 1 hour duration
    endDateTime = new Date(date.getTime() + 60 * 60 * 1000).toISOString();
  } catch (e) {
    throw new Error(
      "Invalid date format. Use ISO format like: 2024-12-25T10:00:00"
    );
  }

  const event = {
    summary: eventTitle,
    description: eventDescription,
    start: {
      dateTime: startDateTime,
      timeZone: "UTC",
    },
    end: {
      dateTime: endDateTime,
      timeZone: "UTC",
    },
  };

  const response = await calendar.events.insert({
    calendarId,
    resource: event,
  });

  return {
    success: true,
    action: "createEvent",
    eventId: response.data.id,
    eventLink: response.data.htmlLink,
    calendarId,
    eventTitle,
    eventDate: startDateTime,
  };
}

async function sendWhatsappFunc(params) {
  // console.log({ sendWhatsappParams: JSON.stringify(params) });
  try {
    const nodeData = params.currentNode.data || params.currentNode;

    // Substitute variables in all fields
    const baseUrl = substituteVariables(
      nodeData.baseUrl || "https://crm.oneoftheprojects.com",
      params
    );
    const fullUrl = `${baseUrl}/api/qr/rest/send_message`;
    const token = substituteVariables(nodeData.token || "", params);
    const from = substituteVariables(nodeData.from || "", params);
    const to = substituteVariables(nodeData.to || "", params);
    const messageType = nodeData.messageType || "text";

    const normalizeNumber = (num) => (num ? num.replace(/\D/g, "") : "");

    // Build the body based on messageType
    const body = {
      messageType,
      requestType: "POST", // Assuming POST for reliability
      token,
      from: normalizeNumber(from),
      to: normalizeNumber(to),
    };

    switch (messageType) {
      case "text":
        body.text = substituteVariables(nodeData.text || "", params);
        break;
      case "image":
        body.imageUrl = substituteVariables(nodeData.imageUrl || "", params);
        body.caption = substituteVariables(nodeData.imageCaption || "", params);
        break;
      case "video":
        body.videoUrl = substituteVariables(nodeData.videoUrl || "", params);
        body.caption = substituteVariables(nodeData.videoCaption || "", params);
        break;
      case "audio":
        body.aacUrl = substituteVariables(nodeData.aacUrl || "", params);
        break;
      case "document":
        body.docUrl = substituteVariables(nodeData.docUrl || "", params);
        body.caption = substituteVariables(nodeData.docCaption || "", params);
        break;
      case "location":
        body.lat = substituteVariables(nodeData.lat || "", params);
        body.long = substituteVariables(nodeData.long || "", params);
        body.title = substituteVariables(nodeData.locationTitle || "", params);
        break;
      default:
        throw new Error(`Unsupported message type: ${messageType}`);
    }

    // console.log(
    //   `Sending WhatsApp message to ${fullUrl} with body: ${JSON.stringify(
    //     body
    //   )}`
    // );

    const response = await axios.post(fullUrl, body, {
      headers: { "Content-Type": "application/json" },
      timeout: 10000, // Default timeout
    });

    return {
      success: response.data.success,
      message: response.data.message,
      data: response.data.data || {},
    };
  } catch (error) {
    console.error("WhatsApp API error:", error);
    return {
      success: false,
      error: error.message || "Unknown error",
      data: {},
    };
  }
}

async function hangupCallFunc(params) {
  const farewell = params.currentNode?.farewellMessage || "Goodbye!";

  return {
    instruct: "Hang up the call after saying the farewell message",
    data: {
      hangup: true,
      farewell: farewell,
    },
  };
}

async function sendSmsFunc(params) {
  // console.log({ sendSmsParams: params });

  try {
    const nodeData = params.currentNode.data || params.currentNode;
    const selectedDevice = nodeData.selectedDevice;

    if (!selectedDevice) {
      throw new Error("No Twilio device selected");
    }

    // Extract phone number and message with variable substitution
    const phoneNumber = substituteVariables(nodeData.phoneNumber || "", params);
    const message = substituteVariables(nodeData.message || "", params);

    if (!phoneNumber || !message) {
      throw new Error("Phone number and message are required");
    }

    // Validate phone number format (basic validation)
    const cleanPhoneNumber = phoneNumber.replace(/\D/g, "");
    if (cleanPhoneNumber.length < 10) {
      throw new Error("Invalid phone number format");
    }

    // Format phone number (add + if not present)
    const formattedPhoneNumber = phoneNumber.startsWith("+")
      ? phoneNumber
      : `+${cleanPhoneNumber}`;

    // console.log(
    //   `Sending SMS from ${selectedDevice.number} to ${formattedPhoneNumber}: ${message}`
    // );

    const twilioClient = twilio(selectedDevice.sid, selectedDevice.token);

    try {
      const twilioMessage = await twilioClient.messages.create({
        body: message,
        from: selectedDevice.number,
        to: formattedPhoneNumber,
      });

      return {
        success: true,
        messageId: twilioMessage.sid,
        status: twilioMessage.status,
        from: selectedDevice.number,
        to: formattedPhoneNumber,
        message: message,
        timestamp: new Date().toISOString(),
      };
    } catch (twilioError) {
      console.error("Twilio SMS error:", twilioError);
      return {
        success: false,
        error: twilioError.message || "Failed to send SMS via Twilio",
        code: twilioError.code || "TWILIO_ERROR",
      };
    }
  } catch (error) {
    console.error("SMS sending error:", error);
    return {
      success: false,
      error: error.message || "Unknown error occurred while sending SMS",
    };
  }
}

async function sendSmtpEmailFunc(params) {
  // console.log({ sendSmtpEmailParams: JSON.stringify(params) });

  try {
    const nodeData = params.currentNode.data || params.currentNode;

    // Substitute variables in all fields
    const smtpHost = substituteVariables(nodeData.smtpHost, params);
    const smtpPort =
      parseInt(substituteVariables(nodeData.smtpPort, params)) || 587;
    const smtpSecure = nodeData.smtpSecure; // Boolean, no substitution needed
    const smtpUser = substituteVariables(nodeData.smtpUser, params);
    const smtpPass = substituteVariables(nodeData.smtpPass, params);
    const fromEmail = substituteVariables(nodeData.fromEmail, params);
    const toEmail = substituteVariables(nodeData.toEmail, params);
    const emailSubject = substituteVariables(nodeData.emailSubject, params);
    const emailBody = substituteVariables(nodeData.emailBody, params);

    // Validate required fields
    if (
      !smtpHost ||
      !smtpUser ||
      !smtpPass ||
      !fromEmail ||
      !toEmail ||
      !emailSubject ||
      !emailBody
    ) {
      throw new Error("Missing required SMTP or email fields");
    }

    // Create Nodemailer transporter
    const transporter = nodemailer.createTransport({
      host: smtpHost,
      port: smtpPort,
      secure: smtpSecure, // true for 465, false for other ports
      auth: {
        user: smtpUser,
        pass: smtpPass,
      },
    });

    // Email options
    const mailOptions = {
      from: fromEmail,
      to: toEmail,
      subject: emailSubject,
      text: emailBody, // Plain text body (you can add html: for HTML support)
    };

    // Send email
    const info = await transporter.sendMail(mailOptions);
    // console.log("Email sent:", info.messageId);

    return {
      success: true,
      message: "Email sent successfully",
      messageId: info.messageId,
      response: info.response,
    };
  } catch (error) {
    console.error("SMTP Email error:", error);
    return {
      success: false,
      error: error.message || "Failed to send email",
    };
  }
}

async function playAudioFunc(params, ws, streamSid) {
  // Pass ws and streamSid
  // console.log({ playAudioParams: params });
  const audioUrl = params.currentNode?.audioUrl || "";

  if (!audioUrl) {
    return {
      success: false,
      msg: "No audio file uploaded",
    };
  }

  try {
    // Step 1: Download the MP3
    const response = await axios.get(audioUrl, { responseType: "arraybuffer" });
    const tempMp3Path = path.join(__dirname, "temp.mp3");
    fs.writeFileSync(tempMp3Path, Buffer.from(response.data));

    // Step 2: Convert MP3 to mu-law WAV (8000Hz, mono)
    const tempWavPath = path.join(__dirname, "temp.wav");
    await new Promise((resolve, reject) => {
      ffmpeg(tempMp3Path)
        .outputOptions([
          "-f wav", // WAV format
          "-acodec pcm_mulaw", // mu-law codec
          "-ar 8000", // 8000 Hz sample rate
          "-ac 1", // Mono channel
        ])
        .on("end", resolve)
        .on("error", reject)
        .save(tempWavPath);
    });

    // Step 3: Read WAV and get duration
    const fileReader = new wav.Reader();
    const wavStream = fs.createReadStream(tempWavPath).pipe(fileReader);
    let duration = 0;
    wavStream.on("format", (format) => {
      const byteRate =
        (format.sampleRate * format.channels * format.bitDepth) / 8;
      duration = fs.statSync(tempWavPath).size / byteRate;
    });

    // Step 4: Stream audio chunks to Twilio
    const chunkSize = 4096; // Adjust for smooth playback
    let offset = 0;
    const audioBuffer = fs.readFileSync(tempWavPath);

    return new Promise((resolve) => {
      const sendChunk = () => {
        if (offset >= audioBuffer.length) {
          // Cleanup temp files
          fs.unlinkSync(tempMp3Path);
          fs.unlinkSync(tempWavPath);
          resolve({
            success: true,
            msg: "Audio played successfully",
            data: { url: audioUrl, duration: Math.floor(duration) },
          });
          return;
        }

        const chunk = audioBuffer
          .slice(offset, offset + chunkSize)
          .toString("base64");
        const mediaEvent = {
          event: "media",
          streamSid: streamSid,
          media: { payload: chunk },
        };
        ws.send(JSON.stringify(mediaEvent));

        offset += chunkSize;
        setTimeout(sendChunk, 20); // ~20ms per chunk for realtime playback
      };

      sendChunk();
    });
  } catch (error) {
    console.error("Audio playback error:", error);
    return {
      success: false,
      msg: "Failed to play audio",
      error: error.message,
    };
  }
}

async function mysqlQueryFunc(params) {
  // console.log({ mysqlQueryParams: params });

  try {
    const nodeData = params.currentNode.data || params.currentNode;
    const {
      host,
      port,
      user,
      password,
      database,
      query: rawQuery,
      params: rawParams,
    } = nodeData;

    // Substitute variables in query and params
    const substitutedQuery = substituteVariables(rawQuery, params);
    const substitutedParams = rawParams.map((param) =>
      substituteVariables(param, params)
    );

    // Create connection
    const connection = await mysql.createConnection({
      host: host || "localhost",
      port: port || 3306,
      user: user || "root",
      password: password || "",
      database: database || "",
    });

    try {
      // Execute query with prepared statements
      const [rows, fields] = await connection.execute(
        substitutedQuery,
        substitutedParams
      );
      return {
        success: true,
        rowsAffected: rows.affectedRows || 0,
        data: rows,
        // fields: fields,
      };
    } finally {
      await connection.end();
    }
  } catch (error) {
    console.error("MySQL query error:", error);
    return {
      success: false,
      error: error.message || "Unknown error",
      data: [],
    };
  }
}

const functionRegistry = {
  // Add this to your functionRegistry object in voiceagent/functionRegistry.js
  callForward: async (params, ws, streamSid, callSid, device) => {
    // console.log(
    //   `📞 Processing call forward with params: ${JSON.stringify(params)}`
    // );

    try {
      const nodeData = params.currentNode.data || params.currentNode;
      const phoneNumber = nodeData.phoneNumber?.replace("+", "");

      if (!phoneNumber) {
        return {
          instruct: "Call forward failed - no phone number provided",
          data: {
            success: false,
            error: "Phone number is required",
          },
        };
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
            waitUrl="http://twimlets.com/holdmusic?Bucket=com.twilio.music.rock"
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

      return {
        instruct: "Call forward initiated successfully using conference bridge",
        data: {
          success: true,
          conferenceName: conferenceName,
          targetNumber: phoneNumber,
        },
      };
    } catch (error) {
      console.error("Conference transfer failed:", error);

      return {
        instruct: "Call forward failed - check error details",
        data: {
          success: false,
          error: error.message || "Unknown error",
        },
      };
    }
  },
  mysql_query: async (params) => {
    // console.log(
    //   `🗄️ Executing MySQL query with params: ${JSON.stringify(params)}`
    // );
    try {
      const result = await mysqlQueryFunc(params);
      return {
        instruct:
          "MySQL query completed. Check the response data for results or errors.",
        data: result,
      };
    } catch (error) {
      return {
        instruct: "MySQL query failed. Check the error details.",
        data: {
          success: false,
          error: error.message || "Unknown error",
          data: [],
        },
      };
    }
  },
  play_audio: async (params, ws, streamSid) => {
    // Pass ws and streamSid
    // console.log(`🎵 Playing audio with params: ${JSON.stringify(params)}`);
    try {
      const result = await playAudioFunc(params, ws, streamSid);
      return {
        instruct:
          "check the response if success or failed and act as per the response",
        data: result,
      };
    } catch (error) {
      return {
        instruct:
          "check the response if success or failed and act as per the response",
        data: { error: error.message || "Unknown error" },
      };
    }
  },
  send_smtp_email: async (params) => {
    // console.log(`📧 Sending SMTP email with params: ${JSON.stringify(params)}`);
    try {
      const result = await sendSmtpEmailFunc(params);
      return {
        instruct:
          "Check the response if success or failed and act as per the response",
        data: result,
      };
    } catch (error) {
      return {
        instruct:
          "Check the response if success or failed and act as per the response",
        data: { error: error.message || "Unknown error" },
      };
    }
  },
  send_sms: async (params) => {
    // console.log(`📱 Sending SMS with params: ${JSON.stringify(params)}`);
    try {
      const result = await sendSmsFunc(params);
      return {
        instruct:
          "SMS sending completed. Check the response data for success/failure status.",
        data: result,
      };
    } catch (error) {
      return {
        instruct: "SMS sending failed. Check the error details.",
        data: {
          success: false,
          error: error.message || "Unknown error",
        },
      };
    }
  },
  send_whatsapp: async (params) => {
    // console.log(
    //   `📱 Sending WhatsApp message with params: ${JSON.stringify(params)}`
    // );
    try {
      const result = await sendWhatsappFunc(params);
      return {
        instruct:
          "WhatsApp message sent. Check the response for success/failure.",
        data: result,
      };
    } catch (error) {
      return {
        instruct: "WhatsApp message failed. Check the error details.",
        data: {
          success: false,
          error: error.message || "Unknown error",
          data: {},
        },
      };
    }
  },
  hangup_call: async (params) => {
    // console.log(`📞 Hanging up call with params: ${JSON.stringify(params)}`);
    try {
      const result = await hangupCallFunc(params);
      return {
        instruct:
          "check the response if success or failed and act as per the response",
        data: result.data,
      };
    } catch (error) {
      return {
        instruct:
          "check the response if success or failed and act as per the response",
        data: { error: error.message || "Unknown error" },
      };
    }
  },
  google_services: async (params) => {
    // console.log(
    //   `🔧 Google Services operation with params: ${JSON.stringify(params)}`
    // );
    try {
      const result = await googleServicesFunc(params);
      return {
        instruct:
          "Google Services operation completed. Check the response data and status for success/failure.",
        data: result,
      };
    } catch (error) {
      return {
        instruct: "Google Services operation failed. Check the error details.",
        data: {
          success: false,
          error: error.message || "Unknown error",
          data: {},
        },
      };
    }
  },
  api_call: async (params) => {
    // console.log(`🌐 Making API call with params: ${JSON.stringify(params)}`);
    try {
      const result = await makeApiCallFunc(params);
      return {
        instruct:
          "API call completed. Check the response data and status for success/failure.",
        data: result,
      };
    } catch (error) {
      return {
        instruct: "API call failed. Check the error details.",
        data: {
          success: false,
          error: error.message || "Unknown error",
          data: {},
        },
      };
    }
  },
  send_message: async (params) => {
    // console.log(`📤 Sending message with params: ${JSON.stringify(params)}`);
    try {
      const result = await sendMessageFunc(params);
      // console.log({ result });
      return {
        instruct:
          "check the response if success or failed and act as per the response",
        data: result,
      };
    } catch (error) {
      console.log({ error });
      return {
        instruct:
          "check the response if success or failed and act as per the response",
        data: { error: error.message || "Unknown error" },
      };
    }
  },
  send_email: async (params) => {
    // console.log(`📧 Sending email with params: ${JSON.stringify(params)}`);
    try {
      const result = await sendEmailFunc(params);
      return {
        instruct:
          "check the response if success or failed and act as per the response",
        data: result,
      };
    } catch (error) {
      return {
        instruct:
          "check the response if success or failed and act as per the response",
        data: { error: error.message || "Unknown error" },
      };
    }
  },
};

module.exports = {
  functionRegistry,
  makeApiCallFunc,
  sendMessageFunc,
  sendEmailFunc,
  sendWhatsappFunc,
  sendSmsFunc,
  sendSmtpEmailFunc,
  mysqlQueryFunc,
};
