#a shell script to write CPU and Memory usage for a single process, derived from the ps command
#Execution: ./ps_process_stats.sh <process_name> <path_to_output_file> 
#!/bin/bash

PNAME="$1"
LOG_FILE="$2"

while true ; do
   #echo "$(date),$PNAME[$(pidof ${PNAME})] $(ps -C ${PNAME} -o %cpu -o %mem | tail -1)%" >> $LOG_FILE
    echo "$(date),$PNAME[$(pidof ${PNAME})],$(ps -C ${PNAME} -o %cpu -o %mem | tail -1)" >> $LOG_FILE
    sleep 1
done
