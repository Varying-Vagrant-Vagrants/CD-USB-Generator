#!/usr/bin/env bash

set -e

if [ -d "resources" ]; then
	echo "1/18 Resource folder found"
else
	echo "ERROR: Resources folder not found, are you running this script in the correct folder?"
	echo "       Navigate to the folder run.sh is located in and run ./run.sh"
	exit 1
fi

echo "2/18 Cleaning up build and vvv folders"
rm -rf build vvv
mkdir -p build vvv

echo "3/18 Grabbing VVV"
git clone https://github.com/Varying-Vagrant-Vagrants/VVV.git --branch=master vvv

echo "4/18 Copying custom VVV config with meta environment"
cp resources/vvv-custom.yml vvv/vvv-custom.yml

cd vvv

echo "5/18 Installing vagrant hosts updater plugin"
VVV_SKIP_LOGO=true vagrant plugin install vagrant-hostsupdater

echo "6/18 Updating box"
VVV_SKIP_LOGO=true vagrant box update

echo "7/18 Provisioning VVV"
VVV_SKIP_LOGO=true vagrant up --provision --provider=virtualbox

echo "8/18 Creating DB export"
VVV_SKIP_LOGO=true vagrant ssh -c db_backup

echo "9/18 Prepackaging box"
VVV_SKIP_LOGO=true vagrant package --output ../build/vvv-contribute.box

echo "10/18 Destroying temporary VM"
VVV_SKIP_LOGO=true vagrant destroy --force

echo "11/18 Cleaning up after Vagrant"
rm -rf .vagrant

echo "12/18 Modifying vagrant file box"
sed -i '.bak' 's#ubuntu/trusty64#vvv/contribute#' Vagrantfile

cd ..

echo "13/18 Creating build/vvv.zip"
zip -r build/vvv.zip vvv

echo "14/18 Cleaning up vvv folder"
rm -rf vvv

echo "15/18 Creatig installer folders"
mkdir -p build/windows build/osx build/linux

echo "16/18 Downloading installers"
curl -L  https://releases.hashicorp.com/vagrant/2.1.1/vagrant_2.1.1_x86_64.msi -o build/windows/vagrant.msi
curl -L  https://releases.hashicorp.com/vagrant/2.1.1/vagrant_2.1.1_x86_64.dmg -o build/osx/vagrant.dmg
curl -L  https://download.virtualbox.org/virtualbox/5.2.12/VirtualBox-5.2.12-122591-Win.exe -o build/windows/virtualbox.exe
curl -L  https://download.virtualbox.org/virtualbox/5.2.12/VirtualBox-5.2.12-122591-OSX.dmg -o build/osx/virtualbox.dmg
curl -L  https://github.com/git-for-windows/git/releases/download/v2.17.0.windows.1/Git-2.17.0-64-bit.exe -o build/windows/git.exe

echo "17/18 Copying instructions"
cp resources/linux.txt build/linux/linux.txt
cp resources/instructions.html build/instructions.html

echo "18/18 Congrats, copy the contents of the build folder on to your USB drives and distribute!"
