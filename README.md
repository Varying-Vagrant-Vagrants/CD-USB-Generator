# VVV Contributor Day USB Generator

## What Does It Do?

The script will take a while run, and will:

- Checkout and provision a copy of VVV
- Package a pre-built VVV box
- Zip up the VVV install
- Download and place copies of the `git` `vagrant` and `virtualbox` installers Windows/Mac in subfolders

## Usage

Clone this repository and run `./run.sh`. This will create 2 subfolders:

- `vvv`, a temporary location that the script will use to download and create the files it needs
- `build`, this folder will contain the final USB stick files

When the script has finished running without issues, copy the contents of the build folder into the root of your USB drive

## License

This script is under the GPL v2+ license.
