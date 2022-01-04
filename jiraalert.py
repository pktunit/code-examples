#!/usr/bin/python
import base64
import datetime
import json
import smtplib
import sys
import urllib
import urllib2
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from optparse import OptionParser

credentials = base64.b64encode("gojira:PASSWORD")
baseUrl = 'https://godzilla.company.com'
parser = OptionParser()
parser.add_option('-d', '--days', help='look for items due in [days] days', metavar='[days]')
parser.add_option('-a', '--assignee', help='only search for tasks assigned to [username]', metavar='[username]')
(options, args) = parser.parse_args()
days = int(options.days)
duedate = (datetime.datetime.now() + datetime.timedelta(days=+days)).strftime('%Y-%m-%d')
me = "it@company.com"
msg = MIMEMultipart('alternative')
msg['Subject'] = "JIRA: ALERT"
msg['From'] = me
msg.add_header('Reply-to', me)
msg.add_header('Cc', me)

if options.assignee:
  jql = "duedate = " + duedate + " and status not in (Resolved, Closed, Done) and assignee = " + options.assignee
else:
  jql = "duedate = " + duedate + " and status not in (Resolved, Closed, Done)"

arguments = {"jql":jql,"startAt":0,"maxResults":50,"fields":["key","summary","status","assignee"]}
data = json.dumps(arguments)
headers = {'Content-type': 'application/json', 'Context-length': len(data)}
url = baseUrl + '/rest/api/2/search'
req = urllib2.Request(url, data, headers)
req.add_header('Authorization', 'Basic ' + credentials)
response = urllib2.urlopen(req)
resJson = response.read()
res = json.loads(resJson)
#check for errors
if 'errorMessages' in resJson:
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
  s = smtplib.SMTP('mailcluster.company.com')
  #s.sendmail(me, you, msg.as_string())
  s.quit
  print(message)
