#!/bin/bash

#start docker if docker server is not running
sudo systemctl status docker || sudo systemctl start docker
script_usage=$"./scripts/psql_docker.sh start|stop|create [db_username][db_password]"

#echo "$script_usage"

task=$1
db_username=$2
db_password=$3

container_exist=$(docker container ls -a -f name=jrvs-psql | wc -l)

#echo " $container_exist "

# check if container exit
case $task in
	create)
    	
	if [[ container_exist -eq 2 ]];
	then
		echo "Container already exist $script_usage"
	exit 0
	fi

	if [[ "$#" != 3 ]]
	then
      echo "db_username or db_password is not passed through CLI arguments"
      exit 1
  fi

	#create `pgdata` volume

	docker volume create pgdata
	docker run --name jrvs-psql -e POSTGRES_PASSWORD= "$db_password" -e POSTGRES_USER= " $db_username" -d -v pgdata:/var/lib/postgresql/data -p 5432:5432 postgres
	exit $?

  #checking if container is created

  #again checking the container_exist variable
	container_exist=$(docker container ls -a -f name=jrvs-psql | wc -l)

	if [[ container_exist -ne 2 ]] ;
	then
		echo "Container not created $script_usage"
	  exit 1
	fi
  ;;
	
	start)
	docker container start jrvs-psql
	exit $?
	;;
	

	stop)
	docker container stop jrvs-psql
	exit $?
	;;

	*) # default case
	echo "Error: The command is invalid"
 	exit 1
	;;

esac


