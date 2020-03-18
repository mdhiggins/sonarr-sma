FROM linuxserver/sonarr:preview
LABEL maintainer="mdhiggins <mdhiggins23@gmail.com>"

ENV SMA_PATH /usr/local/sma
ENV SMA_RS Sonarr
ENV SMA_UPDATE false

# get python3 and git, and install python libraries
RUN \
  apt-get update && \
  apt-get install -y \
    git \
    wget \
    python3 \
    python3-pip && \
# make directory
  mkdir ${SMA_PATH} && \
# download repo
  git clone https://github.com/mdhiggins/sickbeard_mp4_automator.git ${SMA_PATH} && \
# install pip, venv, and set up a virtual self contained python environment
  python3 -m pip install --user --upgrade pip && \
  python3 -m pip install --user virtualenv && \
  python3 -m virtualenv ${SMA_PATH}/venv && \
  ${SMA_PATH}/venv/bin/pip install -r ${SMA_PATH}/setup/requirements.txt && \
# ffmpeg
  wget https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz -O /tmp/ffmpeg.tar.xz && \
  tar -xJf /tmp/ffmpeg.tar.xz -C /usr/local/bin --strip-components 1 && \
  chgrp users /usr/local/bin/ffmpeg && \
  chgrp users /usr/local/bin/ffprobe && \
  chmod g+x /usr/local/bin/ffmpeg && \
  chmod g+x /usr/local/bin/ffprobe && \
# cleanup
  apt-get purge --auto-remove -y && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

EXPOSE 8989

VOLUME /config
VOLUME /usr/local/sma/config

# update.py sets FFMPEG/FFPROBE paths, updates API key and Sonarr/Radarr settings in autoProcess.ini
COPY extras/ ${SMA_PATH}/
COPY root/ /
