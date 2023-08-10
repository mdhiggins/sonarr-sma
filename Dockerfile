FROM ghcr.io/linuxserver/ffmpeg AS ffmpeg

FROM ghcr.io/linuxserver/sonarr AS sonarr

LABEL maintainer="mdhiggins <mdhiggins23@gmail.com>"

# copy ffmpeg executable from linuxserver
COPY --from=ffmpeg / /

ENV SMA_PATH /usr/local/sma
ENV SMA_RS Sonarr
ENV SMA_UPDATE false

RUN \
  # get git
  apt-get update && \
  apt-get install -y git && \
  # make directory
  mkdir ${SMA_PATH} && \
  # download repo
  git config --global --add safe.directory ${SMA_PATH} && \
  git clone https://github.com/mdhiggins/sickbeard_mp4_automator.git ${SMA_PATH} && \
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
