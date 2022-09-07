#a shell script to write CPU and Memory usage for a single process, derived from the ps command
#Execution: ./ps_process_stats.sh <process_name> <path_to_output_file> 
#!/bin/bash

PNAME1="$1"
PNAME2="$2"
LOG_FILE="$3"

: '
while true ; do
   #echo "$(date),$PNAME[$(pidof ${PNAME})] $(ps -C ${PNAME} -o %cpu -o %mem | tail -1)%" >>
    echo "$(date)"," $(ps -C ${PNAME} -o rss,%mem,%cpu,pid,command)" >> $LOG_FILE
    sleep 1
done
'

#echo "1234" | sudo -S systemctl start ${service}

while true ; do
    echo "$(date)","${PNAME1}"," $(echo "1234" | sudo smem -c "pss" --mapfilter=${PNAME1} -t | tail -n 1)" >> $LOG_FILE
    echo "$(date)","${PNAME2}"," $(echo "1234" | sudo smem -c "pss" --mapfilter=${PNAME2} -t | tail -n 1)" >> $LOG_FILE
    sleep 5
done    
