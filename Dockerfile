ARG ffmpeg_source=jrottenberg/ffmpeg
ARG ffmpeg_tag=4.4-ubuntu
ARG sonarr_tag=latest
ARG extra_packages

FROM ${ffmpeg_source}:${ffmpeg_tag} as ffmpeg

RUN \
  mkdir -p /build

FROM ghcr.io/linuxserver/sonarr:${sonarr_tag}
LABEL maintainer="mdhiggins <mdhiggins23@gmail.com>"

# Add files from ffmpeg
COPY --from=ffmpeg /usr/local/ /usr/local/
COPY --from=ffmpeg /build /

ENV SMA_PATH /usr/local/sma
ENV SMA_RS Sonarr
ENV SMA_UPDATE false
ENV SMA_HWACCEL true

RUN \
  if [ -f /usr/bin/apt ]; then \
    apt-get update && \
    apt-get install -y \
      git \
      wget \
      python3 \
      python3-pip \
      python3-venv \
      ${extra_packages} && \
# cleanup
    apt-get purge --auto-remove -y && \
    apt-get clean && \
    rm -rf \
      /tmp/* \
      /var/lib/apt/lists/* \
      /var/tmp/*; \
  elif [ -f /sbin/apk ]; then \
    apk update && \
    apk add --no-cache \
      git \
      wget \
      python3 \
      py3-pip \
      py3-virtualenv \
      ${extra_packages} && \
# cleanup
    apk del --purge && \
    rm -rf \
      /root/.cache \
      /tmp/*; \
  fi && \
# make directory
  mkdir ${SMA_PATH} && \
  # download repo
  git config --global --add safe.directory ${SMA_PATH} && \
  git clone https://github.com/mdhiggins/sickbeard_mp4_automator.git ${SMA_PATH} && \
# install pip, venv, and set up a virtual self contained python environment
  python3 -m virtualenv ${SMA_PATH}/venv && \
  ${SMA_PATH}/venv/bin/pip install -r ${SMA_PATH}/setup/requirements.txt && \
# ffmpeg
  chgrp users /usr/local/bin/ffmpeg && \
  chgrp users /usr/local/bin/ffprobe && \
  chmod g+x /usr/local/bin/ffmpeg && \
  chmod g+x /usr/local/bin/ffprobe

EXPOSE 8989

VOLUME /config
VOLUME /usr/local/sma/config

# update.py sets FFMPEG/FFPROBE paths, updates API key and Sonarr/Radarr settings in autoProcess.ini
COPY extras/ ${SMA_PATH}/
COPY root/ /
