FROM lsiobase/ffmpeg:bin as binstage
FROM linuxserver/sonarr
LABEL maintainer="mdhiggins <mdhiggins23@gmail.com>"

# Add files from binstage
COPY --from=binstage / /
ENV FFMPEG=/usr/local/bin/ffmpeg
ENV FFPROBE=/usrlocal/bin/ffprobe
# get python3 and git, and install python libraries
RUN \
  apt-get update && \
  apt-get install -y \
    git \
    wget \
    python3 \
    python3-pip \
	  i965-va-driver \
  	libexpat1 \
  	libgl1-mesa-dri \
  	libglib2.0-0 \
	  libgomp1 \
	  libharfbuzz0b \
	  libv4l-0 \
	  libx11-6 \
	  libxcb1 \
	  libxext6 \
	  libxml2 && \
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
# ffmpeg
  # wget https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz -O /tmp/ffmpeg.tar.xz && \
  # tar -xJf /tmp/ffmpeg.tar.xz -C /usr/local/bin --strip-components 1 && \
  # chgrp users /usr/local/bin/ffmpeg && \
  # chgrp users /usr/local/bin/ffprobe && \
  # chmod g+x /usr/local/bin/ffmpeg && \
  # chmod g+x /usr/local/bin/ffprobe && \
# cleanup
  apt-get purge --auto-remove -y && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

EXPOSE 8989
VOLUME ["/usr/local/bin/sma/sickbeard_mp4_automator/autoProcess.ini"]