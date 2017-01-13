#!/bin/bash

USER=$1
PASSWD=$2




if [ $# -eq 2 ];then
	echo "Found two arguments"
	id -u $USER &> /dev/null
	if [ $? -eq 0 ];then
		echo "$USER already in system"
		exit 10
	fi
	
	if [ -d "/ftpfiles/$USER" ];then
		echo "/ftpfiles/$USER directory already exists remove to continue"
		exit 10
	fi
	useradd $USER
	mkdir /ftpfiles/$USER
	usermod -d /ftpfiles/$USER -s /sbin/nologin -g ftpaccess $USER
	echo "$PASSWD" | passwd $USER --stdin
	chown -R $USER:ftpaccess /ftpfiles/$USER
	
else

	printf "Needs two arguments username and password \n Ex: ftpadd happy happy\n"
	
fi