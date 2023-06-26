const pt = require('puppeteer');

//adding headless flag to false
pt.launch({headless:false}).then(async browser => {
   //browser new page
   const p = await browser.newPage();
     
   //launch URL
   await p.goto('https://cprice-p1-protect.ping-devops.com')

   //add a timeout for the page to load
   await p.waitForTimeout(6000)

   //click on Get Risk Decision button
   await p.click('#getRiskDecision');
   
   //print button click
   console.log('button clicked')

})

