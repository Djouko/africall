require("dotenv").config();
const express = require("express");
const app = express();
const cors = require("cors");
const fileUpload = require("express-fileupload");
const path = require("path");
const expressWs = require("express-ws")(app);
const { startCampaignWorker } = require("./loops/campaign/betaCampaign");

// Middleware setup
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ limit: "10mb", extended: true }));
app.use(cors());
app.use(fileUpload());

// Routers
const userRoute = require("./routes/user");
app.use("/api/user", userRoute);

const webRoute = require("./routes/web");
app.use("/api/web", webRoute);

const adminRoute = require("./routes/admin");
app.use("/api/admin", adminRoute);

const callRoute = require("./routes/call");
app.use("/api/call", callRoute);

const phonebookRoute = require("./routes/phonebook");
app.use("/api/phonebook", phonebookRoute);

const messageRoute = require("./routes/message");
app.use("/api/message", messageRoute);

const chat_flowRoute = require("./routes/chatFlow");
app.use("/api/chat_flow", chat_flowRoute);

const ivrRoute = require("./routes/ivr");
app.use("/api/ivr", ivrRoute);

const callManager = require("./routes/callManager");
app.use("/api/call_manager", callManager);

const campaign = require("./routes/campaign");
app.use("/api/campaign", campaign);

const agent = require("./routes/agent");
app.use("/api/agent", agent);

const call_force = require("./routes/call_force");
app.use("/api/call_force", call_force);

const plan = require("./routes/plan");
app.use("/api/plan", plan);

const voiceAgentRoute = require("./routes/voiceAgentRoute");
app.use("/api/vagent_route", voiceAgentRoute);

const voiceAgentRouter = require("./routes/voiceAgent");
app.use("/api/vagent", voiceAgentRouter);

app.get("/health", (request, response) => {
  response.status(200).json({ status: "ok" });
});

// Serve static files
app.use(express.static(path.resolve(__dirname, "./client/public")));

app.get("*", (request, response) => {
  response.sendFile(path.resolve(__dirname, "./client/public", "index.html"));
});

// Start the server
const primaryPort = Number.parseInt(process.env.PORT || "3010", 10);
const host = process.env.HOST === "127.0.0.1" ? "0.0.0.0" : process.env.HOST || "0.0.0.0";
const extraPorts = (process.env.EXTRA_PORTS || "")
  .split(",")
  .map((port) => Number.parseInt(port.trim(), 10))
  .filter((port) => Number.isInteger(port) && port > 0 && port !== primaryPort);
const ports = [...new Set([primaryPort, ...extraPorts])];
let campaignWorkerStarted = false;

ports.forEach((port) => {
  app.listen(port, host, () => {
    console.log(`Whatsham server is running on ${host}:${port}`);

    if (!campaignWorkerStarted) {
      campaignWorkerStarted = true;
      setTimeout(() => {
        startCampaignWorker();
        // console.log("BULK BETA CAMPAIGN STARTED");
      }, 2000);
    }
  });
});
