#!/bin/bash

#Execution: start_service.sh <server_name>

service="$1"

now=$(date +"%Y.%m.%d-%H.%M.%S")

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

#source ~/Desktop/shell_scripts_VM_Servers/cpu_memory_stats/top_mulProcesses_stats.sh ${service} output_top_mulProcesses_stats_${now}.csv

#start the script in the background and give back control to the script start_service.sh
bash ~/Desktop/shell_scripts_VM_Servers/cpu_memory_stats/top_mulProcesses_stats.sh ${service} output_top_mulProcesses_stats_${now}.csv &

pidIs=$!
echo $pidIs

sleep 3s

# another way to kill the process, it worked by executing with bash.Thought: Could it work with source?
#kill -SIGTERM $pidIs          # Give the process a chance to shut down
#kill -SIGKILL $pidIs         

# to get a process name for a shell script it needs to be executed with bash, otherwise command name is bash
pkill -f top_mulProcesses_stats.sh

echo "memory monitoring terminated"


#system reboots. However password is still required to login

#echo "1234" | sudo -S reboot
