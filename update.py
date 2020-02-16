#!/usr/bin/env python

import sys
import os
import configparser
import xml.etree.ElementTree as ET

sections = {"7878": "Radarr",
            "8989": "Sonarr"}


def main():
    if len(sys.argv) < 5:
        print("Not enough arguments: %d" % len(sys.argv))
        print(sys.argv)
        sys.exit()

    xml = sys.argv[1].strip()
    if not os.path.isfile(xml):
        print("No Sonarr/Radarr config file found")

    tree = ET.parse(xml)
    root = tree.getroot()
    port = root.find("Port").text
    apikey = root.find("ApiKey").text
    section = sections.get(port)

    ip = os.environ.get("HOST")
    ssl = os.environ.get("SSL")
    webroot = os.environ.get("WEBROOT")

    autoProcess = sys.argv[2].strip()
    if not os.path.isfile(autoProcess):
        print("autoProcess.ini does not exist")
        sys.exit()

    option = sys.argv[3].strip()
    value = sys.argv[4].strip()

    safeConfigParser = configparser.SafeConfigParser()
    safeConfigParser.read(autoProcess)
    if not safeConfigParser.has_section(section):
        print("Section does not exist in autoProcess.ini")
        sys.exit()

    if not safeConfigParser.has_option(section, option):
        print("Option does not exist in autoProcess.ini")
        sys.exit()

    safeConfigParser.set(section, option, value)
    if ip:
        safeConfigParser.set(section, "host", ip)
    if ssl:
        safeConfigParser.set(section, "SSL", ssl)
    if webroot:
        safeConfigParser.set(section, "web_root", webroot)

    fp = open(autoProcess, "w")
    safeConfigParser.write(fp)
    fp.close()
    print("autoProcess.ini updated with API key for %s" % section)


if __name__ == '__main__':
    main()
