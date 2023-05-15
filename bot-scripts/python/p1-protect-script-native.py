from selenium import webdriver
from selenium.webdriver.chrome.service import Service as ChromeService
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
import requests
import time
import json
from fake_useragent import UserAgent

options = Options()

# Get new User-Agent
ua = UserAgent()
userAgent = ua.random
print("Requested UserAgent: ", userAgent)
options.add_argument('user-agent={userAgent}')

options.add_argument("--disable-blink-features=AutomationControlled")
options.add_argument("--no-sandbox")
options.add_argument("--disable-web-security")
options.add_argument("--disable-xss-auditor")
options.add_argument('--headless')

options.add_experimental_option("excludeSwitches", ["enable-automation"])
options.add_experimental_option('useAutomationExtension', False)

browser = webdriver.Chrome(service=ChromeService(ChromeDriverManager().install()))
browser = webdriver.Chrome(options=options)

# Hide that Selenium is being used
browser.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")

# Chrome Only
browser.execute_cdp_cmd('Network.setUserAgentOverride', {"userAgent": userAgent})

# Get some random user data for Registration
getUser = requests.get('https://randomuser.me/api/')
userDetails = getUser.json()
userEmail = userDetails['results'][0]['email']
userPass = userDetails['results'][0]['login']['password']

wait = WebDriverWait(browser, 10)

# URL of where to run this bot
startUrl = "http://localhost:3000/loginForm.html"

# Get the web page and start the bot functions
browser.get(startUrl)

# Get user Agent with execute_script
print("Actual User agent:", browser.execute_script("return navigator.userAgent"))

def startForm(userEmail):
    # Complete Email Form
    element = wait.until(EC.element_to_be_clickable((By.ID, 'inputEmail')))
    print("Entering Email Address: ", userEmail)
    element.send_keys(userEmail)
    print("Entering Password")
    element = wait.until(EC.element_to_be_clickable((By.ID, 'inputPassword')))
    element.send_keys(userPass)
    # time.sleep(1)
    print("Submiting Login Form")
    element = wait.until(EC.element_to_be_clickable((By.ID, 'submitLogin')))
    element.click()

# Script Starts here:
print("Logon: "+userEmail)
startForm(userEmail)

# Capture and show the Risk Result
element = wait.until(EC.text_to_be_present_in_element_attribute((By.ID, 'riskDetails'), "innerHTML", "level"))
element = wait.until(EC.presence_of_element_located((By.ID, 'riskResult')))

# Output the Risk Decision Level
riskResult=json.loads(element.get_attribute("innerText"))
print("Risk Level: ", riskResult["level"])

# Output the HIGH Predictors
element = wait.until(EC.presence_of_element_located((By.ID, 'predictorsHigh')))
print("HIGH Predictors: ", element.get_attribute("innerText"))

browser.quit()