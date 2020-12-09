#!/bin/bash
#--
#-- Variables
errorCount=0
#-- Functions
indent() { sed 's/^/  /'; }
doubleIndent() { sed 's/^/    /'; }
tripleIndent() { sed 's/^/      /'; }
#--
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
#--
#-- Do Work
echo "Starting: Refresh Git Repos"
if [ -d /apps ]; then
  for a in $(find /apps/ -maxdepth 1 -type d -print |grep "/apps/[a-z,A-Z]"); do
    echo "Pulling new repo data for: ${a}"|indent
    pushd $a >/dev/null
    echo "Running: git fetch" |doubleIndent
    git fetch
    checkRunStatus 1
    echo "Running: git checkout ." |doubleIndent
    git checkout .
    checkRunStatus 
    echo "Running: git pull" |doubleIndent
    git pull
    checkRunStatus
    echo "-- git refresh completed --"|doubleIndent
    popd >/dev/null
  done
else
  echo "No Directory /apps found.  Please check and run again"
  ((errorCount++))
fi
echo -e "\nExitting: ${errorCount}"
exit ${errorCount}
