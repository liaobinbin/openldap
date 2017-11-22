FROM debian:jessie

EXPOSE 389

VOLUME /var/lib/ldap

ENV SLAPD_VERSION=2.4.40+dfsg-1+deb8u2 \
    FUSIONDIRECTORY_DEB_PKG_VERSION=1.0.9.3-1 \
    LDAP_ORGANIZATION="The Company, INC" \
    LDAP_DOMAIN=example.com \
    LDAP_PASSWORD=changeme

RUN export DEBIAN_FRONTEND=noninteractive && \
    export LC_ALL=en_US.UTF-8 && \
    export LANG=C && \
    export LANGUAGE=C && \
    apt-get update && \
    apt-get install -y software-properties-common gnupg && \
    gpg --keyserver keys.gnupg.net --recv-keys E184859262B4981F && \
    gpg -a --export E184859262B4981F | apt-key add - && \
    add-apt-repository 'deb http://repos.fusiondirectory.org/fusiondirectory-releases/fusiondirectory-1.0.9/debian-jessie/ jessie main' && \
    apt-get update && \
    apt-get install -y slapd=${SLAPD_VERSION} ldap-utils dialog locales ldap-utils \
        fusiondirectory-schema=${FUSIONDIRECTORY_DEB_PKG_VERSION} \
        fusiondirectory-plugin-mail-schema=${FUSIONDIRECTORY_DEB_PKG_VERSION} && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    dpkg-reconfigure locales

RUN mv /etc/ldap /etc/ldap.dist

VOLUME /etc/ldap

COPY start.sh /start.sh

ENTRYPOINT ["/start.sh"]
