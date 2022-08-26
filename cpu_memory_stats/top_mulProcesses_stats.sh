#a shell script to write CPU and Memory usage for a single process, derived fro>
#Execution: ./top_process_stats.sh <process_name> <path_to_output_file>
#Example: ./top_process_stats.sh firefox output_top_bash.txt 
#!/bin/bash
PNAME="$1"
LOG_FILE="$2"
PID=$(pgrep ${PNAME} -d ',')
#PID=$(pidof ${PNAME})

top -b -d 1 -p $PID | awk \
    -v cpuLog="$LOG_FILE" -v pid="$PID" -v pname="$PNAME" '
    /^top -/{time = $3}
    $1+0>0 {printf "%s;%s;%s[%s];VIRT(KiB);%.0f;RES(KiB);%.0f;SHR(KiB);%.0f;CPU_Usage;%.1f;Mem_Usage;%.1f\n", \
            strftime("%Y-%m-%d"), time, $12, $1,$5,$6,$7, $9, $10 > cpuLog
            fflush(cpuLog)}'

