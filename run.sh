#!/usr/bin/env bash

set -e

rm -rf build tmp
mkdir -p build tmp

git clone https://github.com/Varying-Vagrant-Vagrants/VVV.git --branch=develop tmp

cp resources/vvv-custom.yml tmp/vvv-custom.yml

cd tmp

VVV_SKIP_LOGO=true vagrant plugin install vagrant-triggers

VVV_SKIP_LOGO=true vagrant box update
VVV_SKIP_LOGO=true vagrant up --provision --provider=virtualbox
VVV_SKIP_LOGO=true vagrant ssh -c db_backup
VVV_SKIP_LOGO=true vagrant package --output ../build/vvv-contribute.box
VVV_SKIP_LOGO=true vagrant destroy --force

rm -rf .vagrant

sed -i '.bak' 's#ubuntu/trusty64#vvv/contribute#' Vagrantfile

cd ..

zip -r build/vvv.zip tmp

rm -rf tmp

mkdir -p build/windows build/osx build/linux

curl -L  https://releases.hashicorp.com/vagrant/2.0.1/vagrant_2.0.1_x86_64.msi -o build/windows/vagrant.msi
curl -L  https://releases.hashicorp.com/vagrant/2.0.1/vagrant_2.0.1_x86_64.dmg -o build/osx/vagrant.dmg
curl -L  http://download.virtualbox.org/virtualbox/5.2.2/VirtualBox-5.2.2-119230-Win.exe -o build/windows/virtualbox.exe
curl -L  http://download.virtualbox.org/virtualbox/5.2.2/VirtualBox-5.2.2-119230-OSX.dmg -o build/osx/virtualbox.dmg

cp resources/linux.txt build/linux/linux.txt
cp resources/instructions.html build/instructions.html
