ARG ffmpeg_source=jrottenberg/ffmpeg
ARG ffmpeg_tag=4.4-ubuntu
ARG sonarr_tag=latest
ARG extra_packages

FROM ghcr.io/linuxserver/ffmpeg AS ffmpeg

FROM ghcr.io/linuxserver/sonarr AS sonarr
LABEL maintainer="mdhiggins <mdhiggins23@gmail.com>"

# copy ffmpeg executable from linuxserver
COPY --from=ffmpeg / /

ENV SMA_PATH /usr/local/sma
ENV SMA_RS Sonarr
ENV SMA_UPDATE false

RUN \
  # ubuntu
  if [ -f /usr/bin/apt ]; then \
    apt-get update && \
    apt-get install -y \
      git \
      wget \
      xz-utils \
      python3 \
      python3-pip \
      python3-venv \
      fonts-dejavu \
      ${extra_packages} && \
    # cleanup
    apt-get purge --auto-remove -y && \
    apt-get clean && \
    rm -rf \
      /tmp/* \
      /var/lib/apt/lists/* \
      /var/tmp/*; \
  # alpine
  elif [ -f /sbin/apk ]; then \
    apk update && \
    apk add --no-cache \
      git \
      wget \
      xz \
      python3 \
      py3-pip \
      ttf-dejavu \
      ${extra_packages} && \
    apk add --no-cache py3-pymediainfo --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community && \
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

EXPOSE 8989

VOLUME /config
VOLUME /usr/local/sma/config

# update.py sets FFMPEG/FFPROBE paths, updates API key and Sonarr/Radarr settings in autoProcess.ini
COPY extras/ ${SMA_PATH}/
COPY root/ /
