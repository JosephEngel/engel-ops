#!/bin/bash
#
#-- Vars
fileDate=$(date +%Y-%m-%d)
errorCount=0
profilePath="/home/joey/.mozilla/firefox"
profileDir="joey.main"
serverIP="striker.red"


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
echo "Beginning Firefox Full Backup as $(whoami)"
echo "------------------------------------------------"

echo "Stopping firefox processes:"
pids=$(pidof firefox)
if [[ -z ${pids} ]]; then
    echo "  - No Firefox process found.  Continuing."
else
    echo "  - Processes found: ${pids}"
    #echo "    Running: pkill -9 firefox"
    for pid in ${pids}; do
        if [[ $(pidof firefox |grep -c ${pid}) -ge 1 ]]; then
            echo "    - Running: kill -9 ${pid}"
            kill -9 ${pid}
            sleep 2
        else
            echo "    - Main process stopped."
            continue
        fi
    done
    pidCheck=$(pidof firefox)
    if [[ ! -z ${pidCheck} ]]; then
        echo "    Error: pids exist: ${pidCheck}"
        ((errorCount++))
        echo "      Exitting: ${errorCount}"
        exit ${errorCount}
    fi
    echo "      - Success: Firefox Stopped."
fi

echo ""

if [[ ! -d /home/joey/.mozilla/firefox/profile-backups ]]; then
    mkdir /home/joey/.mozilla/firefox/profile-backups
fi

echo "Tar-ing profile:"
echo "  - Running: tar -cf /home/joey/.mozilla/firefox/profile-backups/${fileDate}-firefoxProfile.tar --totals ${profilePath}/${profileDir}"
tar -cf /tmp/${fileDate}-firefoxProfile.tar --totals ${profilePath}/${profileDir}
checkRunStatus 1

echo "Compressing Backup:"
echo "  - Running gzip -9 /tmp/${fileDate}-firefoxProfile.tar"
gzip -9 /tmp/${fileDate}-firefoxProfile.tar
checkRunStatus 1

echo "Copying to Server:"
echo "  - Running: rsync /tmp/${fileDate}-firefoxProfile.tar.gz ${serverIP}:~/firefox-backups/"
rsync /tmp/${fileDate}-firefoxProfile.tar.gz ${serverIP}:~/firefox-backups/
checkRunStatus

echo ""
echo "------------------------------------------------"
echo "Backup Complete!"
echo "Errors: ${errorCount}"
echo "Exit ${errorCount}"
exit ${errorCount}
