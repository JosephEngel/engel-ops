#!/bin/bash
#--
#-- Script to install sublime text 3 on Fedora
#-- Functions
indent() { sed 's/^/  /'; }
doubleIndent() { sed 's/^/    /'; }
tripleIndent() { sed 's/^/      /'; }
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
  echo "Error - must be root user"
  exit 1
fi

echo -e "--- Installing Sublime Text 3 ---\n"
echo "- Adding GPG Key:"|
rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
checkRunStatus && errorCheck
echo -e "- Adding Repository:"|
dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
checkRunStatus && errorCheck
echo -e "- Installing Sublime Text 3:"|
dnf install -y sublime-text
checkRunStatus && errorCheck
echo "--- Install Complete! ---\n"

