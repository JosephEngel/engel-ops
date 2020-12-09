#!/bin/bash
#
#-- Script to dynamically create a virtual machine using KVM and kickstart
#--
#-- Define Functions
#---- usage: Print default text to user on incorrect script usage
#---- checkRunStatus: validates previous task ran successfully and exits with errors if passed with "1"
#--
#-- Check Options & Set Variables
verbose='false'
errorCount=0
ksFile="/apps/engel-ops/kickstart/ks.cfg"
#--
indent() { sed 's/^/  /'; }
doubleIndent() { sed 's/^/    /'; }
tripleIndent() { sed 's/^/      /'; }
#--
function usage() {
  echo "Usage: $0 -a <ipAddress> -n <name> [OPTIONS]"
  echo "Try 'kickstart.sh -h' for more information."
}
if [[ $# -lt 2 ]]; then
  usage
  exit 1
fi
while getopts 'a:c:d:h:m:n:v' flag; do
  case "${flag}" in
    a) ipAddress="${OPTARG}" ;;
    c) cpu="${OPTARG}" ;;
    d) disk="${OPTARG}" ;;
    m) memory="${OPTARG}" ;;
    n) name="${OPTARG}" ;;
    v) verbose='true' ;;
    h)
      echo "Usage: kickstart.sh [OPTION]..."
      echo -e "Create and configure a VM using kickstart\n"
      echo "  -a,    set IP Address"
      echo "  -c,    set number of virtual CPUs"
      echo "  -d,    set disk size"
      echo "  -h,    display help message"
      echo "  -m,    set RAM size"
      echo "  -n,    set VM name"
      echo "  -v,    set verbose"
      exit 0
      ;;
    \?)
      echo "Try 'kickstart.sh -h' for more information."
      exit 1
      ;;
  esac
done
#shift $((OPTIND -1))
if [[ ! ${ipAddress} ]] || [[ ! ${name} ]]; then
  echo "error: missing required argument"
  usage
  exit 1
fi
#-- Set variable defaults when not passed
# disk=GB; memory=MB
[[ -z ${cpu} ]] && cpu=1
[[ -z ${disk} ]] && disk=15
[[ -z ${memory} ]] && memory=1024
#-- Display VM settings
#[[ -n ${name} ]] && echo "VM name: ${name}"
#[[ -n ${ipAddress} ]] && echo "IP Address: ${ipAddress}"
#[[ -n ${cpu} ]] && echo "vCPU: ${cpu}"
#[[ -n ${disk} ]] && echo "Disk: ${disk}GB"
#[[ -n ${memory} ]] && echo "Memory: ${memory}MB"
#--
#-- Functions
function checkRunStatus () {
  runStatus="$?"
  if [[ ${runStatus} -eq 0 ]]; then
    echo "-- Success --"|indent
  else
    echo "-- Failed --"|indent
    errorDetails="${errorDetails}\\n- ${taskDetails}"
    ((errorCount++))
  fi
}
#--
function setTaskDetails () {
  taskDetails="$1"
  echo "----- Starting: ${taskDetails} - $(date +%F:%H:%M:%S) -----"
}
#--
function endTask () {
  echo "----- Completed: - $(date +%F:%H:%M:%S) -----"
}
#--
function errorCheck () {
  if [[ ${errorCount} -ge 1 ]]; then
    #echo "----- Failed: - $(date +%F:%H:%M:%S) -----"
    echo "Exiting"|indent
    exit 1
  #else
    #endTask
  fi
}
#----------
#-- Do Work
echo ""
setTaskDetails "Update ks.cfg"
if [[ -f ${ksFile} ]]; then
  sed -i 's/192.168.0.0/'${ipAddress}'/g' ${ksFile}
  checkRunStatus
else
  echo -e "-- Error: file \'${ksFile}\' not found \\n Exiting"|indent >&2
  ((errorCount++)) && exit ${errorCount}
fi
#--
setTaskDetails "Copy ks.cfg -> nginx file server"
echo "- Running: 'scp ${ksFile} nginx.engelcc.com:/var/www/data/ks.cfg'"|indent
scp -i /home/joey/.ssh/joeyengel_id_rsa ${ksFile} nginx.engelcc.com:/var/www/data/ks.cfg
checkRunStatus
#--
setTaskDetails "Set ks.cfg to default"
echo "- Reverting IP Address to default in ks.cfg"|indent
sed -i 's/'${ipAddress}'/192.168.0.0/g' ${ksFile}
checkRunStatus && errorCheck
#--
setTaskDetails "Create virtual machine"
virt-install --name=${name} \
--memory=${memory} --vcpus=${cpu} \
--location=/home/joey/Documents/iso/CentOS-7-x86_64-DVD-1908.iso \
--disk /var/lib/libvirt/images/${name}.qcow2,device=disk,bus=virtio,size=${disk} \
--network bridge:br0 \
--os-type=generic \
--nographics \
--extra-args='ks=nginx.engelcc.com/ks.cfg'
#
checkRunStatus
echo "${errorDetails}" && exit ${errorCount}