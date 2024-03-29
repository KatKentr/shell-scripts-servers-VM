
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


#directory to save the results

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

PNAME=$service

#echo "service is: ${service}"

if [ "$service" = "apache2" ] || [ "$service" = "nginx" ]; then

   #add php to memory monitoring
   
     echo "in apache2,nginx block"

     PNAME2="php-fpm8.1"
     #PNAME=$PNAME","$PNAME2  eskage error to ps den to anagnwrize
     #echo "$PNAME"
     
       #Remember: 0 is true in bash!
   if  pidof ${service} > /dev/null
   then
       echo "$service is already running"
   else
      #start a service
      echo "1234" | sudo -S systemctl start ${service}
      sleep 1s
   fi
   
   #check if service is running
   systemctl status ${service} | grep 'active (running)' > /dev/null 2>1%
   
   #grep returns 0 if pattern is found(true) and 1 if the pattern not found
   if [ $? != 0 ]
   then
        echo "$service is not running"
        exit
   fi

   
elif [ "$service" = "go" ]; then

 echo "in go block"
 #name of the binary file, in the case of the Go server
 PNAME="server"
 
 #start go server
 cd ~/goProjects/serverProject/server
 
 ./${PNAME} -testcase=${testName} &
 
 pidServer=$!
 
 sleep 1s

#this is the case of nodejs
else

 echo "in node block"

 cd ~/nodeProjects/myserver/
 
 #start node server
 ${PNAME} server.js &
 pidServer=$!
 
 sleep 2s
 
fi

echo "$service is running"

#PNAME1=$service

LOG_FILE1=${pathIs}/${users}Users_${testName}_$(date +"%Y.%m.%d-%H.%M.%S")_stats_cpu.csv
LOG_FILE2=${pathIs}/${users}Users_${testName}_$(date +"%Y.%m.%d-%H.%M.%S")_stats_mem.csv

#start cpu monitoring every 10 seconds
vmstat -t -n 1 >> $LOG_FILE1 &

#retrive id of the process
pidIs=$!

sleep 1s

#retrieve value of the variable testStatus
testStatus=$(awk -F'=' '/^testStatus/ {print $2}' /media/sf_shared_between-VMs/notify_status.sh)
echo $testStatus

#initialize number of samples
count=0

#start memory monitoring and wait until testStatus turns to 0 (end of test)
while [ $testStatus -eq 1 ]
do
 echo "d-$(date +"%Y.%m.%d-%H.%M.%S")","$(ps -C ${PNAME} -o rss)" >> $LOG_FILE2
 ((count++))
 testStatus=$(awk -F'=' '/^testStatus/ {print $2}' /media/sf_shared_between-VMs/notify_status.sh)
 sleep 1
done

echo "$count ","samples" >> $LOG_FILE2

#stop monitoring of CPU
kill -9 $pidIs

echo "$testStatus ,test  is over"

#stop server
if [ "$service" = "apache2" ] || [ "$service" = "nginx" ]; then

   echo "toping ngin or apache2"
   echo "1234" | sudo -S systemctl stop ${service}
   
else
   #one process
   #kill -9 $pidServer
   
   #many processes
   killall ${PNAME} -9
     
fi

sleep 1s

# another way to kill the process, it worked by executing with bash.Thought: Could it work with source?
#kill -SIGTERM $pidIs          # Give the process a chance to shut down
#kill -SIGKILL $pidIs         

#echo "memory monitoring terminated"


#system reboots. However password is still required to login

#echo "1234" | sudo -S reboot
