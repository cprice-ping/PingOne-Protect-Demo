/* Script to initialize the Signals SDK and begin behavior collection */

function onPingOneSignalsReady(callback) {
  if (window['_pingOneSignalsReady']) {
    callback();
  } else {
    document.addEventListener('PingOneSignalsReadyEvent', callback);
  }
}

onPingOneSignalsReady(async function () {

  const runtimeDetails = await fetch("/getRuntimeDetails").then(res => res.json())

  _pingOneSignals.init({
    behavioralDataCollection: false
  })
  .then(function () {
    console.log("PingOne Signals initialized successfully");
  })
  .then(function (payload) {
    console.log("Payload created")
  })
  .catch(function (e) {
    console.error("SDK Init failed", e);
  });
});