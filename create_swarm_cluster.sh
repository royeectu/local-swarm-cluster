#!/bin/bash

# get number of managers & workers from cli
num_managers=$1
num_workers=$2

# validate params
if [ -z "$num_managers" ] || [ -z "$num_workers" ]
then
	echo "missing parameters"
	exit 1
fi

if [ $num_managers == 0 ]
then
	echo "cannot create a cluster when # of managers is less than 1. you need to have at least 1 manager"
	exit 1
fi

# verify that docker-machine is installed
if [ ! -f /usr/local/bin/docker-machine ]
then
	echo "could not locate docker-machine. quitting...."
	exit 1
fi 

# create managers
for manager in $(seq $num_managers);
do
	echo "creating swarm manager-$manager"
	echo "==============================="
       	docker-machine create -d "virtualbox" manager-$manager
done

# create workers
for worker in $(seq $num_workers)
do
        echo "creating swarm worker-$worker"
        echo "============================="
        docker-machine create -d "virtualbox" worker-$worker
done

# create cluster
echo "creating cluster"
echo "================"
# joining managers
for manager in $(seq $num_managers);
do
	if [ $manager == 1 ]
	then
		# 1st manager
		docker-machine ssh manager-$manager docker swarm init --advertise-addr=eth1
		manager_join_cmd=`docker-machine ssh manager-$manager docker swarm join-token manager | grep -i join -A2`
		manager_join_cmd_one_line=`echo $manager_join_cmd`
		worker_join_cmd=`docker-machine ssh manager-$manager docker swarm join-token worker | grep -i join -A2`
		worker_join_cmd_one_line=`echo $worker_join_cmd`
	else
		# additional managers
		echo "joining manager-$manager to the cluster"
		echo "======================================="
		docker-machine ssh manager-$manager eval ${manager_join_cmd_one_line}
	fi
done

# joining workers
for worker in $(seq $num_workers);
do
	echo "joining worker-$worker to the cluster"
	echo "====================================="
	docker-machine ssh worker-$worker eval ${worker_join_cmd_one_line}
	echo ""
done

# display the cluster
echo "the cluster is ready: there are $num_managers managers and $num_workers workers:"
docker-machine ssh manager-1 docker node ls
