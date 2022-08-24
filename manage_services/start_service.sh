#!/bin/bash

#check if service is running

#Remember: 0 is true in bash!
if  pidof apache2 > /dev/null
then
   echo "service is already running"
else
   #start a service
   echo "1234" | sudo -S systemctl start apache2
   sleep 3
fi

#check if service is running
systemctl status apache2 | grep 'active (running)' > /dev/null 2>1%

#grep returns 0 if pattern is found(true) and 1 if the pattern not found
if [ $? != 0 ]
then
        echo "Service is not running"
        exit
fi

echo "service is running"

#system reboots. However password is still required to login

#echo "1234" | sudo -S reboot
