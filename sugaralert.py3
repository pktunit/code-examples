#!/usr/local/bin/python3.4
#requirements:
#python 3.4 - https://www.python.org/download/releases/3.4.0/
#python requests - http://docs.python-requests.org/en/latest/

import argparse
import datetime
import json
import requests
import smtplib
import sys
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from requests.auth import HTTPBasicAuth

baseUrl = 'https://sugar.company.com/rest/v10'
parser = argparse.ArgumentParser(description='Send email alert for SugarCRM Tasks')
parser.add_argument('-d', nargs=1, default=0, type=int, required=True, help='look for items due in [days] days', metavar='[days]')
args = parser.parse_args()
days = args.d[0]
duedate = (datetime.datetime.now() + datetime.timedelta(days=+days)).strftime('%Y-%m-%d')
me = "it@company.com"
msg = MIMEMultipart('alternative')
msg['Subject'] = "SugarCRM: ALERT"
msg['From'] = me
msg.add_header('Reply-to', me)
msg.add_header('Cc', me)

url = baseUrl + '/oauth2/token'
headers = {'Content-type': 'application/json'}
oauth = {}
oauth['grant_type'] = "password"
oauth['client_id'] = "6FjfJYwiX9rYBNZPbYav"
oauth['client_secret'] = "SECRET"
oauth['username'] = "admin"
oauth['password'] = "PASSWORD"
oauth['platform'] = "base"

token = requests.post(url, json=oauth, headers=headers, verify=True)
if 'error' in token.text:
  sys.exit(token.text)
token = json.loads(token.text)
headers = {'Content-type': 'application/json', 'oauth-token': token['access_token']}
arguments = {"filter":[{"$and":[{"status":{"$not_equals":"Complete"}},{"date_due":duedate}]}],"max_num":50,"offset":0,"fields":"assigned_user_id,date_due,description,id,name,status","order_by":"date_due:DESC","favorites":False,"my_items":False}
url = baseUrl + '/Tasks/filter'
tasksJson = requests.post(url, json=arguments, headers=headers, verify=True)
tasks = json.loads(tasksJson.text)
#error checking
if 'errorMessages' in tasksJson.text:
  sys.exit(tasks['errorMessages'])
if tasks['records'] == 0:
  sys.exit('No items found')
#end error checking
for record in tasks['records']:
  url = baseUrl + '/Users/filter'
  arguments = {"filter":[{"id":record['assigned_user_id']}],"max_num":1,"offset":0,"fields":"email","favorites":False,"my_items":False}
  userJson = requests.get(url, json=arguments, headers=headers, verify=True)
  user = json.loads(userJson.text)
  you = user['records'][0]['email'][0]['email_address']
  msg['To'] = you
  message = """<html>
<head>
<style type="text/css">
body {{ font-family: Verdana, Arial, Sans-Serif; }}
</style>
<body>
  <a href="https://sugar.company.com/#Tasks/{id}">{name}</a> is due in {days} days.
  <p>Description: {desc}
  <br>Status: {status}
  <br>Due Date: {duedate}
</body></html>""".format(id=record['id'], name=record['name'], days=days, desc=record['description'], status=record['status'], duedate=duedate)
  msg.attach(MIMEText(message, 'html'))
  s = smtplib.SMTP('mail.company.com')
  #s.sendmail(me, you, msg.as_string())
  s.quit
  print(message)
