#!/usr/bin/env bash

set -e

not_suggested_path=(
    '/volumes/'
    '/mnt/'
    '/media/'
)
proceed=true
current_directory=$(pwd)

echo -e "\033[0;32mHello! This script will generate a build folder containing a copy of VVV with instructions and installers.\033[0m"
echo -e "\033[0;32mOnce this script finishes succesfully, you can copy the contents of the build folder on to USB drives!\033[0m"
echo ""
echo -e "\033[0;33mPrior warning, this script takes a while to run, don't be surprised if it's 1 hour+\033[0m"
for path in "${not_suggested_path[@]}" ; do
    if [[ $current_directory = *$path* ]]; then
        read -p "You are trying run this on a USB drive, it is better for performance and avoid errors to run on HDD/SSD drive. Do you want to proceed anyway?" -n 1 -r
        proceed=false
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            proceed=true
        fi
    fi
done
echo ""

if [[ ! $proceed ]]; then
    exit
fi

total=22
counter=1
if [ -d "resources" ]; then
    echo -e "\033[0;32m${counter}/${total} Resource folder found\033[0m"
else
    echo -e "\033[0;31mERROR: Resources folder not found, are you running this script in the correct folder?"
    echo -e "       Navigate to the folder run.sh is located in and run ./run.sh\033[0m"
    exit 1
fi
counter=$((counter+1))

echo -e "\033[0;32m${counter}/${total} Cleaning up build and vvv folders\033[0m"
rm -rf build vvv
mkdir -p build vvv installers
counter=$((counter+1))

echo -e "\033[0;32m${counter}/${total} Grabbing VVV"
git clone https://github.com/Varying-Vagrant-Vagrants/VVV.git --branch=develop vvv
counter=$((counter+1))

echo -e "\033[0;32m${counter}/${total} Copying custom initial setup VVV config with meta environment\033[0m"
cp resources/pre-config.yml vvv/config/config.yml
counter=$((counter+1))

cd vvv

echo -e "\033[0;32m${counter}/${total} Installing the vagrant goodhosts plugin\033[0m"
VVV_SKIP_LOGO=true vagrant plugin install --local
counter=$((counter+1))

echo -e "\033[0;32m${counter}/${total} Updating base box\033[0m"
VVV_SKIP_LOGO=true vagrant box update
counter=$((counter+1))

echo -e "\033[0;32m${counter}/${total} Provisioning VVV\033[0m"
VVV_SKIP_LOGO=true vagrant up --provision --provider=virtualbox
counter=$((counter+1))

echo -e "\033[0;32m${counter}/${total} Creating DB export\033[0m"
VVV_SKIP_LOGO=true vagrant ssh -c "db_backup"
counter=$((counter+1))

echo -e "\033[0;32m${counter}/${total} Prepackaging box\033[0m"
VVV_SKIP_LOGO=true vagrant package --output ../build/vvv-contribute.box
counter=$((counter+1))

echo -e "\033[0;32m${counter}/${total} Destroying temporary VM\033[0m"
VVV_SKIP_LOGO=true vagrant destroy --force
counter=$((counter+1))

echo -e "\033[0;32m${counter}/${total} Copying final config/config.yml\033[0m"
cp -f ../resources/config.yml config/config.yml
counter=$((counter+1))

echo -e "\033[0;32m${counter}/${total} Cleaning up after Vagrant\033[0m"
rm -rf .vagrant
counter=$((counter+1))

cd ..

echo -e "\033[0;32m${counter}/${total} Creating build/vvv.zip\033[0m"
zip -r build/vvv.zip vvv
counter=$((counter+1))

echo -e "\033[0;32m${counter}/${total} Cleaning up vvv folder\033[0m"
rm -rf vvv
counter=$((counter+1))

echo -e "\033[0;32m${counter}/${total} Creating installer folders\033[0m"
mkdir -p build/windows build/mac build/linux
counter=$((counter+1))

echo -e "\033[0;32m${counter}/${total} Downloading installers\033[0m"

mkdir -p installers/windows installers/mac

if [ ! -f installers/windows/vagrant.2.2.9.msi ]; then
    curl -L --silent https://releases.hashicorp.com/vagrant/2.2.4/vagrant_2.2.9_x86_64.msi -o installers/windows/vagrant.2.2.9.msi &
fi
if [ ! -f installers/mac/vagrant.2.2.9.dmg ]; then
    curl -L --silent https://releases.hashicorp.com/vagrant/2.2.4/vagrant_2.2.9_x86_64.dmg -o installers/mac/vagrant.2.2.9.dmg &
fi
if [ ! -f installers/windows/virtualbox.5.2.26.exe ]; then
    curl -L --silent https://download.virtualbox.org/virtualbox/5.2.26/VirtualBox-5.2.26-128414-Win.exe -o installers/windows/virtualbox.5.2.26.exe &
fi
if [ ! -f installers/mac/virtualbox.6.1.10.dmg ]; then
    curl -L --silent https://download.virtualbox.org/virtualbox/6.1.10/VirtualBox-6.1.10-138449-OSX.dmg -o installers/mac/virtualbox.6.1.10.dmg &
fi
if [ ! -f installers/windows/git.2.27.exe ]; then
    curl -L --silent https://github.com/git-for-windows/git/releases/download/v2.27.0.windows.1/Git-2.27.0-64-bit.exe -o installers/windows/git.2.27.exe &
fi
wait
counter=$((counter+1))

echo -e "\033[0;32m${counter}/${total} Copying installers\033[0m"
mkdir -p build/windows build/mac
cp -f installers/windows/vagrant.2.2.9.msi build/windows/
cp -f installers/windows/virtualbox.5.2.26.exe build/windows/
cp -f installers/windows/git.2.27.exe build/windows/

cp -f installers/mac/vagrant.2.2.9.dmg build/mac/
cp -f installers/mac/virtualbox.6.1.10.dmg build/mac/
counter=$((counter+1))

echo -e "\033[0;32m${counter}/${total} Acquiring a local copy of the Vagrant Hosts Updater plugin\033[0m"
gem fetch vagrant-goodhosts
counter=$((counter+1))

echo -e "\033[0;32m${counter}/${total} Renaming gem file to remove the version number\033[0m"
mv vagrant-goodhosts-*.gem build/vagrant-goodhosts.gem
counter=$((counter+1))

echo -e "\033[0;32m${counter}/${total} Copying instructions\033[0m"
cp resources/linux.txt build/linux/linux.txt
cp resources/instructions.html build/instructions.html
counter=$((counter+1))

echo -e "\033[0;32m${total}/${total} Congrats, copy the contents of the build folder on to your USB drives and distribute!\033[0m"
