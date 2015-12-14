#!/bin/sh

set -e

if [ ! -e /var/lib/ldap/.setup ]; then
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

    echo "Reconfigure"
    dpkg-reconfigure -f noninteractive slapd

    (sleep 4;
        echo "Prepare functiondirectory schemas"
        fusiondirectory-insert-schema;
        fusiondirectory-insert-schema --insert \
            /etc/ldap/schema/fusiondirectory/mail-fd.schema \
            /etc/ldap/schema/fusiondirectory/mail-fd-conf.schema \
            /etc/ldap/schema/fusiondirectory/systems-fd.schema \
            /etc/ldap/schema/fusiondirectory/service-fd.schema \
            /etc/ldap/schema/fusiondirectory/systems-fd-conf.schema
    ) &

    touch /var/lib/ldap/.setup
fi

echo "Start slapd"
/usr/sbin/slapd -h 'ldap:/// ldapi:///' -u openldap -g openldap -d `expr 64 + 256 + 512`
#
# The OpenLDAP logging level:
#
#   -1  enable all debugging
#    0  no debugging
#    1  trace function calls
#    2  debug packet handling
#    4  heavy trace debugging
#    8  connection management
#   16  print out packets sent and received
#   32  search filter processing
#   64  configuration file processing
#  128  access control list processing
#  256  stats log connections/operations/results
#  512  stats log entries sent
# 1024  print communication with shell backends
# 2048  print entry parsing debugging
#

