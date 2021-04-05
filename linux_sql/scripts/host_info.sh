#!/bin/bash

host=$1
port_num=$2
db_name=$3
psql_user=$4
export PGPASSWORD=$5


if [ "$#" -ne 5 ];
  then
    echo "Not enough number of arguments passed"
    exit 0
fi

lscpu_out=$(lscpu)

hostname=$(hostname -f)
total_memory=$(cat /proc/meminfo)

hostname=$(hostname -f)
cpu_number=$(echo "$lscpu_out"  | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out"  | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out"  | egrep "^Model name:" | awk -F: '{print $2}' | xargs)
cpu_mhz=$(echo "$lscpu_out"  | egrep "^CPU MHz:" | awk -F: '{print $2}' | xargs)
l2_cache=$(echo "$lscpu_out"  | egrep "^L2 cache:" | awk -F: '{print $2}' | tr -d K | xargs)
total_mem=$(echo "$total_memory"  | egrep "^MemTotal:" | awk '{print $2}' | tr -d KB | xargs)
timestamp=$(date +"%Y-%m-%d %T")


insert_stmt="INSERT INTO host_info (hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, L2_cache, total_mem, timestamp)
VALUES ('$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', $cpu_mhz, $l2_cache, $total_mem, '$timestamp')"

#insert data in the host_agent database using insert statement
psql -h $host -p $port_num -d $db_name -U $psql_user -c "$insert_stmt"
exit $?




