#!/bin/bash

#Execution: start_service.sh <server_name>

service="$1"

#check if service is running

#Remember: 0 is true in bash!
if  pidof ${service} > /dev/null
then
   echo "$service is already running"
else
   #start a service
   echo "1234" | sudo -S systemctl start ${service}
   sleep 3
fi

#check if service is running
systemctl status ${service} | grep 'active (running)' > /dev/null 2>1%

#grep returns 0 if pattern is found(true) and 1 if the pattern not found
if [ $? != 0 ]
then
        echo "$service is not running"
        exit
fi

echo "$service is running"

#change status of the variable to notify client,  (an attempt to work with a shared variable in a shared file for communication between the two VMs)
sed -i 's/serverOn=.*/serverOn=1/' /media/sf_shared_between-VMs/notify_status.sh


#system reboots. However password is still required to login

#echo "1234" | sudo -S reboot
