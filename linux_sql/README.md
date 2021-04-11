# Linux Cluster Monitoring Agent
This project is under development. Since this project follows the GitFlow, the final work will be merged to the master branch after Team Code Team.

## Introduction
The Linux Cluster Monitoring Agent is a tool to monitor, analyze and collect data from host machines in a 10 node cluster using CentOS 7 over a network using IPv4 through switch.The hardware specifications and CPU usage of the Linux machines is stored in a PostgreSQL database which is provisioned using docker container in the monitoring agent. All the nodes in the cluster have the bash scripts which collects the hardware specifications and usage data and sends it to the database; the CPU usage data is sent every one minute which is scheduled using crontab to get the real time data for real time analysis. The collected data is used to provide statistics for better business decisions and resource planning.

## Quick Start

* Start a psql instance using psql_docker.sh
```
./scripts/psql_docker.sh create [db_username] [db_password]
```
* Create tables using ddl.sql
```
psql -h localhost -U postgres -d host_agent -f sql/ddl.sql
```
* Insert hardware specs data into the db using host_info.sh
```
bash host_info.sh localhost 5432 host_agent postgres password
```
* Insert hardware usage data into the db using host_usage.sh
```
    1. bash host_usage.sh localhost 5432 host_agent postgres password
    2. use in crontab
```
* Crontab setup
```
   # edit cronjobs
     crontab -e 
   # add to crontab
     * * * * * bash <your path>/scripts/host_usage.sh localhost 5432 host_agent postgres password > /tmp/host_usage.log
```
## Implemenation
A psql_docker.sh script creates a psql container using docker to host the postgreSQL database in the monitoring agent node where the other nodes are connected by switch through IPv4.

The database host_agent was then setup using PostgreSQL command line interface using DDL SQL queries. Using ddl.sql the tables host_info and host_usage were created in the host_agent database for storing hardware specifications and CPU and memory usage information respectively.

The bash scripts were created for automation purposes, host_info is created to insert host hardware information into the host_info table and host_usage script is created to insert host resource usage data into host_usage table.

The queries.sql using DML SQL queries was created to retrieve information from the two tables to help answer the business question for better resource planning.

## Architecture

![arch](https://user-images.githubusercontent.com/60118930/113667571-fd05e600-967e-11eb-8e00-09a356272213.PNG)


## Script

### 1.psql_docker.sh 
  Depending on the commands function like create, start, stop are performed

  Command: ```bash psql_docker.sh [command] [password] [db_username]```

### 2.host_info.sh
  checking the table exists or not, and adding a row.

  Command: ```bash host_info.sh [psql_host] [psql_port] [db_name] [db_username] [db_password]```

### 3.host_usage.sh
  checking the table exists or not, and adding a row.

  Command: ```bash host_usage.sh [psql_host] [psql_port] [db_name] [db_username] [db_password]```

### 4.crontab
  checking the table exists or not, and adding a row.

  Command: 

```
   # edit cronjobs
     crontab -e 
   # add to crontab
     * * * * * bash <your path>/scripts/host_usage.sh localhost 5432 host_agent postgres password > /tmp/host_usage.log
```
### 5.ddl.sql 
Creates host_info and host_usage tables to store hardware specification data and linux usage data.
Command: 
``` #execute a sql file using psql command
psql -h HOST_NAME -p 5432 -U USER_NAME -d DB_NAME -f FILE_NAME.sql
```

### 6.queries.sql 
These queries are for the infrastructure team to analyze the memory usage data and plan the resources in a better way.

1. Sorts the list of cluster nodes by number of CPUs and total memory. Through this the infrastructure team can determine the nodes which have more memory.
2. Represents the average percentage of memory used in every 5 minute intervals. Through this the team can figure out that which hosts are under utilized and which ones are over utilized.
3. Reports the nodes which fail to send every minute CPU usage status to the monitoring agent 3 times in 5 minutes. Through this the health of all the servers is checked.

## Database Modeling
The database host_agent consists of 2 tables:

* ```host_info``` contains the Hardware Specification data for each node.

host_info Table
| Columns | Values |
| --- | --- |
| id |SERIAL NOT NULL PRIMARY KEY |
| hostname | VARCHAR NOT NULL UNIQUE |
| cpu_number | INT NOT NULL |
| cpu_architecture | VARCHAR NOT NULL|
| cpu_model | VARCHAR NOT NULL|
| cpu_mhz | FLOAT NOT NULL|
| L2_cache | VARCHAR NOT NULL|
| total_mem | INT NOT NULL|
| timestamp | TIMESTAMP NOT NULL|

host_usage Table
| Columns | Values |
| --- | --- |
| timestamp |TIMESTAMP NOT NULL PRIMARY KEY |
| host_id | INT NOT NULL REFRENCES host_info(id) |
| memory_free | INT NOT NULL|
| cpu_idle | INT NOT NULL |
| cpu_kernel | INT NOT NULL |
| disk_io | INT NOT NULL |
| disk_available | VARCHAR NOT NULL |

## Test
1. The bash scripts were tested manually using command line to ensure the proper functioning of the scripts by verifying the number of arguments, expected errors got displayed and the exit code was successful.
2. The SQL queries were tested using test data to ensure the expected results were displayed.

## Improvements
1. More number of queries can be added for more analysis for better resource planning.
2. Visualization tools can be integrated to graphically represent the average resource utilization for easier understanding.
