#!/bin/sh

USER=$1

removeDIR(){
	echo "Finding DIR /ftpfiles/$USER"
	echo "Current Folder Size $(du -sh /ftpfiles/$USER)"
	read -p "Continue to remove folder?" -n 1 -r 
	echo
	if [[ $REPLY =~ ^[Yy]$ ]];then
		echo "Removing $USER and Folder"
		userdel --remove $USER
		
	}

id -u $USER &> /dev/null
if [ $? -eq 0 ];then
	echo "$USER Found"
	cat /etc/vsftpd/user_list | grep $USER >> /dev/null
	if [ $? -eq 0 ];then
		removeDIR
	else
		echo "$USER unable to removed non-ftp user /etc/vsftpd/user_list"
		exit 10
	fi
else
	echo "$USER not found"
	exit 10
fi
	
	