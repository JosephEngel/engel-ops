#!/bin/bash
# Configure ansible to be used with aws
#--
indent() { sed 's/^/  /'; }
doubleIndent() { sed 's/^/    /'; }
tripleIndent() { sed 's/^/      /'; }
#-- vars
ansibleHostsFile="/etc/ansible/hosts"
#-- Check user
userName="$(whoami)"
if [[ ${userName} != "root" ]]; then
  echo "Error - script must be run as root. Exitting."
  exit 1
fi
#-- Run ansible user install
if [[ $(grep -c "ansible" /etc/passwd) -lt 1 ]]; then
  echo "- Ansible user not found: adding user"
  if [[ ! -f /apps/home-private/scripts/userAdd.sh ]]; then
      echo "- Error: file /apps/home-private/scripts/userAdd.sh not found. Exitting."|indent
      exit 1
  else
      echo "- Running: /apps/[..]/userAdd.sh"|indent
      ./apps/home-private/scripts/userAdd.sh
  fi
fi
#-- install ansible
echo "- Installing Ansible"
if [[ $(dnf list installed |grep ansible|wc -l) -ge 1 ]]; then
    echo "- ansible already installed. Skipping"|indent
else
    echo "- Running: dnf install -y ansible"|indent
    dnf install -y ansible
fi
#-- install boto
echo " -Installing boto"
if [[ $(dnf list installed |grep python3-boto3|wc -l) -ge 1 ]]; then
    echo "- python3-boto3 already installed. Skipping."|indent
else
    echo "- Running: dnf install -y python3-boto3"|indent
    dnf install -y python3-boto3
fi
#-- add localhost to inv.
echo "- Inventory: add localhost"
if [[ $(cat ${ansibleHostsFile} |grep localhost|wc -l) -ge 1 ]]; then
    echo "- localhost already configured. Skipping."|indent
else
    echo "- Running: echo \"localhost\" >> ${ansibleHostsFile}"|indent
    echo "localhost" >> ${ansibleHostsFile}
fi
#--
echo -e "\n--- Setup Complete! ---\n"