# Official SMA container based on linuxserver/sonarr

Docker container for Sonarr that includes all FFMPEG and python requirements to run SMA with Sonarr.

## Version Tags

|Tag|Description|
|---|---|
|latest|Stable release from linuxserver/sonarr with FFMPEG compiled from linuxserver/ffmpeg|
|develop|Develop release from linuxserver/sonarr with FFMPEG compiled from linuxserver/ffmpeg|

## Usage

### docker-compose
~~~yml
services:
  sonarr:
    image: mdhiggins/sonarr-sma
    container_name: sonarr
    volumes:
      - /opt/appdata/sonarr:/config
      - /opt/appdata/sma:/usr/local/sma/config
      - /mnt/storage/tv:/tv
      - /mnt/storage/downloads:/downloads
    ports:
      - 8989:8989
    restart: always
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
~~~

### autoProcess.ini
- Mount autoProcess.ini containing directory to `/usr/local/sma/config` using volumes
 - Consider making this writable as new options will be auto written to the config as they are added
- Sonarr configuration options are read from `config.xml` inside the container and injected at runtime into `autoProcess.ini`
 - ffmpeg
 - ffprobe
 - host (read from environment variable or set to 127.0.0.1)
 - web_root
 - port
 - ssl

### Python Environment
The script installs all dependencies in a virtual environment, not the container/system level Python environment. In order to use the Python environment with the dependencies installed, please execute using `/usr/local/sma/venv/bin/python3`. Use this same Python executable if using manual.py

## Configuring Sonarr

###  Enable completed download handling
- Settings > Download Client > Completed Download Handling > Enable: Yes

### Add Custom Script
- Settings > Connect > + Add > Custom Script

|Parameter|Value|
|---|---|
|On Grab| No|
|On Download| Yes|
|On Upgrade| Yes|
|On Rename| No|
|Path|`/usr/local/sma/postSonarr.sh`|

**Make sure you're using the .sh file, no the .py file, the .sh file points to the appropriate virtual environment**

## Logs

Located at `/usr/local/sma/config/sma.log` inside the container and your mounted config folder

## Environment Variables
|Variable|Description|
|---|---|
|PUID|User ID|
|PGID|Group ID|
|HOST|Local IP address for callback requests, default `127.0.0.1`|
|SMA_PATH|`/usr/local/sma`|
|SMA_UPDATE|Default `false`. Set `true` to pull git update of SMA on restart|
|SMA_FFMPEG_URL|If provided, override linuxserver/ffmpeg with a static build provided by the URL|
|SMA_STRIP_COMPONENTS|Default `1`. Number of components to strip from your tar.xz file when extracting so that FFmpeg binaries land in `/usr/local/bin`|

## Hardware Acceleration
The default image is built with [linuxserver/ffmpeg](https://hub.docker.com/r/linuxserver/ffmpeg), which supports VAAPI, QSV, and NVEnc/NVDec.

For VAAPI/QSV, you need to mount the hardware device from `/dev/dri`. 

Nvidia GPU support requires the `nvidia` runtime, available by installing [nvidia-container-toolkit](https://github.com/NVIDIA/nvidia-container-toolkit).

### VAAPI docker-compose sample
~~~yml
services:
  sonarr:
    container_name: sonarr
    devices:
      - /dev/dri/renderD128:/dev/dri/renderD128
~~~

### NVIDIA / NVEnc  NVDec docker-compose sample
~~~yml
services:
  sonarr:
    container_name: sonarr
    runtime: nvidia
~~~
