FROM debian:buster

# Arguments to instantiate as variables
ARG BASE_IMAGE
ARG BASE_IMAGE_TAG
ARG ARCH="amd64"
ARG PLATFORM="linux"
ARG TAG=""
ARG TAG_ROLLING=""
ARG BUILD_DATE=""
ARG IMAGE_VCS_REF=""
ARG VCS_REF=""
ARG FHEM_VERSION=""
ARG IMAGE_VERSION=""

# Custom build options:
#  Disable certain image layers using build env variables if desired
ARG IMAGE_LAYER_SYS_EXT
ARG IMAGE_LAYER_PERL_EXT
ARG IMAGE_LAYER_DEV
ARG IMAGE_LAYER_PERL_CPAN
ARG IMAGE_LAYER_PERL_CPAN_EXT
ARG IMAGE_LAYER_PYTHON
ARG IMAGE_LAYER_PYTHON_EXT
ARG IMAGE_LAYER_NODEJS
ARG IMAGE_LAYER_NODEJS_EXT

# Custom installation packages
ARG APT_PKGS
ARG CPAN_PKGS
ARG PIP_PKGS
ARG NPM_PKGS

# Re-usable variables during build
ARG L_AUTHORS="Julian Pawlowski (Forum.fhem.de:@loredo, Twitter:@loredo)"
ARG L_URL="https://hub.docker.com/r/fhem/fhem-${ARCH}_${PLATFORM}"
ARG L_USAGE="https://github.com/fhem/fhem-docker/blob/${IMAGE_VCS_REF}/README.md"
ARG L_VCS_URL="https://github.com/fhem/fhem-docker/"
ARG L_VENDOR="FHEM"
ARG L_LICENSES="MIT"
ARG L_TITLE="fhem-${ARCH}_${PLATFORM}"
ARG L_DESCR="A basic Docker image for FHEM house automation system, based on Debian Buster."

ARG L_AUTHORS_FHEM="https://fhem.de/MAINTAINER.txt"
ARG L_URL_FHEM="https://fhem.de/"
ARG L_USAGE_FHEM="https://fhem.de/#Documentation"
ARG L_VCS_URL_FHEM="https://svn.fhem.de/"
ARG L_VENDOR_FHEM="FHEM"
ARG L_LICENSES_FHEM="GPL-2.0"
ARG L_DESCR_FHEM="FHEM (TM) is a GPL'd perl server for house automation. It is used to automate some common tasks in the household like switching lamps / shutters / heating / etc. and to log events like temperature / humidity / power consumption."

# annotation labels according to
# https://github.com/opencontainers/image-spec/blob/v1.0.1/annotations.md#pre-defined-annotation-keys
LABEL org.opencontainers.image.created=${BUILD_DATE} \
   org.opencontainers.image.authors=${L_AUTHORS} \
   org.opencontainers.image.url=${L_URL} \
   org.opencontainers.image.documentation=${L_USAGE} \
   org.opencontainers.image.source=${L_VCS_URL} \
   org.opencontainers.image.version=${IMAGE_VERSION} \
   org.opencontainers.image.revision=${IMAGE_VCS_REF} \
   org.opencontainers.image.vendor=${L_VENDOR} \
   org.opencontainers.image.licenses=${L_LICENSES} \
   org.opencontainers.image.title=${L_TITLE} \
   org.opencontainers.image.description=${L_DESCR}

# non-standard labels
LABEL org.fhem.authors=${L_AUTHORS_FHEM} \
   org.fhem.url=${L_URL_FHEM} \
   org.fhem.documentation=${L_USAGE_FHEM} \
   org.fhem.source=${L_VCS_URL_FHEM} \
   org.fhem.version=${FHEM_VERSION} \
   org.fhem.revision=${VCS_REF} \
   org.fhem.vendor=${L_VENDOR_FHEM} \
   org.fhem.licenses=${L_LICENSES_FHEM} \
   org.fhem.description=${L_DESCR_FHEM}

ENV LANG=en_US.UTF-8 \
   LANGUAGE=en_US:en \
   LC_ADDRESS=de_DE.UTF-8 \
   LC_MEASUREMENT=de_DE.UTF-8 \
   LC_MESSAGES=en_DK.UTF-8 \
   LC_MONETARY=de_DE.UTF-8 \
   LC_NAME=de_DE.UTF-8 \
   LC_NUMERIC=de_DE.UTF-8 \
   LC_PAPER=de_DE.UTF-8 \
   LC_TELEPHONE=de_DE.UTF-8 \
   LC_TIME=de_DE.UTF-8 \
   TERM=xterm \
   TZ=Europe/Berlin

# Install base environment
COPY ./src/qemu-* /usr/bin/
COPY src/entry.sh /entry.sh
COPY src/ssh_known_hosts.txt /ssh_known_hosts.txt
COPY src/health-check.sh /health-check.sh
COPY src/find-* /usr/local/bin/
COPY src/99_DockerImageInfo.pm /fhem/FHEM/
RUN chmod 755 /*.sh /usr/local/bin/* \
    && echo "org.opencontainers.image.created=${BUILD_DATE}\norg.opencontainers.image.authors=${L_AUTHORS}\norg.opencontainers.image.url=${L_URL}\norg.opencontainers.image.documentation=${L_USAGE}\norg.opencontainers.image.source=${L_VCS_URL}\norg.opencontainers.image.version=${IMAGE_VERSION}\norg.opencontainers.image.revision=${IMAGE_VCS_REF}\norg.opencontainers.image.vendor=${L_VENDOR}\norg.opencontainers.image.licenses=${L_LICENSES}\norg.opencontainers.image.title=${L_TITLE}\norg.opencontainers.image.description=${L_DESCR}\norg.fhem.authors=${L_AUTHORS_FHEM}\norg.fhem.url=${L_URL_FHEM}\norg.fhem.documentation=${L_USAGE_FHEM}\norg.fhem.source=${L_VCS_URL_FHEM}\norg.fhem.version=${FHEM_VERSION}\norg.fhem.revision=${VCS_REF}\norg.fhem.vendor=${L_VENDOR_FHEM}\norg.fhem.licenses=${L_LICENSES_FHEM}\norg.fhem.description=${L_DESCR_FHEM}" > /image_info \
    && sed -i "s/buster main/buster main contrib non-free/g" /etc/apt/sources.list \
    && sed -i "s/buster-updates main/buster-updates main contrib non-free/g" /etc/apt/sources.list \
    && sed -i "s/buster\/updates main/buster\/updates main contrib non-free/g" /etc/apt/sources.list \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get update \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
        apt-transport-https \
        apt-utils \
        ca-certificates \
        gnupg \
        locales \
    && LC_ALL=C c_rehash \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get -qqy --no-install-recommends upgrade \
    \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
    && echo 'de_DE@euro ISO-8859-15\nde_DE ISO-8859-1\nde_DE.UTF-8 UTF-8\nen_DK ISO-8859-1\nen_DK.ISO-8859-15 ISO-8859-15\nen_DK.UTF-8 UTF-8\nen_GB ISO-8859-1\nen_GB.ISO-8859-15 ISO-8859-15\nen_GB.UTF-8 UTF-8\nen_IE ISO-8859-1\nen_IE.ISO-8859-15 ISO-8859-15\nen_IE.UTF-8 UTF-8\nen_US ISO-8859-1\nen_US.ISO-8859-15 ISO-8859-15\nen_US.UTF-8 UTF-8\nes_ES@euro ISO-8859-15\nes_ES ISO-8859-1\nes_ES.UTF-8 UTF-8\nfr_FR@euro ISO-8859-15\nfr_FR ISO-8859-1\nfr_FR.UTF-8 UTF-8\nit_IT@euro ISO-8859-15\nit_IT ISO-8859-1\nit_IT.UTF-8 UTF-8\nnl_NL@euro ISO-8859-15\nnl_NL ISO-8859-1\nnl_NL.UTF-8 UTF-8\npl_PL ISO-8859-2\npl_PL.UTF-8 UTF-8' >/etc/locale.gen \
    && LC_ALL=C locale-gen \
    \
    && ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
    && echo "Europe/Berlin" > /etc/timezone \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive dpkg-reconfigure tzdata \
    \
    && sed -i "s,http://deb.debian.org,https://cdn-aws.deb.debian.org,g" /etc/apt/sources.list \
    && sed -i "s,http://security.debian.org,https://cdn-aws.deb.debian.org,g" /etc/apt/sources.list \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get update \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
        adb \
        avahi-daemon \
        avrdude \
        bluez \
        curl \
        dnsutils \
        etherwake \
        fonts-liberation \
        git-core \
        i2c-tools \
        inetutils-ping \
        jq \
        libcap-ng-utils \
        libcap2-bin \
        lsb-release \
        mariadb-client \
        netcat \
        net-tools \
        openssh-client \
        procps \
        sendemail \
        sqlite3 \
        subversion \
        sudo \
        telnet \
        unzip \
        usbutils \
        wget \
        ${APT_PKGS} \
    && LC_ALL=C apt-get autoremove -qqy && LC_ALL=C apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.[^.] ~/.??* ~/*

# Add extended system layer
RUN if [ "${IMAGE_LAYER_SYS_EXT}" != "0" ]; then \
      LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get update \
      && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
          alsa-utils \
          dfu-programmer \
          ffmpeg \
          espeak \
          lame \
          libsox-fmt-all \
          libttspico-utils \
          mp3wrap \
          mpg123 \
          mplayer \
          nmap \
          normalize-audio \
          snmp \
          snmp-mibs-downloader \
          sox \
          vorbis-tools \
      && LC_ALL=C apt-get autoremove -qqy && LC_ALL=C apt-get clean \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.[^.] ~/.??* ~/* \
    ; fi

# Add Perl basic app layer for pre-compiled packages
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get update \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
        perl-base \
        libarchive-extract-perl \
        libarchive-zip-perl \
        libcgi-pm-perl \
        libcpanel-json-xs-perl \
        libdbd-mysql \
        libdbd-mysql-perl \
        libdbd-pg-perl \
        libdbd-sqlite3-perl \
        libdbi-perl \
        libdevice-serialport-perl \
        libdevice-usb-perl \
        libgd-graph-perl \
        libgd-text-perl \
        libimage-imlib2-perl \
        libimage-info-perl \
        libimage-librsvg-perl \
        libio-all-perl \
        libio-file-withpath-perl \
        libio-interface-perl \
        libio-socket-inet6-perl \
        libio-socket-ssl-perl \
        libjson-perl \
        libjson-pp-perl \
        libjson-xs-perl \
        liblist-moreutils-perl \
        libmail-gnupg-perl \
        libmail-imapclient-perl \
        libmail-sendmail-perl \
        libmime-base64-perl \
        libmime-lite-perl \
        libnet-server-perl \
        libsocket6-perl \
        libterm-readline-perl-perl \
        libtext-csv-perl \
        libtext-diff-perl \
        libtext-iconv-perl \
        libtimedate-perl \
        libutf8-all-perl \
        libwww-curl-perl \
        libwww-perl \
        libxml-libxml-perl \
        libxml-parser-lite-perl \
        libxml-parser-perl \
        libxml-simple-perl \
        libxml-stream-perl \
        libxml-treebuilder-perl \
        libxml-xpath-perl \
        libxml-xpathengine-perl \
        libyaml-libyaml-perl \
        libyaml-perl \
    && LC_ALL=C apt-get autoremove -qqy && LC_ALL=C apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.[^.] ~/.??* ~/*

# Add Perl extended app layer for pre-compiled packages
RUN if [ "${IMAGE_LAYER_PERL_EXT}" != "0" ]; then \
      LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get update \
      && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
          perl \
          libalgorithm-merge-perl \
          libauthen-*-perl \
          libclass-dbi-mysql-perl \
          libclass-isa-perl \
          libclass-loader-perl \
          libcommon-sense-perl \
          libconvert-base32-perl \
          libcpan-meta-yaml-perl \
          libcrypt-*-perl \
          libcryptx-perl \
          libdata-dump-perl \
          libdatetime-format-strptime-perl \
          libdatetime-perl \
          libdevel-size-perl \
          libdigest-*-perl \
          libdpkg-perl \
          libencode-perl \
          liberror-perl \
          libev-perl \
          libextutils-makemaker-cpanfile-perl \
          libfile-copy-recursive-perl \
          libfile-fcntllock-perl \
          libfinance-quote-perl \
          libgnupg-interface-perl \
          libhtml-strip-perl \
          libhtml-treebuilder-xpath-perl \
          libio-socket-*-perl \
          liblinux-inotify2-perl \
          libmath-round-perl \
          libmodule-pluggable-perl \
          libmojolicious-perl \
          libmoose-perl \
          libmoox-late-perl \
          libmp3-info-perl \
          libmp3-tag-perl \
          libnet-address-ip-local-perl \
          libnet-bonjour-perl \
          libnet-jabber-perl \
          libnet-oauth-perl \
          libnet-oauth2-perl \
          libnet-sip-perl \
          libnet-snmp-perl \
          libnet-ssleay-perl \
          libnet-telnet-perl \
          libnet-xmpp-perl \
          libnmap-parser-perl \
          librivescript-perl \
          librpc-xml-perl \
          libsnmp-perl \
          libsnmp-session-perl \
          libsoap-lite-perl \
          libsocket-perl \
          libswitch-perl \
          libsys-hostname-long-perl \
          libsys-statistics-linux-perl \
          libterm-readkey-perl \
          libterm-readline-perl-perl \
          libtime-period-perl \
          libtypes-path-tiny-perl \
          liburi-escape-xs-perl \
      && LC_ALL=C apt-get autoremove -qqy && LC_ALL=C apt-get clean \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.[^.] ~/.??* ~/* \
    ; fi

# Add development/compilation layer
RUN if [ "${IMAGE_LAYER_DEV}" != "0" ] || [ "${IMAGE_LAYER_PERL_CPAN}" != "0" ] || [ "${IMAGE_LAYER_PERL_CPAN_EXT}" != "0" ] || [ "${IMAGE_LAYER_PYTHON}" != "0" ] || [ "${IMAGE_LAYER_PYTHON_EXT}" != "0" ] || [ "${IMAGE_LAYER_NODEJS}" != "0" ] || [ "${IMAGE_LAYER_NODEJS_EXT}" != "0" ]; then \
      LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get update \
      && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
          autoconf \
          automake \
          build-essential \
          libavahi-compat-libdnssd-dev \
          libdb-dev \
          libsodium-dev \
          libssl-dev \
          libtool \
          libusb-1.0-0-dev \
          patch \
      && LC_ALL=C apt-get autoremove -qqy && LC_ALL=C apt-get clean \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.[^.] ~/.??* ~/* \
    ; fi

# Add Perl app layer for self-compiled modules
#  * exclude any ARM platforms due to long build time
#  * manually pre-compiled ARM packages may be applied here
RUN if [ "${CPAN_PKGS}" != "" ] || [ "${PIP_PKGS}" != "" ] || [ "${IMAGE_LAYER_PERL_CPAN}" != "0" ] || [ "${IMAGE_LAYER_PERL_CPAN_EXT}" != "0" ] || [ "${IMAGE_LAYER_PYTHON}" != "0" ] || [ "${IMAGE_LAYER_PYTHON_EXT}" != "0" ]; then \
      curl --retry 3 --retry-connrefused --retry-delay 2 -fsSL https://git.io/cpanm | perl - App::cpanminus \
      && cpanm --notest \
          App::cpanoutdated \
          CPAN::Plugin::Sysdeps \
          Perl::PrereqScanner::NotQuiteLite \
      && if [ "${CPAN_PKGS}" != "" ]; then \
          cpanm \
           ${CPAN_PKGS} \
         ; fi \
      && if [ "${IMAGE_LAYER_PERL_CPAN_EXT}" != "0" ]; then \
           if [ "${ARCH}" = "amd64" ] || [ "${ARCH}" = "i386" ]; then \
             cpanm --notest \
              Alien::Base::ModuleBuild \
              Alien::Sodium \
              Crypt::Argon2 \
              Crypt::NaCl::Sodium \
              Crypt::OpenSSL::AES \
              Device::SMBus \
              Net::MQTT::Constants \
              Net::MQTT::Simple \
              Net::WebSocket::Server \
             ; fi \
         ; fi \
      && rm -rf /root/.cpanm \
      && LC_ALL=C apt-get autoremove -qqy && LC_ALL=C apt-get clean \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.[^.] ~/.??* ~/* \
    ; fi

# Add Python app layer
RUN if [ "${PIP_PKGS}" != "" ] || [ "${IMAGE_LAYER_PYTHON}" != "0" ] || [ "${IMAGE_LAYER_PYTHON_EXT}" != "0" ]; then \
      LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get update \
      && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
          libinline-python-perl \
          python3 \
          python3-dev \
          python3-pip \
          python3-setuptools \
          python3-wheel \
      && if [ "${PIP_PKGS}" != "" ]; then \
           pip3 install \
            ${PIP_PKGS} \
         ; fi \
      && if [ "${IMAGE_LAYER_PYTHON_EXT}" != "0" ]; then \
           LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
            python3-pychromecast \
            speedtest-cli \
            youtube-dl \
           && ln -s ../../bin/speedtest-cli /usr/local/bin/speedtest-cli \
        ; fi \
      && rm -rf /root/.cpanm \
      && LC_ALL=C apt-get autoremove -qqy && LC_ALL=C apt-get clean \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.[^.] ~/.??* ~/* \
    ; fi

# Add nodejs app layer
RUN if ( [ "${NPM_PKGS}" != "" ] || [ "${IMAGE_LAYER_NODEJS}" != "0" ] || [ "${IMAGE_LAYER_NODEJS_EXT}" != "0" ] ) && [ "${ARCH}" != "arm32v5" ]; then \
      LC_ALL=C curl --retry 3 --retry-connrefused --retry-delay 2 -fsSL https://deb.nodesource.com/setup_10.x | LC_ALL=C bash - \
      && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
           nodejs \
      && if [ ! -e /usr/bin/npm ]; then \
           LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
             npm \
      ; fi \
      && npm install -g --unsafe-perm --production \
          npm \
      && if [ "${NPM_PKGS}" != "" ]; then \
          npm install -g --unsafe-perm --production \
           ${NPM_PKGS} \
         ; fi \
      && if [ "${IMAGE_LAYER_NODEJS_EXT}" != "0" ]; then \
           npm install -g --unsafe-perm --production \
            alexa-cookie2 \
            alexa-fhem \
            gassistant-fhem \
            homebridge \
            homebridge-fhem \
            tradfri-fhem \
        ; fi \
      && LC_ALL=C apt-get autoremove -qqy && LC_ALL=C apt-get clean \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.[^.] ~/.??* ~/* \
    ; fi

# Add FHEM app layer
# Note: Manual checkout is required if build is not run by Travis:
RUN  svn co https://svn.fhem.de/fhem/trunk /
#COPY ./src/fhem/trunk/fhem/ /fhem/
RUN chown `id -u`:`id -g` / /fhem

VOLUME [ "/opt/fhem" ]

EXPOSE 8083

#HEALTHCHECK --interval=20s --timeout=10s --start-period=60s --retries=5 CMD /health-check.sh

WORKDIR "/opt/fhem"
ENTRYPOINT [ "/entry.sh" ]
CMD [ "start" ]
