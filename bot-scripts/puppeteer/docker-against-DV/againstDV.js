const puppeteer = require('puppeteer-extra') 
 
// Add stealth plugin and use defaults 
const pluginStealth = require('puppeteer-extra-plugin-stealth')

const stealth = pluginStealth()
const {executablePath} = require('puppeteer'); 

console.log(stealth.availableEvasions);
puppeteer.use(stealth)


puppeteer.launch({ headless:true, args: ['--no-sandbox', '--disable-blink-features=AutomationControlled', '--disable-web-security', '--disable-xss-auditor'], executablePath: '/usr/bin/chromium-browser' }).then(async browser => {

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

   await p.type('input[id="username"]',randomemail)
   await p.click('#btnSignIn');
   console.log("clicked signIn");

   await p.waitForTimeout(4000)


   await p.waitForSelector('input[id="firstName"]');
   await p.type('input[id="firstName"]','Remy')
   console.log("put in first name");

   await p.waitForSelector('input[id="lastName"]');
   await p.type('input[id="lastName"]','BotTest')
   console.log("put in last name");

   await p.waitForSelector('input[id="password"]');
   await p.type('input[id="password"]','botP@ssword1')
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

