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


vm_static_t=$(vmstat -t)
vm_static_d=$(vmstat -d)
vmstat_out_m=$(vmstat -S m)
disk_output=$(df -BM /)
vmstat_output=$(vmstat)

hostname=$(hostname -f)
timestamp=$(echo "$vm_static_t" | awk '{print  $18, $19}' | egrep "^[0-9]" )
memory_free=$(echo "$vmstat_out_m" | awk '{print $4}' | egrep "^[0-9]")
cpu_idle=$(echo "$vmstat_output" | awk '{print $15}' | egrep "^[0-9]")
cpu_kernel=$(echo "$vmstat_output" | awk '{print $14}' | egrep "^[0-9]")
disk_io=$(echo "$vm_static_d" | awk '{print $10}' | egrep "^[0-9]")
disk_available=$(echo "$disk_output" | awk '{print $4}' | egrep "^[0-9]" | tr -d M)


insert_stmt="INSERT INTO host_usage (timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available)
VALUES ('$timestamp', (SELECT id FROM host_info WHERE hostname = '$hostname'), $memory_free, $cpu_idle, $cpu_kernel, $disk_io, $disk_available)"

#insert data in the host_agent database using insert statement

psql -h $host -p $port_num -U $psql_user -d $db_name -c "$insert_stmt"

exit $?