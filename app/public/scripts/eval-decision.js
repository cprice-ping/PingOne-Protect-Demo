function submitForm(){
  var formData = new FormData(document.getElementById('loginForm'))
  getRiskDecision(formData.get("inputEmail"))
}

// Perform Risk Eval on button click event
// This is a server-side call due to the P1 Protect request needing a Worker token
async function getRiskDecision(username) {
    console.log("getRiskDecision: ", username) 

    // External service to figure out the browser's ipAddress (v4)
    const ipAddress = await fetch("https://api.ipify.org?format=json").then(res => res.json()).catch(err => {console.log("Get IP Address Error: ", err); return {"ip": "127.0.0.1"} })

    // Ask SDK for current payload
    let sdkPayload = ""
    if (typeof _pingOneSignals === "function"){
      sdkPayload = await _pingOneSignals.getData()
    } else {
      console.log("Signals Payload not generated")
    }

    let body = { 
        "username" : username,
        "sdkPayload": sdkPayload,
        "ipAddress": ipAddress.ip
    } 
    
    // Pass payload to Server-side to perform the Risk Eval call
    // Server contains the P1 Worker secrets to make the Eval call
    fetch("/getRiskDecision", {
      headers: {
        "content-type": "application/json"
      },
      method: "post",
      body: JSON.stringify(body)
    })
    .then(res => res.json())
    .then(data => {
      document.getElementById("sdkPayload").innerText = sdkPayload
      document.getElementById("riskResult").innerHTML = "<pre>"+JSON.stringify(data.result, null, 2)+"</pre>"
      document.getElementById("riskDetails").innerHTML = "<pre>"+JSON.stringify(data, null, 2)+"</pre>"

      // Extract the Predictor Values
      const threatDetails = data.details

      const high = jsonPath(threatDetails,'$.[?(@.level === "HIGH")]')
      const medium = jsonPath(threatDetails,'$.[?(@.level === "MEDIUM")].type')
      const low = jsonPath(threatDetails,'$.[?(@.level === "LOW")].type')

      // Populate Tabs
      document.getElementById("predictorsHigh").innerHTML = "<pre>"+JSON.stringify(high, null, 2)+"</pre>"
      document.getElementById("predictorsMed").innerHTML = "<pre>"+JSON.stringify(medium, null, 2)+"</pre>"
      document.getElementById("predictorsLow").innerHTML = "<pre>"+JSON.stringify(low, null, 2)+"</pre>"

      showRiskResult()
    })
    .catch(err => console.log("getRiskDecision: ", err))
}

/* Below functions used to parse and display the Evaluation response */
function showRiskResult() {
  document.getElementById("cardPayload").classList.remove("d-none")
  
  document.getElementById("navResult").classList.add("active")
  document.getElementById("riskResult").classList.remove("d-none")
  document.getElementById("navHigh").classList.remove("d-none")
  document.getElementById("navMed").classList.remove("d-none")
  document.getElementById("navLow").classList.remove("d-none")
  
  document.getElementById("navDetails").classList.remove("active")
  document.getElementById("riskDetails").classList.add("d-none")
  
  document.getElementById("navHigh").classList.remove("active")
  document.getElementById("predictorsHigh").classList.add("d-none")
  
  document.getElementById("navMed").classList.remove("active")
  document.getElementById("predictorsMed").classList.add("d-none")
  
  document.getElementById("navLow").classList.remove("active")
  document.getElementById("predictorsLow").classList.add("d-none")
}

function showRiskDetails() {
  document.getElementById("navDetails").classList.add("active")
  document.getElementById("riskDetails").classList.remove("d-none")
  
  document.getElementById("navResult").classList.remove("active")
  document.getElementById("riskResult").classList.add("d-none")
  
  document.getElementById("navHigh").classList.remove("active")
  document.getElementById("predictorsHigh").classList.add("d-none")
  
  document.getElementById("navMed").classList.remove("active")
  document.getElementById("predictorsMed").classList.add("d-none")
  
  document.getElementById("navLow").classList.remove("active")
  document.getElementById("predictorsLow").classList.add("d-none")
}

function showHighResults() {
  document.getElementById("navHigh").classList.add("active")
  document.getElementById("predictorsHigh").classList.remove("d-none")
  
  document.getElementById("navResult").classList.remove("active")
  document.getElementById("riskResult").classList.add("d-none")
  
  document.getElementById("navDetails").classList.remove("active")
  document.getElementById("riskDetails").classList.add("d-none")
  
  document.getElementById("navMed").classList.remove("active")
  document.getElementById("predictorsMed").classList.add("d-none")
  
  document.getElementById("navLow").classList.remove("active")
  document.getElementById("predictorsLow").classList.add("d-none")
}

function showMedResults() {
  document.getElementById("navMed").classList.add("active")
  document.getElementById("predictorsMed").classList.remove("d-none")
  
  document.getElementById("navResult").classList.remove("active")
  document.getElementById("riskResult").classList.add("d-none")
  
  document.getElementById("navDetails").classList.remove("active")
  document.getElementById("riskDetails").classList.add("d-none")
  
  document.getElementById("navHigh").classList.remove("active")
  document.getElementById("predictorsHigh").classList.add("d-none")
  
  document.getElementById("navLow").classList.remove("active")
  document.getElementById("predictorsLow").classList.add("d-none")
}

function showLowResults() {
  document.getElementById("navLow").classList.add("active")
  document.getElementById("predictorsLow").classList.remove("d-none")
  
  document.getElementById("navResult").classList.remove("active")
  document.getElementById("riskResult").classList.add("d-none")
  
  document.getElementById("navDetails").classList.remove("active")
  document.getElementById("riskDetails").classList.add("d-none")
  
  document.getElementById("navHigh").classList.remove("active")
  document.getElementById("predictorsHigh").classList.add("d-none")
  
  document.getElementById("navMed").classList.remove("active")
  document.getElementById("predictorsMed").classList.add("d-none")
}