#!/bin/bash
# Install pyenv on Fedora
user=$(whoami)
repo="https://github.com/pyenv/pyenv.git"
pathFile="~/.bashrc"
depList="make gcc zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel"
#-- Do Work
echo "==================================="
echo "Installing pyenv for user: ${user}"
echo "==================================="

cd /home/$(user)
echo "  - Running: git clone ${repo} ~/.pyenv"
git clone ${repo} ~/.pyenv

echo "-- Setting PATH --"
echo "  - Running: echo 'export PYENV_ROOT=\"$HOME/.pyenv\"' >> ${pathFile}"
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ${pathFile}

echo "  - Running: echo 'export PATH=\"$PYENV_ROOT/bin:$PATH\"' >> ${pathFile}"
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ${pathFile}

# Add pyenv init to shel to enable shims and autocompletion
echo "  - Running: echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval \"$(pyenv init -)\"\nfi' >> ${pathFile}"
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ${pathFile}

echo "  - Running: source ${pathFile}"
source ${pathFile}

echo "-- Installing dependencies --"
echo "  - Running: sudo dnf install ${depList}"
sudo dnf install -y ${depList}

# Install Python versions into $(pyenv root)/versions
pyenv install 3.7.6
