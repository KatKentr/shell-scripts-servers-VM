#!/bin/bash

#Execution: start_service.sh <server_name> <test_params_file> <test_case> <test_name>

service="$1"

fileIs="$2"

line_no=$3

testName="$4"


source parse_functions

#retrieve test case: users,rampup,number of requests as a string 
testCase=$(getTestCase $fileIs $line_no)

# Set comma as delimiter
IFS=','

#Read the split words into an array based on comma delimiter
read -a strarr <<< "$testCase"


#assign to variables

users=${strarr[0]}
rampup=${strarr[1]}
requests=${strarr[2]}

#create directory to store server side test results(if it does not exist)
dateIs=$(date +"%Y_%m_%d")
#mkdir ~/Desktop/test_results/${service}_results/${testName}/${users}_users/${dateIs}
mkdir /media/sf_test_results/${testName}/${service}/${users}_users
mkdir /media/sf_test_results/${testName}/${service}/${users}_users/${dateIs}



#directory to move the result file(not implemented yet)
dateIs=$(date +"%Y_%m_%d")
pathIs=/media/sf_test_results/${testName}/${service}/${users}_users/${dateIs}



#write values to the common file, so that client machine can read it
sed -i "s/serverName=.*/serverName=${service}/" /media/sf_shared_between-VMs/notify_status.sh
sed -i "s/users=.*/users=${users}/" /media/sf_shared_between-VMs/notify_status.sh
sed -i "s/rampup=.*/rampup=${rampup}/" /media/sf_shared_between-VMs/notify_status.sh
sed -i "s/requests=.*/requests=${requests}/" /media/sf_shared_between-VMs/notify_status.sh
sed -i "s/var=.*/var=${testName}/" /media/sf_shared_between-VMs/notify_status.sh

#Print the splitted words
echo "users : ${strarr[0]}"
echo "rampup : ${strarr[1]}"
echo "requests: ${strarr[2]}"


#check if service is running

#Remember: 0 is true in bash!
if  pidof ${service} > /dev/null
then
   echo "$service is already running"
else
   #start a service
   echo "1234" | sudo -S systemctl start ${service}
   sleep 300
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


#add php to memory monitoring
if [ $service="apache2" ] || [ $service="nginx" ] ;
then
  PNAME2="php-fpm"
fi

PNAME1=$service

LOG_FILE=${pathIs}/output_smem_stats_${testName}_${users}_$(date +"%Y.%m.%d-%H.%M.%S").csv


sleep 4s

#retrieve value of the variable testStatus
testStatus=$(awk -F'=' '/^testStatus/ {print $2}' /media/sf_shared_between-VMs/notify_status.sh)
echo $testStatus

#wait until testStatus turns to 0 (end of test)
while [ $testStatus -eq 1 ]
do
 echo "$(date)","${PNAME1}"," $(echo "1234" | sudo smem -c "pss" --mapfilter=${PNAME1} -t | tail -n 1)" >> $LOG_FILE
 echo "$(date)","${PNAME2}"," $(echo "1234" | sudo smem -c "pss" --mapfilter=${PNAME2} -t | tail -n 1)" >> $LOG_FILE
 testStatus=$(awk -F'=' '/^testStatus/ {print $2}' /media/sf_shared_between-VMs/notify_status.sh)
 sleep 10
done


echo "$testStatus ,test  is over"


#stop server
echo "1234" | sudo -S systemctl stop ${service}
   

sleep 5s

# another way to kill the process, it worked by executing with bash.Thought: Could it work with source?
#kill -SIGTERM $pidIs          # Give the process a chance to shut down
#kill -SIGKILL $pidIs         

#echo "memory monitoring terminated"


#system reboots. However password is still required to login

#echo "1234" | sudo -S reboot
