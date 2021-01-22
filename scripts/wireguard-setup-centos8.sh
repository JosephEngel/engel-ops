#!/bin/bash
#
#-- Vars
repos='epel-release'
packages='yum-utils wireguard-tools'
errorCount=0
userName="$(whoami)"

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

#-- Do Work
if [[ ${userName} != "root" ]]; then
  echo "Error - script must be run as root. Exitting."
  exit 1
fi

#-- Enable Repos
echo "Adding Required Repos:"
echo "  - Running: initial updates"
dnf update -y
checkRunStatus 1
for repo in ${repos}; do
    echo "  - Adding repo: ${repo}"
    echo "    Running: dnf install -y ${repo}"
    dnf install -y ${repo}
    checkRunStatus 1
    echo ""
done

echo "Enabling PowerTools:"
echo "  - Running: dnf config-manager --set-enabled powertools"
dnf config-manager --set-enabled powertools
checkRunStatus 1

echo "Removing WireGuard DKMS package:"
if [[ $(dnf list installed |grep wireguard-dkms |wc -l) -ge 1 ]]; then
    echo "  - wireguard-dkms package found.  Removing"
    dnf remove -y wireguard-dkms
    checkRunStatus 1
else
    echo "  - Skipping: Package not installed"
fi

# #-- Enable copr repo for wireguard
# echo "Adding copr repo: jdoss/wireguard"
# dnf copr enable jdoss/wireguard -y
# checkRunStatus 1
# echo "Running: dnf update -y"
# dnf update -y

#-- Add Centos Plus repo (for wireguard)
echo "Adding CentosPlus Repo"
if [[ -f /etc/yum.repos.d/CentOS-Stream-BaseOS.repo ]]; then
    baseRepo="/etc/yum.repos.d/CentOS-Stream-BaseOS.repo"
elif [[ -f /etc/yum.repos.d/CentOS-BaseOS.repo ]]; then
    baseRepo="/etc/yum.repos.d/CentOS-BaseOS.repo"
fi
if [[ -z ${baseRepo} ]]; then
    echo "  - Backing up ${baseRepo}:"
    cp ${baseRepo} ${baseRepo}-bak
    checkRunStatus
    echo "  - Adding CentosPlus to baseRepo:"
    echo "" >> ${baseRepo}
    echo '#additional packages that extend functionality of existing packages' >> ${baseRepo}
    echo '[centosplus]' >> ${baseRepo}
    echo 'name=CentOS-$releasever - Plus' >> ${baseRepo}
    echo 'mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus' >> ${baseRepo}
    echo '#baseurl=http://mirror.centos.org/centos/$releasever/centosplus/$basearch/' >> ${baseRepo}
    echo 'gpgcheck=1' >> ${baseRepo}
    echo 'enabled=0' >> ${baseRepo}
    echo "   - Success"
else
    echo "Error: baseRepo not found."
fi

echo "Enabling CentosPlus:"
echo "  - Running: yum-config-manager --setopt=centosplus.includepkgs=\"kernel-plus, kernel-plus-*\" --setopt=centosplus.enabled=1 --save"
yum-config-manager --setopt=centosplus.includepkgs="kernel-plus, kernel-plus-*" --setopt=centosplus.enabled=1 --save
checkRunStatus 1

echo "Adding kernel headers: "
echo "  - Running: sudo sed -e 's/^DEFAULTKERNEL=kernel-core$/DEFAULTKERNEL=kernel-plus-core/' -i /etc/sysconfig/kernel"
sudo sed -e 's/^DEFAULTKERNEL=kernel-core$/DEFAULTKERNEL=kernel-plus-core/' -i /etc/sysconfig/kernel
checkRunStatus 1

echo "Installing Required Packages:"
#for package in ${packages}; do 
#    echo "  - Installing: ${package}"
#    if [[ $(dnf list installed |grep ${package} |wc -l) -lt 1 ]]; then
#        dnf install -y ${package}
#        checkRunStatus 1
#    else
#        echo " - Skipping: Package ${package} already installed."
#    fi
#    echo ""
#done
echo "  - Running: dnf install -y ${packages}"
dnf install -y ${packages}
checkRunStatus 1

echo "Enabling IP Forwarding"
echo "  - Running: 'echo \"net.ipv4.ip_forward=1\" >> /etc/sysctl.d/99-custom.conf'"
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.d/99-custom.conf
checkRunStatus 1

echo "-- Wireguard Installation Complete! -- "
echo "Errors: ${errorCount}"
exit ${errorCount}
