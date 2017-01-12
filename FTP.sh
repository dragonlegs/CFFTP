#!/bin/sh
set -e
echo "Starting Initial FTP Start"
PASSWORD=$1
setupPackages(){
	yum install vsftpd expect -y

}

errorHDfunction() {
	echo "$1"; exit 10;
}
setupEBS(){
	mkdir /ftpfiles/ || errorHDfunction "/ftpfiles/ already found please delete folder to continue"
	lsblk | grep xvdb || errorHDfunction "Unable to find /dev/xvdb"
	mkfs -t ext4 /dev/xvdb
	mount /dev/xvdb /ftpfiles/
	useradd ftpuser
	groupadd ftpaccess
	usermod -a -G ftpaccess ftpuser
	chown -R ftpuser:ftpaccess /ftpuser/
	
	
	
}
setupFTP(){
	sed -i s/anonymous_enable=YES/anonymous_enable=NO/g /etc/vsftpd/vsftpd.conf
	sed -i s/#chroot_local_user=YES/chroot_local_user=YES/g /etc/vsftpd/vsftpd.conf 
	echo "ec2-user" >> /etc/vsftpd/user_list
	echo "pasv_enable=YES" >> /etc/vsftpd/vsftpd.conf
	echo "pasv_min_port=1024" >> /etc/vsftpd/vsftpd.conf
	echo "pasv_max_port=1048" >> /etc/vsftpd/vsftpd.conf
	echo "pasv_address=$(curl http://169.254.169.254/latest/meta-data/public-ipv4/)" >> /etc/vsftpd/vsftpd.conf
}

setupUsers(){
	useradd happy
	usermod -d /ftpfiles/happy -s /sbin/nologin -g ftpaccess happy
	echo $PASSWORD | passwd happy --stdin
	mkdir /ftpfiles/happy
	chown -R happy /ftpfiles/happy

}

setupPackages
setupEBS
setupFTP
setupUsers
service vsftpd start
chkconfig vsftpd on