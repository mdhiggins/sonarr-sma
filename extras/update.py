#!/usr/bin/env python

import os
import sys
import logging
import configparser
import xml.etree.ElementTree as ET
from resources.readsettings import ReadSettings

xml = "/config/config.xml"
autoProcess = os.path.join(os.environ.get("SMA_PATH", "/usr/local/sma"), "config/autoProcess.ini")


def main():
    # Ensure a valid config file
    ReadSettings()

    if not os.path.isfile(autoProcess):
        logging.error("autoProcess.ini does not exist")
        sys.exit(1)

    safeConfigParser = configparser.ConfigParser()
    safeConfigParser.read(autoProcess)

    # Set FFMPEG/FFProbe Paths
    safeConfigParser.set("Converter", "ffmpeg", "ffmpeg")
    safeConfigParser.set("Converter", "ffprobe", "ffprobe")

    section = os.environ.get("SMA_RS")
    if section and os.path.isfile(xml):
        tree = ET.parse(xml)
        root = tree.getroot()
        port = root.find("Port").text
        try:
            sslport = root.find("SslPort").text
        except:
            sslport = port
        webroot = root.find("UrlBase").text
        webroot = webroot if webroot else ""
        ssl = root.find("EnableSsl").text
        ssl = ssl.lower() in ["true", "yes", "t", "1", "y"] if ssl else False
        apikey = root.find("ApiKey").text

        # Set values from config.xml
        safeConfigParser.set(section, "apikey", apikey)
        safeConfigParser.set(section, "ssl", str(ssl))
        safeConfigParser.set(section, "port", sslport if ssl else port)
        safeConfigParser.set(section, "webroot", webroot)

        # Set IP from environment variable
        ip = os.environ.get("HOST")
        if ip:
            safeConfigParser.set(section, "host", ip)
        else:
            safeConfigParser.set(section, "host", "127.0.0.1")

    fp = open(autoProcess, "w")
    safeConfigParser.write(fp)
    fp.close()


if __name__ == '__main__':
    main()
