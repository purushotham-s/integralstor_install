#!/bin/bash

if [[ $(firewall-cmd --state) != 'running' ]];
then
        echo "Firewalld is not running, starting and enabling Firewalld.."
        systemctl start firewalld &> /dev/null
        if [[ $? -gt 0 ]];
        then
                echo "Error starting Firewalld, exiting.."
                exit 1
        fi      
        systemctl enable firewalld &> /dev/null
fi

if [[ $(firewall-cmd --get-default-zone) != 'public' ]];
then
        echo 'Default zone is not public'
        firewall-cmd --set-default-zone=public
        echo 'Default zone changed to public'
fi

ports=(20 21 22 25 53 80 111 131 139 389 443 445 465 548 873 1311 5666 55413 55414 35622 35623 35621 3260 8125 8000 8001 8002 8003 8443 19999)

for port in ${ports[@]};
do
        firewall-cmd --zone=public --permanent --add-port=$port/tcp 
        firewall-cmd --zone=public --permanent --add-port=$port/udp
done

echo "Reloading firewalld"
firewall-cmd --reload
echo "Enabling SELinux in Permissive mode, effective from next reboot"
sed -i 's/SELINUX=disabled/SELINUX=permissive/' /etc/selinux/config
