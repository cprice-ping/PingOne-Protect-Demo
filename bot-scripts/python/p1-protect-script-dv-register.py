# This script uses Chrome to automate accessing a website that is integrated with PingOne Protect
# Import base modules
import requests
import time
import json
import random
import math
# import UserAgent generator
from fake_useragent import UserAgent
# Import Selenium components
from selenium import webdriver
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains
# Import VPN
# from nordvpn_switcher import initialize_VPN,rotate_VPN,terminate_VPN

start_time = time.time()

# Get some random user data for Registration
getUser = requests.get('https://randomuser.me/api/?password=special,upper,lower,number&results=5')
userDetails = getUser.json()

options = Options()

# Options that hide that Chrome is under Selenium's control
options.add_argument("--disable-blink-features=AutomationControlled")
options.add_argument("--no-sandbox")
options.add_argument("--disable-web-security")
options.add_argument("--disable-xss-auditor")
# Uncomment this line to display the browser as the script runs
# options.add_argument('--headless')

options.add_experimental_option("excludeSwitches", ["enable-automation"])
options.add_experimental_option('useAutomationExtension', False)
##

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
        .move_to_element_with_offset(element, random.randint(0, 400), random.randint(0, 300))\
        .perform()
    # Click into the element
    element.click()
    
def noSimulateTyping(element, string):
     element.send_keys(string)

def startForm(userEmail):
    browser.delete_cookie("ST")
    browser.delete_cookie("ST-NO-SS")

    # Complete Email Form
    element = wait.until(EC.element_to_be_clickable((By.ID, 'username')))
    print("Attempting to register: ", userEmail, end='\n', flush=True)
    moveMouse(element)
    simulateTyping(element, userEmail)
    # noSimulateTyping(element, userEmail)
    element = wait.until(EC.element_to_be_clickable((By.ID, 'btnSignIn')))
    moveMouse(element)

def registerUser(userDetail):
    # Complete Registration Form
    element = wait.until(EC.element_to_be_clickable((By.ID, 'firstName')))
    moveMouse(element)
    # simulateTyping(element, userDetail['name']['first'])
    noSimulateTyping(element, userDetail['name']['first'])
    element = wait.until(EC.element_to_be_clickable((By.ID, 'lastName')))
    moveMouse(element)
    # simulateTyping(element, userDetails['name']['last'])
    noSimulateTyping(element, userDetail['name']['last'])
    element = wait.until(EC.element_to_be_clickable((By.ID, 'password')))
    moveMouse(element)
    simulateTyping(element, userDetail['login']['password'])
    # noSimulateTyping(element, userDetail['login']['password'])
    # simulateTyping(element, "2FederateM0re!")
    moveMouse(element)

    element = wait.until(EC.element_to_be_clickable((By.ID, 'submitBtn')))
    moveMouse(element)

def displayRiskDetails():
    element = wait.until(EC.presence_of_element_located((By.CLASS_NAME, 'reactSingularKey_messageTitleRow')))
    print(element.get_attribute("innerText"))

    element = wait.until(EC.presence_of_element_located((By.CLASS_NAME, 'reactSingularKey_messageTextArea2')))
    riskResult=json.loads(element.get_attribute("innerText"))
    print("newDevice: ", riskResult["newDevice"])
    print("botDetection: ", riskResult["botDetection"])
    print("suspiciousDevice: ", riskResult["suspiciousDevice"])
    print("userVelocityByIp: ", riskResult["userVelocityByIp"])
    print("ipVelocityByUser: ", riskResult["ipVelocityByUser"])
    # print("Recommended Action: ", )

# Script Starts here:
countLow = 0
countHigh = 0
countFail = 0

f = open("registeredUsers.json", "a")

for user in userDetails['results']:

    browser = webdriver.Chrome(options=options)
    wait = WebDriverWait(browser, 5)

    try:
        setUserAgent()
        browser.get('https://cprice-p1-protect.ping-devops.com/oidc.html')

        element = wait.until(EC.element_to_be_clickable((By.ID, 'loginButton')))
        # pause a moment for the JS listener to attach to the button
        time.sleep(0.3)
        moveMouse(element)

        # Switch the random.me email address to mailinator so that NewDevice emails can be seen
        userEmail = user['email'].replace("example.com", "mailinator.com")

        startForm(userEmail)

        # Check to see if we're on the Register page
        if wait.until(EC.presence_of_element_located((By.ID, 'header'))).text == "Create Your Profile":
            registerUser(user)

            try:
                if wait.until(EC.text_to_be_present_in_element_attribute((By.ID, 'id-token'), 'innerText', '{')):
                    print("User Registered Successfully")

                    # Store registered credential
                    registeredUser = {}
                    registeredUser['username'] = user['email']
                    registeredUser['password'] = user['login']['password']
                    f.write(json.dumps(registeredUser)+"\n")

                    # element = wait.until(EC.presence_of_element_located((By.ID, 'id-token')))
                    # id_token=json.loads(element.get_attribute("innerText"))
                    # print("Eval ID: ", id_token["evalId"])
                    browser.execute_script("localStorage.removeItem('oidc-client:response');")
                    countLow += 1
                else:
                    print("No ID Token found")
            except:
                displayRiskDetails()
                countHigh += 1

        else:
            print("Known User -- Logon")

    except Exception as e:
        print("DV Flow failed to execute")
        # print(f"The Error: {e}")
        browser.execute_script("localStorage.removeItem('oidc-client:response');")
        countFail += 1
    
    browser.quit

# Print results
print("HIGH: "+str(countHigh)+" | LOW: "+str(countLow)+" | Fail: "+str(countFail)+" ("+str(math.ceil(time.time()-start_time))+"s)")