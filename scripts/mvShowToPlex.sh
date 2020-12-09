#!/bin/bash
#--
#-- Variables
errorCount=0
#--
show="$1"
season="$2" # run with empty parameter to skip series check
type="$3" # Only required if show is an anime
if [[ $(echo "${type}"|grep -c "nime") -ge 1 ]]; then
    echo "Type set to 'Anime'"
    plexDir="/mnt/plex/Anime/${show}"
else
    plexDir="/mnt/plex/TV/${show}"
fi
if [[ -z ${season} ]]; then
    echo "Season not provided - episodes will be put in title folder"
else
    plexDir="${plexDir}/${season}"
fi
downloadDir="/mnt/plex/downloads/complete"
#-- Functions
errorCheck () {
    errorStatus="$?"
    [[ ${errorStatus} -ge 1 ]] && ((errorCount++))
    if [[ ${errorCount} -ge 1 ]]; then
        echo "Error: Exitting"
        exit 1
    fi 
}
function moveVideo () {
    echo "Running: pushd ${dir}"
    pushd ${dir} >/dev/null
    errorCheck
    #-- Replace any spaces in dir name with an underscore
    for f in *\ *; do mv "$f" "${f// /_}"; done 2>/dev/null
    title=$(echo "${dir}" |grep -Eo '[-_.][0-9]{1,2}[-_.]')
    title=$(echo ${title:1:-1})
    videos=$(ls |grep -E "*.(avi|mkv)")
    for vid in ${videos}; do
        if [[ ${vid} =~ "sample" ]]; then
            echo "Removing sample file: ${vid}"
            rm -rf ${vid}
        else
            echo "Setting video file permissions"
            chmod 755 ${vid}
            errorCheck
            if [[ -z ${title} ]]; then
                echo "Running: mv ${vid} ${plexDir}"
                mv ${vid} ${plexDir}
            else
                echo "Running: mv ${vid} ${plexDir}/${title}.mkv"
                mv ${vid} ${plexDir}/${title}.mkv
            fi
        fi    
        errorCheck 
    done
    popd >/dev/null
    errorCheck
    echo -e "Removing Dir: ${dir}\n"
    rm -rf ${dir}
    errorCheck
}
function moveVideoSeason () {
    echo "Running: pushd ${dir}"
    pushd ${dir} >/dev/null
    errorCheck
    #-- Replace any spaces in dir name with an underscore
    for f in *\ *; do mv "$f" "${f// /_}"; done 2>/dev/null
    #title=$(echo "${dir}" |grep -Eo '[sS][0-9]{1,2}[eE][0-9]{1,2}')
    title=$(echo "${dir}" |grep -Eo '([sS][0-9]{1,2}[eE][0-9]{1,2}|[0-9][xX][0-9]{1,2})')
    videos=$(ls |grep -E "*.(avi|mkv|mp4)")
    for vid in ${videos}; do
        if [[ ${vid} =~ "sample" ]]; then
            echo "Removing sample file: ${vid}"
            rm -rf ${vid}
        else
            echo "Setting video file permissions"
            chmod 755 ${vid}
            errorCheck
            if [[ -z ${title} ]]; then
                echo "Running: mv ${vid} ${plexDir}"
                mv ${vid} ${plexDir}
            else
                echo "Running: mv ${vid} ${plexDir}/${title}.mkv"
                mv ${vid} ${plexDir}/${title}.mkv
            fi
        fi    
        errorCheck 
    done
    popd >/dev/null
    errorCheck
    echo -e "Removing Dir: ${dir}\n"
    rm -rf ${dir}
    errorCheck
}
#-- Do Work
if [[ -z "$1" ]]; then
    echo "Error: must pass variables:"
    echo "./mvShowToPlex.sh \"show\""
    ((errorCount++))
    errorCheck
fi
[[ -d ${downloadDir} ]] && cd ${downloadDir}
errorCheck
if [[ ! -d ${plexDir} ]]; then
    echo "Creating dir: ${plexDir}"
    mkdir -p ${plexDir}
    errorCheck
fi
#-- Replace any spaces in dir name with an underscore
for f in *\ *; do mv "$f" "${f// /_}"; done 2>/dev/null
#-- Set for insensitive case matching
shopt -s nocasematch
if [[ -z ${season} ]]; then
    for dir in $(ls); do
        if [[ ${dir} =~ "$(echo ${show}| sed 's/_/./g')" ]] || [[ ${dir} =~ "$(echo ${show}| sed 's/_/-/g')" ]] || [[ ${dir} =~ "$(echo ${show})" ]]; then
            echo "Running: moveVideo"
            moveVideo
        fi
    done
else
    for dir in $(ls); do
        if [[ "${dir}" =~ "${season}" ]]; then
            if [[ ${dir} =~ "$(echo ${show}| sed 's/_/./g')" ]] || [[ ${dir} =~ "$(echo ${show}| sed 's/_/-/g')" ]] || [[ ${dir} =~ "$(echo ${show})" ]]; then
                echo "Running: moveVideoSeason"
                moveVideoSeason
            fi
        fi
    done
fi

