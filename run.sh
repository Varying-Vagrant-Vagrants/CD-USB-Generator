#!/usr/bin/env bash

set -e

if [ -d "resources" ]; then
	echo "Resource folder found"
else
	echo "ERROR: Resources folder not found, are you running this script in the correct folder?"
	echo "       Navigate to the folder run.sh is located in and run ./run.sh"
	exit 1
fi

echo "Cleaning up build and tmp folders"
rm -rf build tmp
mkdir -p build tmp

echo "Grabbing VVV"
git clone https://github.com/Varying-Vagrant-Vagrants/VVV.git --branch=develop tmp

echo "Copying custom VVV config with meta environment"
cp resources/vvv-custom.yml tmp/vvv-custom.yml

cd tmp

echo "Updating box"
VVV_SKIP_LOGO=true vagrant box update

echo "Provisioning VVV"
VVV_SKIP_LOGO=true vagrant up --provision --provider=virtualbox

echo "Creating DB export"
VVV_SKIP_LOGO=true vagrant ssh -c db_backup

echo "Prepackaging box"
VVV_SKIP_LOGO=true vagrant package --output ../build/vvv-contribute.box

echo "Destroying temporary VM"
VVV_SKIP_LOGO=true vagrant destroy --force

echo "Cleaning up after Vagrant"
rm -rf .vagrant

echo "Modifying vagrant file box"
sed -i '.bak' 's#ubuntu/trusty64#vvv/contribute#' Vagrantfile

cd ..

echo "Creating build/vvv.zip"
zip -r build/vvv.zip tmp

echo "Cleaning up tmp folder"
rm -rf tmp

echo "Creatig installer folders"
mkdir -p build/windows build/osx build/linux

echo "Downloading installers"
curl -L  https://releases.hashicorp.com/vagrant/2.1.1/vagrant_2.1.1_x86_64.msi -o build/windows/vagrant.msi
curl -L  https://releases.hashicorp.com/vagrant/2.1.1/vagrant_2.1.1_x86_64.dmg -o build/osx/vagrant.dmg
curl -L  https://download.virtualbox.org/virtualbox/5.2.12/VirtualBox-5.2.12-122591-Win.exe -o build/windows/virtualbox.exe
curl -L  https://download.virtualbox.org/virtualbox/5.2.12/VirtualBox-5.2.12-122591-OSX.dmg -o build/osx/virtualbox.dmg
curl -L  https://github.com/git-for-windows/git/releases/download/v2.17.0.windows.1/Git-2.17.0-64-bit.exe -o build/windows/git.exe

echo "Copying instructions"
cp resources/linux.txt build/linux/linux.txt
cp resources/instructions.html build/instructions.html

echo "Congrats, copy the contents of the build folder on to your USB drives and distribute!"
