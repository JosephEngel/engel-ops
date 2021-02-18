#!/bin/bash
#-- Script to attempt to auto-renew letsencrypt certificates
#-- Vars
certbot="/usr/bin/certbot"

echo "User: $(whoami) - HostName: ${HOSTNAME}"
echo "---- Starting Cert Renewal ---- $(date)"
echo "  User: $(whoami) - HostName: ${HOSTNAME}"
if [[ $(whoami|grep -c "root") -lt 1 ]]; then
    echo "Error: User not Root - $(whomai) - $(date)"
    exit 1
elif [[ -f ${certbot} ]]; then
    echo "Validating Certificates - $(date)"
    echo "---- Current Certs ----"
    ${certbot} certificates |sed "s|^|    |g"
    echo -e "\n---- Re-newing Certs ----"
    ${certbot} renew |sed "s|^|    |g"
    echo -e "\n---- Cert Renewal Log ----"
    [[ -f /var/log/letsencrypt/letsencrypt.log ]] && cat /var/log/letsencrypt/letsencrypt.log |sed "s|^|    |g"
else
    echo "Error: ${certbot} not found - $(date)"
    exit 1
fi
