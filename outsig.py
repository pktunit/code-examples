#!/usr/bin/python

import errno
import fileinput
import shutil
import os

def mkdir(path):
  try:
    os.makedirs(path)
  except OSError as exception:
    if exception.errno != errno.EEXIST:
      raise 

username = raw_input("Username: ")
fullname = raw_input("Full Name (E.g. John Smith): ")
position = raw_input("Position: ")


dbase = "%s/Signatures/" % (username)
dsub = dbase + "%s@company.com_files/" % (username)
dhtm = dbase + "%s@company.com.htm" % (username)
drtf = dbase + "%s@company.com.rtf" % (username)
dtxt = dbase + "%s@company.com.txt" % (username)
dxml1 = dsub + "colorschememapping.xml"
dxml2 = dsub + "filelist.xml"
dthmx = dsub + "themedata.thmx"

sbase = "Signatures"
ssub = sbase + "/username@company.com_files"
shtm = sbase + "/username@company.com.htm"
srtf = sbase + "/username@company.com.rtf"
stxt = sbase + "/username@company.com.txt"
sxml1 = ssub + "/colorschememapping.xml"
sxml2 = ssub + "/filelist.xml"
sthmx = ssub + "/themedata.thmx"

mkdir(dsub)

shutil.copyfile(shtm, dhtm)
shutil.copyfile(srtf, drtf)
shutil.copyfile(stxt, dtxt)
shutil.copyfile(sxml1, dxml1)
shutil.copyfile(sxml2, dxml2)
shutil.copyfile(sthmx, dthmx)

templates = [dhtm, drtf, dtxt, dxml2]

for file in templates:
  for line in fileinput.input(file, inplace=True):
    line = line.replace("username", username)
    line = line.replace("fullname", fullname)
    line = line.replace("position", position)
    print(line)
