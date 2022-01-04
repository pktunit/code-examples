#!/usr/bin/python
import datetime
import json
import smtplib
import sys
import urllib
import urllib2
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from optparse import OptionParser

user = False
baseUrl = 'https://sugar.company.com/rest/v10'
parser = OptionParser()
parser.add_option('-d', '--days', help='look for items due in [days] days', metavar='[days]')
parser.add_option('-a', '--assignee', help='only search for tasks assigned to [username]', metavar='[username]')
(options, args) = parser.parse_args()
days = int(options.days)
duedate = (datetime.datetime.now() + datetime.timedelta(days=+days)).strftime('%Y-%m-%d')
assignee = str(options.assignee)
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
oauth['client_secret'] = "JICFAWoyF7cIOo57ODef"
oauth['username'] = "admin"
oauth['password'] = "am1G472NGy1MrXTBTdMf"
oauth['platform'] = "api"

data = urllib.urlencode(oauth)
req = urllib2.Request(url, data)
response = urllib2.urlopen(req)
token = response.read()
if 'error' in token:
  sys.exit(token)
token = json.loads(token)
headers = {'oauth-token': token['access_token']}

def get_user(hint):
  if any(char.isdigit() for char in str(hint)):
    arguments = {"filter":[{"id":hint}],"max_num":1,"offset":0,"fields":"email,user_name","favorites":False,"my_items":False}
  else:
    arguments = {"filter":[{"user_name":hint}],"max_num":1,"offset":0,"fields":"email,user_name","favorites":False,"my_items":False}
  data = json.dumps(arguments)
  url = baseUrl + '/Users/filter'
  req = urllib2.Request(url, data, headers)
  response = urllib2.urlopen(req)
  userJson = response.read()
  user = json.loads(userJson)
  return(user)

if assignee == None or assignee == "None":
  arguments = {"filter":[{"$and":[{"status":{"$not_equals":"Complete"}},{"date_due":duedate}]}],"max_num":50,"offset":0,"fields":"assigned_user_id,date_due,description,id,name,status","order_by":"date_due:DESC","favorites":False,"my_items":False}
else:
  if user == False:
    user = get_user(assignee)
  if (len(user['records']) == 0):
    sys.exit('No items found')
  arguments = {"filter":[{"$and":[{"status":{"$not_equals":"Complete"}},{"date_due":duedate},{"assigned_user_id":user['records'][0]['id']}]}],"max_num":50,"offset":0,"fields":"assigned_user_id,date_due,description,id,name,status","order_by":"date_due:DESC","favorites":False,"my_items":False}
data = json.dumps(arguments)
url = baseUrl + '/Tasks/filter'
req = urllib2.Request(url, data, headers)
response = urllib2.urlopen(req)
tasksJson = response.read()
tasks = json.loads(tasksJson)

#error checking
if 'errorMessages' in tasksJson:
  sys.exit(tasks['errorMessages'])
if not tasks['records']:
  sys.exit('No items found')
#end error checking
for record in tasks['records']:
  user = get_user(record['assigned_user_id'])
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
  s = smtplib.SMTP('mailcluster.company.com')
  #s.sendmail(me, you, msg.as_string())
  s.quit
  print(message)
