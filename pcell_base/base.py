#!/bin/python3.10

import os
import subprocess
import math
from datetime import datetime
from datetime import date
import time
import pandas as pd
import xlwings as xw

def rmDup(inputlist = None):
    out = sorted(set(inputlist), key=inputlist.index)
    return out

def findAllFile(base):
    allfile = []
    for root, ds, fs in os.walk(base):
        for f in fs:
            fullname = os.path.join(root, f)
            allfile.append(fullname)
    return allfile

def createDir(dirPath):
    os.makedirs(dirPath, exist_ok=True)
    return dirPath

def getTime():
    now = datetime.now()
    ds_string = now.strftime("%Y-%m-%d %H:%M:%S")
    return ds_string

def getDate():
    today = date.today()
    dt_string = today.strftime("%Y-%m-%d")
    return dt_string

def run_shell_cmd(cmd):
    cmd_list = cmd.split(" ")
    result = subprocess.run(cmd_list, capture_output=True, text=True)
    output = result.stdout
    return output

def create_format_title(content = "", total_length = 50):
    content_length = len(content)
    fill_length = 10
    white_space_length1 = math.floor((total_length-2*fill_length-content_length)/2)
    white_space_length2 = math.ceil((total_length-2*fill_length-content_length)/2)
    out = "*"*fill_length + " "*white_space_length1 + content + " "*white_space_length2 + "*" * fill_length + "\n"
    return out

def replacePattern(template = "", pattern = {}):
    content = open(template, "r").read()
    for key, value in pattern.items():
        content = re.sub(r"[$]%s[$]"%(key), value, content)
    print(content)
    return content

def lsf_submit(cmd = None):
    id_pat = r"[<](\d+)[>]"
    out = subprocess.getoutput(cmd)
    jobid = re.findall(id_pat, out)
    return jobid[0]

def lsf_bjobs():
    out = subprocess.getoutput("bjobs")
    pat = r'\n(\d+)\b'
    m = re.findall(pat, out)
    return m

def wait_all_jobs(jobid = None, interval = 2, timeout = 10000):
    timeflag = 1
    checkflag = 1
    print(" --- waiting for jobs --- %s\n" %getTime())
    while timeflag and checkflag:
        checklist = []
        run_jobs = lsf_bjobs()
        for job in jobid:
            if job in run_jobs:
                checklist.append(job)
        timeout = timeout - 1
        checkflag = 0 if len(checklist) == 0 else 1
        timeflag = 0 if timeout == 0 else 1
        time.sleep(interval)
    print(" --- all jobs finished --- %s\n" %getTime())


def wirte_col(io, sheet, col, data = None):
    if os.path.isfile(io):
        wb = xw.Book(io)
    else:
        wb = xw.Book()

        if ininstance(sheet, str):
            sheet = wb.sheets[sheet]
        else:
            sheet = wb.sheets[0]
        sheet.range((1, col)).options(transpose = True).value = data
        wb.save(io)
        wb.app.quit()

def sum_drc(drc_file):
    out = []
    lines = open(drc_file, "r").readlines()
    for line in lines:
        pat = "^RULECHECK\s+(\S+)\s+\S+\s+TOTAL\s+Result\s+Count\s+[=]\s+(\d+).+"
        info = re.findall(pat, line)
        if info:
            if info[0][-1] != "0":
                export = "%-25s--%-5s"%(info[0][0], info[0][1])
                out.append(export)
    return out
