#!/bin/bash
#--
echo "Starting: Update all Flatpak Repos"
repoTotal=$(flatpak list --columns=application |grep -Ev 'Application ID'|wc -l)
count=1
for repo in $(flatpak list --columns=application |grep -Ev 'Application ID'); do 
    echo "[${count} of ${repoTotal}] - ${repo}"
    flatpak update ${repo} -y
    ((count++))
    echo ""
done
