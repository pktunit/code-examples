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

parser = argparse.ArgumentParser(description='Send email alert for Jira Tasks')
parser.add_argument('-d', nargs=1, default=0, type=int, required=True, help='look for items due in [days] days', metavar='[days]')
parser.add_argument('-a', nargs=1, default=0, type=str, required=False, help='only search for issues assigned to [username]', metavar='[username]')
args = parser.parse_args()
days = args.d[0]
duedate = (datetime.datetime.now() + datetime.timedelta(days=+days)).strftime('%Y-%m-%d')
me = "it@company.com"
msg = MIMEMultipart('alternative')
msg['Subject'] = "JIRA: ALERT"
msg['From'] = me
msg.add_header('reply-to', me)
msg.add_header('cc', me)

if args.a:
  jql = "duedate = " + duedate + " and status not in (Resolved, Closed, Done) and assignee = " + args.a[0]
else:
  jql = "duedate = " + duedate + " and status not in (Resolved, Closed, Done)"

arguments = {"jql":jql,"startAt":0,"maxResults":50,"fields":["key","summary","status","assignee"]}
url = 'https://godzilla.company.com/rest/api/2/search'
headers = {'Content-type': 'application/json', 'Content-length': len(arguments)}
resJson = requests.post(url, auth=HTTPBasicAuth('gojira', 'PASSWORD'), json=arguments, headers=headers, verify=True)
res = json.loads(resJson.text)
#check for errors
if 'errorMessages' in resJson.text:
  sys.exit(res['errorMessages'])

if res['total'] == 0:
  sys.exit('No items found')
#end check
for i in res['issues']:
  you = i['fields']['assignee']['emailAddress']
  msg['To'] = you
  message = """<html>
<head>
<style type="text/css">
body {{ font-family: Verdana, Arial, Sans-Serif; }}
</style>
  <body>
  <a href="https://godzilla.company.com/browse/{key}">{key}</a> is due in {days} days.
  <p>Summary: {summary}
  <br>Status: {status}
  <br>Due Date: {duedate}
</body></html>""".format(key=i['key'], days=days, summary=i['fields']['summary'], status=i['fields']['status']['name'], duedate=duedate)
  msg.attach(MIMEText(message, 'html'))
  s = smtplib.SMTP('mail.company.com')
  #s.sendmail(me, you, msg.as_string())
  s.quit
  print(message)
