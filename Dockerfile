FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive
ENV ASTERISK_VERSION=22.4.1

RUN apt-get update && \
    apt-get install -y \
      build-essential \
      wget \
      curl \
      git \
      subversion \
      libedit-dev \
      uuid-dev \
      libxml2-dev \
      libsqlite3-dev \
      libjansson-dev \
      libssl-dev \
      libncurses5-dev \
      liblua5.2-dev \
      libunbound-dev \
      libiksemel-dev \
      libopus-dev \
      libsrtp2-dev \
      libspeexdsp-dev \
      libcurl4-openssl-dev \
      ca-certificates && \
    apt-get clean

# Téléchargement + extraction
RUN wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-${ASTERISK_VERSION}.tar.gz && \
    tar xzf asterisk-${ASTERISK_VERSION}.tar.gz && \
    rm asterisk-${ASTERISK_VERSION}.tar.gz

WORKDIR /asterisk-${ASTERISK_VERSION}

# MP3 support
RUN contrib/scripts/get_mp3_source.sh

# Configuration + compilation
RUN ./configure && \
    make menuselect.makeopts && \
    menuselect/menuselect --enable format_mp3 menuselect.makeopts && \
    make -j$(nproc) && \
    make install && \
    make samples && \
    make config

EXPOSE 5060/udp 5060/tcp 10000-10100/udp

CMD ["/usr/sbin/asterisk", "-f", "-U", "root"]
