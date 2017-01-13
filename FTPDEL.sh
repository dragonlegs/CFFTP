#!/bin/bash

USER=$1

removeDIR(){
	echo "Finding DIR /ftpfiles/$USER"
	echo "Current Folder Size $(du -sh /ftpfiles/$USER)"
	read -p "Continue to remove folder?" -n 1 -r 
	echo ""
	if [[ $REPLY =~ ^[Yy]$ ]];then
		echo "Removing $USER and Folder"
		userdel --remove $USER
	fi
}
if [ $# -ne 1 ];then
	echo "Need one argument"
	echo "Ex: ftpdel user"
fi
id -u $USER &> /dev/null
if [ $? -eq 0 ];then
	echo "$USER Found"
	id -Gn $USER | grep '\ftpaccess\b'
	if [ $? -eq 0 ];then
		removeDIR
	else
		echo "$USER unable to removed non-ftp user (Not in ftpaccess group)"
		exit 10
	fi
else
	echo "$USER not found"
	exit 10
fi
	