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
from selenium.webdriver.common.action_chains import ActionChains

# Get some random user data for Registration
getUser = requests.get('https://randomuser.me/api/?password=special,upper,lower,number&results=20')
userDetails = getUser.json()

options = Options()

# Options that hide that Chrome is under Selenium's control
options.add_argument("--disable-blink-features=AutomationControlled")
options.add_argument("--no-sandbox")
options.add_argument("--disable-web-security")
options.add_argument("--disable-xss-auditor")
options.add_argument('--headless')

options.add_experimental_option("excludeSwitches", ["enable-automation"])
options.add_experimental_option('useAutomationExtension', False)

browser = webdriver.Chrome(options=options)

wait = WebDriverWait(browser, 10)

def setUserAgent():
    # Get new User-Agent
    ua = UserAgent()
    userAgent = ua.random
    # print("Requested UserAgent: ", userAgent)
    options.add_argument('user-agent={userAgent}')

    # Hide that Selenium is being used
    browser.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")
    browser.execute_cdp_cmd('Network.setUserAgentOverride', {"userAgent": userAgent})

def simulateTyping(element, string):
    for character in string:
        element.send_keys(character)
        delay = random.randint(0, 1000)/10000
        time.sleep(delay)

def moveMouse(element):
    ActionChains(browser)\
        .move_to_element_with_offset(element, random.randint(0, 200), random.randint(0, 100))\
        .perform()
    
def noSimulateTyping(element, string):
     element.send_keys(string)

def startForm(userEmail):
    # Complete Email Form
    element = wait.until(EC.element_to_be_clickable((By.ID, 'username')))
    print("Attempting to register: ", userEmail)
    moveMouse(element)
    simulateTyping(element, userEmail)
    # noSimulateTyping(element, userEmail)
    element = wait.until(EC.element_to_be_clickable((By.ID, 'btnSignIn')))
    moveMouse(element)
    element.click()
    # print("Continue button pressed")

def registerUser(userDetail):
    # Complete Registration Form
    element = wait.until(EC.element_to_be_clickable((By.ID, 'firstName')))
    moveMouse(element)
    # simulateTyping(element, userDetails['results'][0]['name']['first'])
    noSimulateTyping(element, userDetail['name']['first'])
    element = wait.until(EC.element_to_be_clickable((By.ID, 'lastName')))
    moveMouse(element)
    # simulateTyping(element, userDetails['results'][0]['name']['last'])
    noSimulateTyping(element, userDetail['name']['last'])
    element = wait.until(EC.element_to_be_clickable((By.ID, 'password')))
    moveMouse(element)
    # simulateTyping(element, 'botP@ssword1')
    noSimulateTyping(element, userDetail['login']['password'])
    moveMouse(element)
    browser.find_element(By.ID, 'submitBtn').click()

# Script Starts here:
countLow = 0
countHigh = 0
countFail = 0

for user in userDetails['results']:
    try:
        setUserAgent()
        browser.get('https://cprice-p1-protect.ping-devops.com/oidc.html')

        element = wait.until(EC.element_to_be_clickable((By.ID, 'loginButton')))
        # pause a moment for the JS listener to attach to the button
        time.sleep(0.3)
        moveMouse(element)
        element.click()
        # print("OIDC button pressed")

        startForm(user['email'])

        # Check to see if we're on the Register page
        if wait.until(EC.presence_of_element_located((By.ID, 'header'))).text == "Create Your Profile":
            # print("Unknown User -- Register")
            registerUser(user)

            try:
                if wait.until(EC.text_to_be_present_in_element_attribute((By.ID, 'id-token'), 'innerText', '{')):
                    # print("User Registered Successfully")

                    # element = wait.until(EC.presence_of_element_located((By.ID, 'id-token')))
                    # id_token=json.loads(element.get_attribute("innerText"))
                    # print("Eval ID: ", id_token["evalId"])
                    countLow += 1
                else:
                    print("No ID Token found")
            except:
                # element = wait.until(EC.presence_of_element_located((By.CLASS_NAME, 'reactSingularKey_messageTitleRow')))
                # print(element.get_attribute("innerText"))

                # element = wait.until(EC.presence_of_element_located((By.CLASS_NAME, 'reactSingularKey_messageTextArea2')))
                # riskResult=json.loads(element.get_attribute("innerText"))
                # print("New Device: ", riskResult["newDevice"])
                # print("Bot Predictor: ", riskResult["botDetection"])
                # print("Sus Device Predictor: ", riskResult["suspiciousDevice"])
                countHigh += 1

        else:
            print("Known User -- Logon")

        browser.close

    except Exception as e:
        # print("DV Flow failed to execute")
        # print(f"The Error: {e}")
        countFail += 1

# Print results
print("-----------------")
print("HIGH: "+str(countHigh)+" | LOW: "+str(countLow)+" | Fail: ", str(countFail))