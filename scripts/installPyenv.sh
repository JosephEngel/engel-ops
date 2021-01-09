#!/bin/bash
#-- Install pyenv on Fedora/centos8
user=$(whoami)
repo="https://github.com/pyenv/pyenv.git"
pathFile="/home/${user}/.bashrc"
depList="make gcc zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel"
#-- Do Work
echo "==================================="
echo "Installing pyenv for user: ${user}"
echo "==================================="

cd /home/${user}
if [[ ! -d ~/.pyenv ]]; then
    echo "  - Running: git clone ${repo} ~/.pyenv"
    git clone ${repo} ~/.pyenv
else
    echo "  - pyenv already installed. Skipping."
fi

echo "-- Setting PATH --"
if [[ $(cat ${pathFile} |grep -c 'export PYENV_ROOT') -ge 1 ]]; then
    echo "  - pyenv paths already set. Skipping."
else
    #echo "  - Running: echo 'export PYENV_ROOT=\"$HOME/.pyenv\"' >> ${pathFile}"
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ${pathFile}
    #echo "  - Running: echo 'export PATH=\"$PYENV_ROOT/bin:$PATH\"' >> ${pathFile}"
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ${pathFile}
fi

# Add pyenv init to shel to enable shims and autocompletion
echo "-- Enabling shims and autocompletion --"
if [[ $(cat ${pathFile} |grep -c 'if command -v pyenv') -ge 1 ]]; then
    echo "  - pyenv init already added. Skipping."
else
    #echo "  - Running: echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval \"$(pyenv init -)\"\nfi' >> ${pathFile}"
    echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ${pathFile}
fi
echo "  - Running: source ${pathFile}"
source ${pathFile}

echo "-- Installing dependencies --"
echo "  - Running: sudo dnf install -y ${depList}"
sudo dnf install -y ${depList}

# Install Python versions into $(pyenv root)/versions
echo "-- Installing pyenv python --"
echo "  - Running: pyenv install 3.7.6"
pyenv install 3.7.6
# Set global pyenv
pyenv global 3.7.6

# Install pyenv-virtualenv plugin
echo "-- Installing pyenv-virtualenv plugin --"
echo "  - Running: cd .pyenv/plugins"
cd .pyenv/plugins
echo "  - Cloning repo: pyenv-virtualenv"
if [[ -d pyenv-virtualv ]]; then
    echo "  - plugin already installed. Skipping"
else
    git clone https://github.com/pyenv/pyenv-virtualenv.git pyenv-virtualenv
fi
if [[ $(cat ${pathFile} |grep -c 'pyenv virtualenv-init') -lt 1 ]]; then
    echo 'eval "$(pyenv virtualenv-init -)"' >> ${pathFile}
fi

echo -e "\n-- Complete! --"
