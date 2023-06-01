// NodeJS imports
import { fileURLToPath } from "url";
import path from "path";
import btoa from "btoa"
import * as dotenv from 'dotenv' // see https://github.com/motdotla/dotenv#how-do-i-use-dotenv-with-import
dotenv.config()

// External libraries
import Fastify from "fastify";
// import fetch from "node-fetch";

// Initialize variables that are no longer available by default in Modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Require the fastify framework and instantiate it
const fastify = Fastify({
  // Set this to true for detailed logging
  logger: false,
  ignoreTrailingSlash: true,
  trustProxy: true
});

// Setup our static files
fastify.register(import("@fastify/static"), {
  root: path.join(__dirname, "public"),
  prefix: "/" // optional: default '/'
});

// fastify-formbody lets us parse incoming forms
fastify.register(import("@fastify/formbody"));

// fastify-cookie lets us handle cookies
fastify.register(import("@fastify/cookie"));

// Run the server and report out to the logs
fastify.listen(
  { port: 3000, host: "0.0.0.0" },
  function (err, address) {
    if (err) {
      console.error(err);
      process.exit(1);
    }
    console.log(`Your app is listening on ${address}`);
  }
);

/******************************************
 * Client - Get Runtime Details
 * Endpoint to pass deployed environment data to the client
 *****************************************/
fastify.get("/getRuntimeDetails", (req, res) => {
    res.send({envId: process.env.ENVID, clientId: process.env.OIDCCLIENTID })
})

/******************************************
 * Client - Form Post
 * Endpoint for Form demo to Post into -- returns Eval Decision response
 *****************************************/
fastify.post("/postForm", (req, res) => {
  console.log("postForm: ", req)
  const username = req.body.username
  const ipAddress = req.body.ipAddress || req.headers['x-forwarded-for'].split(",")[0]
  const sdkpayload = req.body.sdkPayload

  getProtectDecision(ipAddress, sdkpayload, username, riskDetails => {
    res.send(riskDetails)
  })
})

/******************************************
* PingOne Risk - Evaluation request
******************************************/
fastify.all("/getRiskDecision", (req, res) => { 
    
  const userAgent = req.headers['user-agent']

  const username = req.body.username
  const ipAddress = req.body.ipAddress || req.headers['x-forwarded-for'].split(",")[0]
  const sdkpayload = req.body.sdkPayload
  
  // console.log("Protect Request: ", username)

  getProtectDecision(ipAddress, sdkpayload, username, userAgent, riskDetails => {
    res.send(riskDetails)
  })
})

/*****************************************
* Get decision from P1 Protect
*
* This call is on the Server-Side because it requires a P1 Worker token
*****************************************/
function getProtectDecision(ipAddress, sdkpayload, username, userAgent, cb){

  // Get P1 Worker Token
  getPingOneToken(pingOneToken => {
  
    // URL must match the Risk EnvID used to create the payload
    const url="https://api.pingone.com/v1/environments/"+process.env.ENVID+"/riskEvaluations"
    
    // Construct Risk headers
    const headers = {
        "Authorization": "Bearer "+pingOneToken,
        "Content-Type": "application/json"
      }
    
    // Construct Risk Eval body
    const body = {
      event: {
        "targetResource": { 
            "id": "Signals SDK demo",
            "name": "Signals SDK demo"
        },
        "ip": ipAddress,
        "userAgent": userAgent,
        "sdk": {
          "signals": {
              "data": sdkpayload // Signals SDK payload from Client
          }
        },
        "flow": { 
            "type": "AUTHENTICATION" 
        },
        "user": {
          "id": username, // if P1, send in the UserId and set `type` to PING_ONE
          "name": username, // This is displayed in Dashboard and Audit
          "type": "EXTERNAL"
        },
        "sharingType": "PRIVATE", 
        "origin": "P1_PROTECT_DEMO" 
      }
    }
    
    // Make the call to PingOne Risk
    fetch(url, {
      method: "POST",
      headers: headers,
      body: JSON.stringify(body)
    })
    .then(response => response.json())
    .then(data => {
        // console.log("Risk Response: ", data)
        const responseLog = {"userID": data.event.user.id, "level": data.result.level, "id": data.id }
        console.log(responseLog)
        cb(data)
    })
    .catch(err => {
        console.log("Error: ", err); 
        cb(err)
    })
  })
}
  
/**********************************************
* Get Worker token for P1 API call
***********************************************/
function getPingOneToken(cb) {
  const url="https://auth.pingone.com/"+process.env.ENVID+"/as/token"
  const basicAuth=btoa(process.env.WORKERID+":"+process.env.WORKERSECRET)

  var urlencoded = new URLSearchParams();
  urlencoded.append("grant_type", "client_credentials");

  fetch(url, {
      headers: {
          "Authorization":  "Basic "+basicAuth,
          "Content-Type": "application/x-www-form-urlencoded"
      },
      method: "POST",
      body: urlencoded
  })
      .then(res => res.json())
      .then(data => cb(data.access_token))
      .catch(err => console.log("P1 Token Error: ", err))
}