#!/bin/bash

# Look for developer tools (needed for Homebrew)
xcode-select -p
if [ $? -eq 0 ]; then
  	echo "Found XCode Tools"
else
  	echo "Installing XCode Tools"
  
	xcode-select --install
fi

# Flags
set -e # Global exit on error flag
set -x # Higher verbosity for easier debug
set -o pipefail # Exit on pipe error

# Chage shell script files to run
chmod +x *.sh

# Change MacOS Settings
./settings.sh

# Put local in bash_profile
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bash_profile

# Install Homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update

# Setup Brew bundle for running Brewfiles
brew tap Homebrew/bundle && brew bundle

# Since XCode got installed, need to agree to license
sudo xcodebuild -license

# Install python environments
./python_setup.sh

# Install Ruby gems
gem install bundler
bundle install

# Configure ZSH
./zsh_setup.sh

# Load dotfiles
./dotfiles_setup.sh

# Run post-processing script
./post-process.sh

# Extra dependencies and applications [Optional]
while true; do
    read -p "Do you want to install the extra utils/apps?[y/n]" yn
    case $yn in
        [Yy]* ) brew bundle --file=Brewfile_extra; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done


# Clean cached files and pkgs
brew cleanup
brew cask cleanup
brew prune