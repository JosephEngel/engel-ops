#!/bin/bash
#-- Script to setup do initial setup on MacOS
#   This has not been tested so use at your discretion
#-- Vars
errorCount=0
brewPackages='asdf awscli bash bash-completion curl git helm htop jq kubectx kubernetes-cli kube-ps1 minikube neofetch neovim pyenv ssh-copy-id sublime-text tmux tree watch wget'
brewCasks='eloston-chromium firefox firefox-developer-edition sublime-text vscodium'
fontCasks='font-fira-code'
taps='hashicorp/tap'
#-- Functions
errorCheck () {
    errorStatus="$?"
    [[ ${errorStatus} -ge 1 ]] && ((errorCount++))
    if [[ ${errorCount} -ge 1 ]]; then
        echo "Error: Exitting"
        exit 1
    fi 
}
#
#-- Do Work
#-- install brew
echo "-- Installing brew --"
echo "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
errorCheck
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
errorCheck
echo "-- Brew Installation Complete --"
echo ""

#-- Install packages
packageCount=$(echo ${brewPackages}|wc -w)
num=1
echo "-- Installing Homebrew Packages --"
for package in ${brewPackages}; do
  echo "  -- [${num} of ${packageCount}]: ${package} --"
  echo "    - Running: brew install ${package}"
  brew install ${package}
  errorCheck
  ((num++))
  echo ""
done
echo -e "\n-- Brew Package Installs Complete --\n"

#-- Install Casks
caskCount=$(echo ${brewCasks} |wc -w)
num=1
echo "-- Installing Homebrew Casks --"
for package in ${brewCasks}; do
  echo "  -- [${num} of ${caskCount}]: ${package} --"
  echo "    - Running: brew install --cask ${package}"
  brew install --cask ${package}
  errorCheck
  ((num++))
  echo ""
done
echo -e "\n-- Brew Cask Installs Complete --\n"

#-- Install fonts
fontCount=$(echo ${fontCasks} |wc -w)
num=1
echo "-- Installing Homebrew Casks --"
for package in ${fontCasks}; do
  echo "  -- [${num} of ${fontCount}]: ${package} --"
  echo "    - Running: brew install homebrew/cask-fonts/${package}"
  brew install homebrew/cask-fonts/${package}
  errorCheck
  ((num++))
  echo ""
done
echo -e "\n-- Brew Font Installs Complete --\n"

echo "All packages have been installed!"
echo "exitting - ${errorCount}"
exit ${errorCount}
