#!/bin/sh

set -e

if [ ! -e /.setup ]; then
    echo "Setting up slapd config"

    cat << EOF | debconf-set-selections
slapd slapd/internal/generated_adminpw password ${LDAP_PASSWORD}
slapd slapd/internal/adminpw password ${LDAP_PASSWORD}
slapd slapd/password2 password ${LDAP_PASSWORD}
slapd slapd/password1 password ${LDAP_PASSWORD}
slapd slapd/domain string ${LDAP_DOMAIN}
slapd shared/organization string ${LDAP_ORGANIZATION}
slapd slapd/backend string HDB
slapd slapd/purge_database boolean true
slapd slapd/move_old_database boolean true
slapd slapd/allow_ldap_v2 boolean false
slapd slapd/no_configuration boolean false
slapd slapd/dump_database select when needed
EOF
    #slapd slapd/dump_database_destdir string /var/backups/slapd-VERSION

    dpkg-reconfigure -f noninteractive slapd

    echo "Prepare functiondirectory schemas"
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
