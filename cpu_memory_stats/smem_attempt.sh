#a shell script to write CPU and Memory usage for a single process, derived from the ps command
#Execution: ./ps_process_stats.sh <process_name> <path_to_output_file> 
#!/bin/bash

PNAME1="$1"
PNAME2="$1"
LOG_FILE="$2"

: '
while true ; do
   #echo "$(date),$PNAME[$(pidof ${PNAME})] $(ps -C ${PNAME} -o %cpu -o %mem | tail -1)%" >>
    echo "$(date)"," $(ps -C ${PNAME} -o rss,%mem,%cpu,pid,command)" >> $LOG_FILE
    sleep 1
done
'

#echo "1234" | sudo -S systemctl start ${service}

while true ; do
    echo "$(date)"," $(echo "1234" | sudo smem --mapfilter="php" -t | tail -n 1)" >> $LOG_FILE
    echo "$(date)"," $(echo "1234" | sudo smem --mapfilter="apache" -t | tail -n 1)" >> $LOG_FILE
    sleep 5
done    
