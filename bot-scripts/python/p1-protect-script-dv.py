# This script uses Chrome to automate accessing a website that is integrated with PingOne Protect
# Import base modules
import requests
import time
import json
import os
import random
# import UserAgent generator
from fake_useragent import UserAgent
# Import Selenium components
from selenium import webdriver
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By

# Get some random user data for Registration
getUser = requests.get('https://randomuser.me/api/')
userDetails = getUser.json()
userEmail = userDetails['results'][0]['email']
userPass = userDetails['results'][0]['login']['password']

options = Options()

# Options that hide that Chrome is under Selenium's control
options.add_argument("--disable-blink-features=AutomationControlled")
options.add_argument("--no-sandbox")
options.add_argument("--disable-web-security")
options.add_argument("--disable-xss-auditor")
options.add_argument('--headless')

options.add_experimental_option("excludeSwitches", ["enable-automation"])
options.add_experimental_option('useAutomationExtension', False)

# Get new User-Agent
ua = UserAgent()
userAgent = ua.random
print("Requested UserAgent: ", userAgent)
options.add_argument('user-agent={userAgent}')

browser = webdriver.Chrome(options=options)

# Hide that Selenium is being used
browser.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")
browser.execute_cdp_cmd('Network.setUserAgentOverride', {"userAgent": userAgent})

browser.get('https://cprice-p1-protect.ping-devops.com/oidc.html')

wait = WebDriverWait(browser, 10)

element = wait.until(EC.element_to_be_clickable((By.ID, 'loginButton')))
# pause a moment for the JS listener to attach to the button
time.sleep(0.3)
element.click()
print("OIDC button pressed")

def simulateTyping(element, string):
    for character in string:
        element.send_keys(character)
        delay = random.randint(0, 2000)/10000
        time.sleep(delay)

def startForm(userEmail):
    # Complete Email Form
    element = wait.until(EC.element_to_be_clickable((By.ID, 'username')))
    print("Entering Email Address: ", userEmail)
    simulateTyping(element, userEmail)
    element = wait.until(EC.element_to_be_clickable((By.ID, 'btnSignIn')))
    element.click()
    print("Continue button pressed")

def registerUser(userDetails):
    # Complete Registration Form
    element = wait.until(EC.element_to_be_clickable((By.ID, 'firstName')))
    simulateTyping(element, userDetails['results'][0]['name']['first'])
    element = wait.until(EC.element_to_be_clickable((By.ID, 'lastName')))
    simulateTyping(element, userDetails['results'][0]['name']['last'])
    element = wait.until(EC.element_to_be_clickable((By.ID, 'password')))
    simulateTyping(element, 'botP@ssword1')
    browser.find_element(By.ID, 'submitBtn').click()

# Script Starts here:
startForm(userEmail)

# Check to see if we're on the Register page
if wait.until(EC.presence_of_element_located((By.ID, 'header'))).text == "Create Your Profile":
    print("Unknown User -- Register")
    registerUser(userDetails)

    time.sleep(1)

    try:
        element = wait.until(EC.presence_of_element_located((By.ID, 'id-token')))
        print("User Registered Successfully")
        id_token=json.loads(element.get_attribute("innerText"))
        print("UserID: ", id_token["sub"])
    except:
        element = wait.until(EC.presence_of_element_located((By.CLASS_NAME, 'reactSingularKey_messageTitleRow')))
        print(element.get_attribute("innerText"))

        element = wait.until(EC.presence_of_element_located((By.CLASS_NAME, 'reactSingularKey_messageTextArea2')))
        riskResult=json.loads(element.get_attribute("innerText"))
        print("New Device: ", riskResult["newDevice"])
        print("Bot Predictor: ", riskResult["botDetection"])
        print("Sus Device Predictor: ", riskResult["suspiciousDevice"])

else:
    print("Known User -- Logon")

