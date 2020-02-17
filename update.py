#!/usr/bin/env python

import os
import configparser
import xml.etree.ElementTree as ET

xml = "/config/config.xml"
autoProcess = "/usr/local/bin/sma/sickbeard_mp4_automator/autoProcess.ini"
sections = {"7878": "Radarr",
            "8989": "Sonarr"}


def main():
    if not os.path.isfile(xml):
        print("No Sonarr/Radarr config file found")
        return

    tree = ET.parse(xml)
    root = tree.getroot()
    port = root.find("Port").text
    apikey = root.find("ApiKey").text
    section = sections.get(port)

    ip = os.environ.get("HOST")
    ssl = os.environ.get("SSL")
    webroot = os.environ.get("WEBROOT")

    if not os.path.isfile(autoProcess):
        print("autoProcess.ini does not exist")
        return

    safeConfigParser = configparser.SafeConfigParser()
    safeConfigParser.read(autoProcess)
    safeConfigParser.set(section, "apikey", apikey)
    if ip:
        safeConfigParser.set(section, "host", ip)
    if ssl:
        safeConfigParser.set(section, "SSL", ssl)
    if webroot:
        safeConfigParser.set(section, "web_root", webroot)
    if port:
        safeConfigParser.set(section, "port", port)

    safeConfigParser.set("MP4", "ffmpeg", "/usr/local/bin/ffmpeg")
    safeConfigParser.set("MP4", "ffprobe", "/usr/local/bin/ffprobe")

    fp = open(autoProcess, "w")
    safeConfigParser.write(fp)
    fp.close()
    print("autoProcess.ini updated with API key for %s" % section)


if __name__ == '__main__':
    main()
