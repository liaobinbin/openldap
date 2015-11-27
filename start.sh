#!/bin/sh

set -e

if [ ! -e /.setup ]; then
    echo "setting slapd config"
    echo "slapd shared/organization string $LDAP_ORGANIZATION" | debconf-set-selections
    echo "slapd slapd/domain string $LDAP_DOMAIN" | debconf-set-selections
    echo "slapd slapd/password1 password $LDAP_PASSWORD1" | debconf-set-selections
    echo "slapd slapd/password2 password $LDAP_PASSWORD2" | debconf-set-selections
    echo "slapd slapd/internal/generated_adminpw password $LDAP_GENERATED_ADMINPW" | debconf-set-selections
    echo "slapd slapd/internal/adminpw password $LDAP_ADMINPW" | debconf-set-selections

    echo "prepare slapd"
    (sleep 2;
        fusiondirectory-insert-schema;
        fusiondirectory-insert-schema --insert \
            /etc/ldap/schema/fusiondirectory/mail-fd.schema \
            /etc/ldap/schema/fusiondirectory/mail-fd-conf.schema \
            /etc/ldap/schema/fusiondirectory/systems-fd.schema \
            /etc/ldap/schema/fusiondirectory/service-fd.schema \
            /etc/ldap/schema/fusiondirectory/systems-fd-conf.schema
    ) &
    touch /.setup
fi

/usr/sbin/slapd -h 'ldap:/// ldapi:///' -u openldap -g openldap -d 0
