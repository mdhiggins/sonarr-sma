ARG ffmpeg_tag=4.2-ubuntu
FROM jrottenberg/ffmpeg:${ffmpeg_tag} as ffmpeg
FROM linuxserver/sonarr
LABEL maintainer="mdhiggins <mdhiggins23@gmail.com>"

# Add files from ffmpeg
COPY --from=ffmpeg /usr/local/ /usr/local/

# get python3 and git, and install python libraries
RUN \
  apt-get update && \
  apt-get install -y \
    git \
    wget \
    python3 \
    python3-pip && \
# install pip, venv, and set up a virtual self contained python environment
  python3 -m pip install --user --upgrade pip && \
  python3 -m pip install --user virtualenv && \
  mkdir /usr/local/bin/sma && \
  python3 -m virtualenv /usr/local/bin/sma/env && \
  /usr/local/bin/sma/env/bin/pip install requests \
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
# download repo
  git clone https://github.com/mdhiggins/sickbeard_mp4_automator.git /usr/local/bin/sma/sickbeard_mp4_automator && \
# create logging directory
  mkdir /var/log/sickbeard_mp4_automator && \
  touch /var/log/sickbeard_mp4_automator/index.log && \
  chgrp -R users /var/log/sickbeard_mp4_automator && \
  chmod -R g+w /var/log/sickbeard_mp4_automator && \
# cleanup
  apt-get purge --auto-remove -y && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# update.py sets FFMPEG/FFPROBE paths, updates API key and Sonarr/Radarr settings in autoProcess.ini
ADD update.py /usr/local/bin/sma/update.py
CMD /usr/local/bin/sma/env/bin/python3 /usr/local/bin/sma/update.py

EXPOSE 8989
VOLUME ["/usr/local/bin/sma/sickbeard_mp4_automator/autoProcess.ini"]