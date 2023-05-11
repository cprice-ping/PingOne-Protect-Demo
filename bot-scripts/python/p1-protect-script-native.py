# from pickle import FALSE
from selenium import webdriver
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
# from selenium.webdriver.firefox.options import Options
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
import requests
import time
import json

# Get some random user data for Registration
getUser = requests.get('https://randomuser.me/api/')
userDetails = getUser.json()
userEmail = userDetails['results'][0]['name']['first']+"."+userDetails['results'][0]['name']['last']+"@mailinator.com"

options = Options()
options.add_argument('--headless')

# browser = webdriver.Firefox(options=options)
browser = webdriver.Chrome(options=options)

wait = WebDriverWait(browser, 10)

# URL of where to run this bot
startUrl = "http://localhost:3000/loginForm.html"

# Get the web page and start the bot functions
browser.get(startUrl)

def startForm(userEmail):
    # Complete Email Form
    element = wait.until(EC.element_to_be_clickable((By.ID, 'inputEmail')))
    print("Entering Email Address: ", userEmail)
    element.send_keys(userEmail)
    print("Entering Password")
    element = wait.until(EC.element_to_be_clickable((By.ID, 'inputPassword')))
    element.send_keys('botP@ssword12')
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


