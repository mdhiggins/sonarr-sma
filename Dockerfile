FROM linuxserver/sonarr:preview
LABEL maintainer="mdhiggins <mdhiggins23@gmail.com>"

ENV SMAPATH /usr/local/sma

# get python3 and git, and install python libraries
RUN \
  apt-get update && \
  apt-get install -y \
    git \
    wget \
    python3 \
    python3-pip && \
# make directory
  mkdir ${SMAPATH} && \
# download repo
  git clone https://github.com/mdhiggins/sickbeard_mp4_automator.git ${SMAPATH} && \
# create logging directory
  mkdir -p /var/log/sickbeard_mp4_automator && \
  touch /var/log/sickbeard_mp4_automator/index.log && \
  chown -R ${PUID}:${PGID} /var/log/sickbeard_mp4_automator && \
  chmod -R 664 /var/log/sickbeard_mp4_automator && \
# install pip, venv, and set up a virtual self contained python environment
  python3 -m pip install --user --upgrade pip && \
  python3 -m pip install --user virtualenv && \
  python3 -m virtualenv ${SMAPATH}/env && \
  ${SMAPATH}/env/bin/pip install requests \
    requests[security] \
    requests-cache \
    babelfish \
    tmdbsimple \
    guessit \
    mutagen \
    subliminal \
    stevedore \
    python-dateutil \
    setuptools \
    qtfaststart && \
# ffmpeg
  wget https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz -O /tmp/ffmpeg.tar.xz && \
  tar -xJf /tmp/ffmpeg.tar.xz -C /usr/local/bin --strip-components 1 && \
  chown ${PUID}:${PGID} /usr/local/bin/ff* && \
  chmod 755 /usr/local/bin/ff* && \
# cleanup
  apt-get purge --auto-remove -y && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

EXPOSE 8989

VOLUME /config

# update.py sets FFMPEG/FFPROBE paths, updates API key and Sonarr/Radarr settings in autoProcess.ini
ADD update.py ${SMAPATH}/update.py
ADD postSonarr.sh ${SMAPATH}/postSonarr.sh
ADD sma-config /etc/cont-init.d/98-sma-config

RUN \
  chown -R ${PUID}:${PGID} ${SMAPATH} && \
  chmod -R 755 ${SMAPATH}
