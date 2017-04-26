# Create Swarm Cluster

The script uses docker-machine in order to create and configure a Swarm cluster of managers and workers

## Requirements:
1. docker
2. docker-machine
3. Oracle Virtual Box

## Usage:
The following script takes 2 arguments:

- num-managers
- num-workers

For example, in order to create a Swarm cluster of 3 managers and 2 workers run: **_create\_swarm\_cluster.sh 3 2_**
