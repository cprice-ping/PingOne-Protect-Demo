# from pickle import FALSE
from selenium import webdriver
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.firefox.options import Options
# from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
import requests
import time

# Get some random user data for Registration
getUser = requests.get('https://randomuser.me/api/')
userDetails = getUser.json()
userEmail = userDetails['results'][0]['name']['first']+"."+userDetails['results'][0]['name']['last']+"@mailinator.com"

options = Options()
# options.add_argument('--headless')

browser = webdriver.Firefox(options=options)
# browser = webdriver.Chrome(options=options)
browser.get('https://cprice-p1-protect.ping-devops.com/oidc.html')

wait = WebDriverWait(browser, 10)

element = wait.until(EC.element_to_be_clickable((By.ID, 'loginButton')))
# pause a moment for the JS listener to attach to the button
time.sleep(0.6)
element.click()
print("OIDC button pressed")

def startForm(userEmail):
    # Complete Email Form
    element = wait.until(EC.element_to_be_clickable((By.ID, 'username')))
    print("Entering Email Address: ", userEmail)
    element.send_keys(userEmail)
    element = wait.until(EC.element_to_be_clickable((By.ID, 'btnSignIn')))
    element.click()
    print("Continue button pressed")

def registerUser(userDetails):
    # Complete Registration Form
    element = wait.until(EC.element_to_be_clickable((By.ID, 'firstName')))
    element.send_keys(userDetails['results'][0]['name']['first'])
    element = wait.until(EC.element_to_be_clickable((By.ID, 'lastName')))
    element.send_keys(userDetails['results'][0]['name']['last'])
    element = wait.until(EC.element_to_be_clickable((By.ID, 'password')))
    element.send_keys('botP@ssword12')
    browser.implicitly_wait(5)
    browser.find_element(By.ID, 'submitBtn').click()

# Script Starts here:
startForm(userEmail)

# Check to see if we're on the Register page
if wait.until(EC.presence_of_element_located((By.ID, 'header'))).text == "Create Your Profile":
    print("Unknown User -- Register")
    registerUser(userDetails)

    # Pause for 2s before logging on
    print("Pausing before logging on")
    browser.implicitly_wait(2)
    print("Logon: "+userEmail)
    startForm(userEmail)
else:
    print("Known User -- Logon")

