//const myCursor = require('ghost-cursor')
const puppeteer = require('puppeteer-extra')
//const {installMouseHelper} = require('./install-mouse-helper');

// Add stealth plugin and use defaults 
const pluginStealth = require('puppeteer-extra-plugin-stealth')

const stealth = pluginStealth()
const { executablePath } = require('puppeteer');



//stealth.enabledEvasions.delete('user-agent-override')
console.log(stealth.availableEvasions);
puppeteer.use(stealth)

/*
// Stealth plugins are just regular `puppeteer-extra` plugins and can be added as such
const UserAgentOverride = require('puppeteer-extra-plugin-stealth/evasions/user-agent-override')
// Define custom UA and locale
const ua = UserAgentOverride({
  userAgent: 'MyFunkyUA/1.0',
  locale: 'de-DE,de'
})
puppeteer.use(ua)
*/






puppeteer.launch({ headless: false, args: ['--no-sandbox', '--disable-blink-features=AutomationControlled', '--disable-web-security', '--disable-xss-auditor'], executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' }).then(async browser => {
  //browser new page

  //browser new page
  const p = await browser.newPage();

  await p.setBypassCSP(true);

  //launch URL
  await p.goto('https://cprice-p1-protect.ping-devops.com/oidc.html')
  console.log("timeout started")
  await p.waitForTimeout(6000)
  console.log("timeout ended")
  //await p.goto('http://localhost:3000/oidc.html')

  //const cursor = myCursor.createCursor(p)
  await p.click('#loginButton');
  console.log("clicked loginButton");
  await p.waitForTimeout(4000)

  await p.waitForSelector('input[id="username"]');

  // generate random email
  var randomnumber = Math.floor(Math.random() * (99999 - 100 + 1)) + 100;
  console.log(randomnumber)

  var randomemail = "remyremyremy" + randomnumber + "@example.com";
  console.log(randomemail)

  await p.type('input[id="username"]', randomemail)
  await p.click('#btnSignIn');
  console.log("clicked signIn");

  await p.waitForTimeout(4000)


  await p.waitForSelector('input[id="firstName"]');
  await p.type('input[id="firstName"]', 'Remy')
  console.log("put in first name");

  await p.waitForSelector('input[id="lastName"]');
  await p.type('input[id="lastName"]', 'BotTest')
  console.log("put in last name");

  await p.waitForSelector('input[id="password"]');
  await p.type('input[id="password"]', 'botP@ssword1')
  console.log("put in password");

  await p.click('#submitBtn');
  console.log("clicked submitRegistration");

  await p.waitForTimeout(6000)

  const n = await p.$("#access-token")
  //const t = await (await n.getProperty('textContent')).jsonValue()

  ///console.log(t);
  //console.log("SUCCESS WITH BOT")

  if (n) {
    const t = await (await n.getProperty('textContent')).jsonValue()
    console.log(t);
    console.log("SUCCESS WITH BOT")
  } else {
    const findResult = await p.$("[class='reactSingularKey_messageTextArea2 styles_messageTextArea2__35NkK ']")
    const text = await (await findResult.getProperty('textContent')).jsonValue()
    console.log(text)
  }


  await browser.close();



})

