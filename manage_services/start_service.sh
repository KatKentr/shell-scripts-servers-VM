#!/bin/bash

#Execution: start_service.sh <server_name> <test_params_file> <test_case> <test_name>

service="$1"

fileIs="$2"

line_no=$3

#testname. later to be included in the test cases file

testName="$4"

#create directory to store server side test results(if it does not exist)
dateIs=$(date +"%Y_%m_%d")
mkdir ~/Desktop/test_results/${serverName}_results/${dateIs}

source parse_functions

#retrieve test case: users,rampup,number of requests as a string 
testCase=$(getTestCase $fileIs $line_no)

# Set comma as delimiter
IFS=','

#Read the split words into an array based on comma delimiter
read -a strarr <<< "$testCase"

#Print the splitted words
echo "users : ${strarr[0]}"
echo "rampup : ${strarr[1]}"
echo "requests: ${strarr[2]}"

#assign to variables

users=${strarr[0]}
rampup=${strarr[1]}
requests=${strarr[2]}

#write values to the common file, so that client machine can read it

sed -i "s/users=.*/users=${users}/" /media/sf_shared_between-VMs/notify_status.sh
sed -i "s/users=.*/rampup=${rampup}/" /media/sf_shared_between-VMs/notify_status.sh
sed -i "s/requests=.*/requests=${requests}/" /media/sf_shared_between-VMs/notify_status.sh


#now=$(date +"%Y.%m.%d-%H.%M.%S")

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

#start memory monitoring

#source ~/Desktop/shell_scripts_VM_Servers/cpu_memory_stats/top_mulProcesses_stats.sh ${service} output_top_mulProcesses_stats_${now}.csv

#start the script in the background and give back control to the script start_service.sh
bash ~/Desktop/shell_scripts_VM_Servers/cpu_memory_stats/top_mulProcesses_stats.sh ${service} ~/Desktop/test_results/${service}_results/${dateIs}/output_top_mulProcesses_stats_${testName}_${users}_$(date +"%Y.%m.%d-%H.%M.%S").csv &

pidIs=$!
echo $pidIs

#retrieve value of the variable testStarted
testStatus=$(awk -F'=' '/^testStatus/ {print $2}' /media/sf_shared_between-VMs/notify_status.sh)
echo $testStatus

#wait until testStatus turns to 0 (end of test)

while [ $testStatus -eq 1 ]
do
 testStatus=$(awk -F'=' '/^testStatus/ {print $2}' /media/sf_shared_between-VMs/notify_status.sh)
done

#Since test is over kill memory monitoring script. (to get a process name for a shell script it needs to be executed with bash, otherwise command name is bash). 
pkill -f top_mulProcesses_stats.sh

echo "$testStatus ,test  is over"


#sleep 3s

# another way to kill the process, it worked by executing with bash.Thought: Could it work with source?
#kill -SIGTERM $pidIs          # Give the process a chance to shut down
#kill -SIGKILL $pidIs         

#echo "memory monitoring terminated"


#system reboots. However password is still required to login

#echo "1234" | sudo -S reboot
