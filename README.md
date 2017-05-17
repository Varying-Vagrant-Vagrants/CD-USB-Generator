# VVV Contributor Day USB Generator

## Usage

Clone this repository and run `run.sh`. This will create 2 subfolders:

 - `tmp` - a temporary location that the script will use to download and create the files it needs
 - `build` - this folder will contain the final USB stick files
 
When the script has finished running without issues, copy the contents of the build folder into the root of your USB drive

## What Does It Do?

The script will take a while run, and will:

 - Checkout and provision a copy of VVV
 - Package a pre-built VVV box
 - Zip up the VVV install
 - Download and place copies of the `git` `vagrant` and `virtualbox` installers for Win32/Win64/MacOS in subfolders
 
 ## License
 
 GPL!!
