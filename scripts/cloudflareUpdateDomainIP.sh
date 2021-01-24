#!/bin/bash
#-- Description
#  Script to update a Domains IP Address using Cloudflare's API

#-- Vars
errorCount=0
domain="$1"
apiKey="$2"
zoneID="$3"
getIP=$(curl -s icanhazip.com)

#-- Functions
function checkRunStatus () {
  runStatus="$?"
  if [[ ${runStatus} -gt 0 ]] && [[ $1 -ge 1 ]]; then
    ((errorCount++))
    echo "- Fatal Error: Exitting (${errorCount})."
    exit ${errorCount}
  elif [[ ${runStatus} -gt 0 ]]; then
    ((errorCount++))
    echo "- Non-Fatal Error: Continuing."
  else
    [[ $1 -lt 3 ]] && echo "- Success"
  fi
}

function getDomainInfo () {
  echo "Getting Domain Info: ${domain}"
  echo " - Polling: NS"
  nameserver=$(dig NS ${domain} +short |head -n 1)
  checkRunStatus 1
  echo " - Polling: IP Address "
  domainIP=$(dig A ${domain} @${nameserver} +short)
  checkRunStatus 1
}

function getRecordInfo () {
  echo "Getting DNS Record Info:"
  echo " - Polling: All DNS Records"
  records=$(curl -sX GET "https://api.cloudflare.com/client/v4/zones/${zoneID}/dns_records" -H "Authorization: Bearer ${apiKey}" -H "Content-Type: application/json")
  checkRunStatus 1
  echo " - Polling: A record Value"
  domainIP=$(echo ${records}|jq ".result[] |select(((.zone_name==\"${domain}\") and .name==\"${domain}\") and .type==\"A\") |.content"|tr -d '"')
  checkRunStatus 1
  echo " - Polling: A record API ID"
  recordID=$(echo ${records}|jq ".result[] |select(((.zone_name==\"${domain}\") and .name==\"${domain}\") and .type==\"A\") |.id"|tr -d '"')
  checkRunStatus 1
  echo " - Polling: A record TTL"
  recordTTL=$(echo ${records}|jq ".result[] |select(((.zone_name==\"${domain}\") and .name==\"${domain}\") and .type==\"A\") |.ttl"|tr -d '"')
  checkRunStatus 1
}

function updateRecordIP () {
  curl -sX --output /dev/null PUT "https://api.cloudflare.com/client/v4/zones/${zoneID}/dns_records/${recordID}" -H "Authorization: Bearer ${apiKey}" -H "Content-Type: application/json" --data "{\"type\":\"A\",\"name\":\"${domain}\",\"content\":\"${getIP}\",\"ttl\":${recordTTL},\"proxied\":false}"
  checkRunStatus 1
}

#-- Do Work
# Check Passed Vars
if [[ -z ${domain} ]]; then
  echo "Error: must pass a domain (\$1).  Exitting."
  exit 1
elif [[ -z ${apiKey} ]]; then
  echo "Error: must pass an api key (\$2).  Exitting."
  exit 1
elif [[ -z ${zoneID} ]]; then
  echo "Error: must pass a zone id (\$3).  Exitting."
  exit 1
elif [[ $(echo ${getIP} |grep -cE "^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$") -ne 1 ]]; then
  echo "Error: Could not determine current IP address:"
  echo "  getIP: ${getip}"
  echo "Exitting."
  exit 1
fi

getDomainInfo
echo -e "\n-----------------------"
echo "Domain Info: ${domain}"
echo "  - Current IP: ${getIP}"
echo "  - DNS Record IP: ${domainIP}"
echo -e "\n-----------------------"

if [[ ${domainIP} != ${getIP} ]]; then
  echo "Current IP does not match DNS Record. Updating DNS Record:"
  echo ""
  getRecordInfo
  echo "Updating DNS Record from ${domainIP} to: ${getIP}"
  echo ""
  updateRecordIP
  echo ""
  echo "Confirming DNS Update:"
  updateSuccess=0
  for (( i = 1; i < 10 ; i++ )); do
    echo "  [${i} of 10]: ${domain}"
    records=$(curl -sX GET "https://api.cloudflare.com/client/v4/zones/${zoneID}/dns_records" -H "Authorization: Bearer ${apiKey}" -H "Content-Type: application/json")
    domainIP=$(echo ${records}|jq ".result[] |select(((.zone_name==\"${domain}\") and .name==\"${domain}\") and .type==\"A\") |.content"|tr -d '"')
    if [[ ${domainIP} == ${getIP} ]]; then
      echo "   - A Record Updated: ${domainIP}"
      updateSuccess=1
      break
    else
      echo "   - A record not yet updated. Waiting 5 sec."
      sleep 5
    fi
  done
  if [[ ${updateSuccess} -ne 1 ]]; then
    echo "  Error: Record not updated."
    ((errorCount++))
  fi 
else
  echo "DNS Record up to date."
fi

echo ""
echo "-- Complete --"
echo "Exitting: ${errorCount}"
exit ${errorCount}
