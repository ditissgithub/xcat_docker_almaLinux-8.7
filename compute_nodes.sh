#!/bin/bash
#path=$pwd
#mkdir /root/os_dir
#cd os_dir
#echo "Want to download linux_iso yes or no :"
#read userinput
#echo "which linux want to download Centos 7.9 or Alma 8.6"
#echo "For Centos 7.9 enter c else a:"
#read linux

#if [[ ( $userinput == "yes" && $linux == "c" )]]
#wget https://ftp.riken.jp/Linux/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-DVD-2207-02.iso
#else
#wget http://mirrors.hostever.com/almalinux/8.6/isos/x86_64/AlmaLinux-8.6-x86_64-boot.iso
#fi

echo "Enter the path of os directory:"
read os_pwd
copycds $os_pwd/*
echo "edit xcat database"
echo "Enter the domain:"
read domain
chdef -t site domain=$domain
echo "Enter the dhcpinterface:"
read dhcpinterface
chdef -t site dhcpinterfaces=$dhcpinterface

echo "Create a definition for compute nodes:"
echo "Enter the name of compute nodes "
read cn
echo "Enter the ip(in dhcp network) for cn:"
read ip
echo "Enter the mac address of compute nodes:"
read mac_add

mkdef -t node $cn groups=compute,all cons=ipmi ip=$ip netboot=xnba installnic=mac primarynic=mac mac=$mac_add postscripts="confignetwork -s"

makehosts
makedhcp -n
makedns -n
makedns -a
makedhcp -a

os_image=$(lsdef -t osimage | awk '{print $1}' | grep netboot)

#echo "enter the usernamae for access compute node:"
#read -p "username"
#echo "enter the password:"
#read -s "password1"
#echo "enter the password again:"
#read -s "password2"
#for i in {1}
#do
#   if [ $(password$i) == $(password$i+1)]then
#      echo "password is ok"
#      i++
#   else
 #     i=i-1
#   fi
#done

chtab key=system passwd.username=root passwd.password=root

genimage $os_image

# Define path for xCAT synclist file
mkdir -p /install/custom/netboot
chdef -t osimage -o $os_image synclists="/install/custom/netboot/compute.synclist"
# Add desired credential files to synclist
echo "/etc/passwd -> /etc/passwd" > /install/custom/netboot/compute.synclist
echo "/etc/group -> /etc/group" >> /install/custom/netboot/compute.synclist
echo "/etc/shadow -> /etc/shadow" >> /install/custom/netboot/compute.synclist


packimage $os_image

nodeset $cn osimage=$os_image

updatenode compute -F
