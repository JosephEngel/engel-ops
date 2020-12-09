#!/bin/bash
#
#-- Variables
file="$1"
hosts="$2"
domain="$3"
user="joey"
[[ -z $3 ]] && domain="engelcc.com"
#-- Do Work
if [[ -z $1 ]]; then
  echo "Error: must pass a script to run: $1. Exitting."
  exit 1
elif [[ ! -f ${file} ]]; then
  echo "Error: script not found: ${file}.  Please make sure the file exists. Exitting."
  exit 1
fi 
if [[ -z $2 ]]; then
  echo "Error: must specify remote host: $2. Exitting."
  exit 1
fi
hostCount=$(echo "${hosts}"|wc -w)
count=1
#
for host in ${hosts}; do
  unset hostname
  echo "--- [${count} of ${hostCount}]: ${host} ---"
  hostname="${host}.${domain}"
  echo "Copying file"
  scp ${file} ${user}@${hostname}:~
  echo "Running script on remote server"
  ssh -t ${user}@${hostname} "sudo /home/${user}/${file}"
  echo "Removing script on remote server"
  ssh -t ${user}@${hostname} "rm /home/${user}/${file}"
done
