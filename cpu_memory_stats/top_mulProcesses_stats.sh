#a shell script to write CPU and Memory usage for a single process, derived fro>
#Execution: ./top_process_stats.sh <process_name> <path_to_output_file>
#Example: ./top_process_stats.sh firefox output_top_bash.txt 
#!/bin/bash
PNAME1="$1"
LOG_FILE="$2"
PID1=$(pgrep ${PNAME1} -d ',')
if [ $PNAME1="apache2" ] || [ $PNAME1="nginx" ] ;
then
  PNAME2="php-fpm"
  PID2=$(pgrep ${PNAME2} -d ',')
  PID="${PID1},${PID2}"
else
PID=$PID1
fi

#PID=$(pidof ${PNAME})

top -b -d 1 -p $PID | awk \
    -v cpuLog="$LOG_FILE" -v pid="$PID" -v pname="$PNAME" '
    /^top -/{time = $3}
    $1+0>0 {printf "%s;%s;%s[%s];VIRT(KiB);%.0f;RES(KiB);%.0f;SHR(KiB);%.0f;CPU_Usage;%.1f;Mem_Usage;%.1f\n", \
            strftime("%Y-%m-%d"), time, $12, $1,$5,$6,$7, $9, $10 > cpuLog
            fflush(cpuLog)}'

