#!/bin/sh
set -e
echo "Starting Initial FTP Start"
USER=$1
PASSWORD=$2
setupPackages(){
	yum install vsftpd -y -q

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
	chown -R ftpuser:ftpaccess /ftpfiles/
	
	
	
}
setupFTP(){
	sed -i s/anonymous_enable=YES/anonymous_enable=NO/g /etc/vsftpd/vsftpd.conf
	sed -i s/#chroot_local_user=YES/chroot_local_user=YES/g /etc/vsftpd/vsftpd.conf 
	echo "ec2-user" >> /etc/vsftpd/user_list
	echo "pasv_enable=YES" >> /etc/vsftpd/vsftpd.conf
	echo "pasv_min_port=1024" >> /etc/vsftpd/vsftpd.conf
	echo "pasv_max_port=1048" >> /etc/vsftpd/vsftpd.conf
	echo "pasv_address=$(curl http://169.254.169.254/latest/meta-data/public-ipv4/)" >> /etc/vsftpd/vsftpd.conf
	echo "ec2-user" >> /etc/vsftpd/user_list
}

setupUsers(){
	useradd $USER
	usermod -d /ftpfiles/$USER -s /sbin/nologin -g ftpaccess $USER
	echo $PASSWORD | passwd $USER --stdin
	mkdir /ftpfiles/$USER
	chown -R $USER:ftpaccess /ftpfiles/$USER

}

setupCommands(){

	echo "Setting up commandline alias"
	mkdir /ftpscripts/
	# curl -L -s -o /ftpscripts/ftpadd.sh https://raw.githubusercontent.com/dragonlegs/CFFTP/master/FTPADD.sh
	# curl -L -s -o /ftpscripts/ftpdel.sh https://raw.github.com/dragonlegs/CFFTP/blob/master/FTPDEL.sh
	wget -O /ftpscripts/ftpadd.sh -q https://raw.githubusercontent.com/dragonlegs/CFFTP/master/FTPADD.sh
	wget -O /ftpscripts/ftpdel.sh -q https://raw.githubusercontent.com/dragonlegs/CFFTP/master/FTPDEL.sh
	chmod +x /ftpscripts/ftpadd.sh
	chmod +x /ftpscripts/ftpdel.sh
	echo "alias ftpadd='/ftpscripts/ftpadd.sh'" >> /root/.bashrc
	echo "alias ftpdel='/ftpscripts/ftpdel.sh'" >> /root/.bashrc
	
}

setupPackages
setupEBS
setupFTP
setupUsers
setupCommands
echo "Starting FTP"
service vsftpd start
chkconfig vsftpd on