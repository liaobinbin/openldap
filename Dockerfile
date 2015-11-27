FROM debian:jessie

EXPOSE 389

RUN export DEBIAN_FRONTEND=noninteractive && \
    export LC_ALL=en_US.UTF-8 && \
    apt-get update && \
    apt-get install -y software-properties-common gnupg && \
    gpg --keyserver keys.gnupg.net --recv-keys E184859262B4981F && \
    gpg -a --export E184859262B4981F | apt-key add - && \
    add-apt-repository 'deb http://repos.fusiondirectory.org/debian-jessie jessie main' && \
    apt-get update && \
    apt-get install -y slapd ldap-utils dialog locales ldap-utils \
    fusiondirectory-schema fusiondirectory-plugin-mail-schema && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    dpkg-reconfigure locales

ENV LDAP_ORGANIZATION="The Company, INC" \
    LDAP_DOMAIN=example.com \
    LDAP_PASSWORD=changeme

COPY start.sh /start.sh

VOLUME /var/lib/ldap

ENTRYPOINT ["/start.sh"]
