#!/usr/bin/env python3
#-*- coding: utf-8 -*-


import os
import time
import json
import pycurl
from io import BytesIO
from src.file import io


####### settings session #########
login = 'api'
passwd = 'yL8bXCf3eymvLN_new'
url = 'http://fl.tlnt.iptvapi.net:8080'
url_streams = '/flussonic/api/v3/streams?limit=1000'
fileexport = '/opt/API/streams.list'
##################################
json_streams = ''
streams = []
threads_count = 1000

def get_streams():
    global json_streams
    js = ''
    header = ['Accept: application/xml']
    try:
        js = BytesIO()
        c = pycurl.Curl()
        c.setopt(c.URL, url+url_streams)
        c.setopt(c.HTTPHEADER, header)
        c.setopt(c.VERBOSE, 0)
        c.setopt(c.USERPWD, login + ':' + passwd)
        c.setopt(c.WRITEFUNCTION, js.write)
        c.perform()
        c.close()
        json_streams = json.loads(js.getvalue())
        result = True
    except:
        result = False

    return result


def parse_streams():
    global json_streams
    global streams
    total_count = 0

    for stream in json_streams["streams"]:

        #print(f'{stream}\n')
        #print(stream["inputs"]["stats"]["media_info"]["tracks"])
        try:
            name = stream["name"]
        except:
            name = False

        try:
            alive = stream["stats"]["alive"]
        except:
            alive = False

        try:
            running = stream["stats"]["running"]
        except:
            running = False

        try:
            dvr = stream["stats"]["dvr_enabled"]
        except:
            dvr = False

        try:
            ts_delay = stream["stats"]["ts_delay"]
            if int(ts_delay)>1000 * 10:
                ts_delay = True
        except:
            ts_delay = False

        if name and alive and running and dvr and ts_delay:
            streams.append(name)

        total_count += 1
    print(f'Streams parsed!\n Total streams: {total_count}\n Working streams: {len(streams) }')


def main():
    file = io()

    result = get_streams()
    if result:
        parse_streams()
        file.rewriteto(fileexport, streams)

if __name__ == '__main__':
    os.system('clear')
    main()


