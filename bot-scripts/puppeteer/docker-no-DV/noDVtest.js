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
   await p.goto('https://cprice-p1-protect.ping-devops.com/loginForm.html')
   console.log("timeout started")
   await p.waitForTimeout(6000)
   console.log("timeout ended")
   

   // generate random email
   var randomnumber = Math.floor(Math.random() * (99999 - 100 + 1)) + 100;
   console.log(randomnumber)
   var randomemail = "reminator" + randomnumber + "@example.com";
   console.log(randomemail)
   await p.waitForSelector('input[id="inputEmail"]');
   await p.type('input[id="inputEmail"]',randomemail)

   //put in password
   await p.waitForSelector('input[id="inputPassword"]');
   await p.type('input[id="inputPassword"]','12345678!')

   //click button
   await p.click('#submitLogin');
   console.log('button clicked');


   await p.waitForTimeout(5000)

   const n = await p.$("#riskResult")
    const text = await (await n.getProperty('textContent')).jsonValue()    
    console.log("Risk Result is: " + text)

    const n2 = await p.$("#predictorsHigh")
    const text2 = await (await n2.getProperty('textContent')).jsonValue()    
    console.log("Risk Result is: " + text2)

   await browser.close();



})

