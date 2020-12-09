#!/bin/bash
#
#-- Vars
repos='elrepo-release epel-release'
packages='kmod-wireguard wireguard-tools'
errorCount=0
userName="$(whoami)"
#
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
#
#-- Do Work
if [[ ${userName} != "root" ]]; then
  echo "Error - script must be run as root. Exitting."
  exit 1
fi
# Enable Repos
echo "Adding Required Repos:"
for repo in ${repos}; do
    echo "  - Adding repo: ${repo}"
    echo "    Running: dnf install -y ${repo}"
    dnf install -y ${repo}
    checkRunStatus 1
    echo ""
done
echo "Removing WireGuard DKMS package:"
if [[ $(dnf list installed |grep wireguard-dkms |wc -l) -ge 1 ]]; then
    echo "  - wireguard-dkms package found.  Removing"
    dnf remove -y wireguard-dkms
    checkRunStatus 1
else
    echo "  - Skipping: Package not installed"
fi
echo "Installing Required Packages:"
for package in ${packages}; do 
    echo "  - Installing: ${package}"
    if [[ $(dnf list installed |grep ${package} |wc -l) -lt 1 ]]; then
        dnf install -y ${package}
        checkRunStatus 1
    else
        echo " - Skipping: Package ${package} already installed."
    fi
    echo ""
done
echo "-- Wireguard Installation Complete! -- "
echo "Errors: ${errorCount}"
exit ${errorCount}
