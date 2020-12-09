#!/bin/bash
#-- Configure undervolting for xps15 7590/precision 5530 (Fedora 31+)
#
#-- Variables
packages="lm_sensors intel-undervolt"
conf="/etc/intel-undervolt.conf"
errorCount=0
#-- Functions
indent() { sed 's/^/  /'; }
#--
function errorCheck () {
  if [[ ${errorCount} -ge 1 ]]; then
    echo "Exiting"|indent
    exit 1
  fi
}
#--
function checkRunStatus () {
  runStatus="$?"
  if [[ ${runStatus} -eq 0 ]]; then
    echo "-- Success --"|indent
  else
    echo "-- Failed --"|indent
  #  #errorDetails="${errorDetails}\\n- ${taskDetails}"
    ((errorCount++))
  fi
}
#-- Do Work
if [[ $(whoami) != 'root' ]]; then
  echo "Error - must run as root"
  exit 1
fi
#-- Verify cpu 
if [[ $(cat /proc/cpuinfo |grep -m 1 "model name"|grep -c -e "i7-[89][78]50H") -ne 1 ]]; then
  echo "Error: CPU must be an i7-9750H/i7-8850H. Exitting"
  exit 1
fi
#-- install packages
for package in ${packages}; do
  if [[ $(dnf list installed|grep -c ${package}) -lt 1 ]]; then
    echo "Installing Package: ${package}"
    dnf install -y ${package}|indent
    checkRunStatus
  fi
done
errorCheck
#-- edit conf
if [[ -f ${conf} ]]; then
  echo "Backing up ${conf} -> ${conf}.bak"
  cp ${conf} ${conf}.bak
  echo "Updating conf file"
  sed -i 's/undervolt 0 '"'"'CPU'"'"' 0/undervolt 0 '"'"'CPU'"'"' -164/g' ${conf} || ((errorCount++))
  sed -i 's/undervolt 1 '"'"'GPU'"'"' 0/undervolt 0 '"'"'GPU'"'"' -150/g' ${conf} || ((errorCount++))
  sed -i 's/undervolt 2 '"'"'CPU Cache'"'"' 0/undervolt 0 '"'"'CPU Cache'"'"' -125/g' ${conf} || ((errorCount++))
else
  echo "Error: ${conf} not found."
  ((errorCount++))
fi
errorCheck
#--
echo -e "CPU info before undervolt:\n"
sensors |indent
echo ''
#-- Start/Enable service
echo "Enabling Service:"
systemctl enable intel-undervolt
checkRunStatus
echo "Starting Service:"
systemctl start intel-undervolt
checkRunStatus
systemctl status intel-undervolt
#--
echo -e "CPU info:\n"
sensors |indent
echo ''
