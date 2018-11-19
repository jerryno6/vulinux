## Deploy cassandra nodes using “GossipingPropertyFileSnitch” across Virtual machines:


**Step 1 On 1st machine, IP: 172.16.10.250**

`docker run --name cas1 -d -e CASSANDRA_BROADCAST_ADDRESS=172.16.10.250 -p 172.16.10.250:7000:7000 -p 172.16.10.250:7001:7001 -p 172.16.10.250:9042:9042 -p 172.16.10.250:7199:7199 -p 172.16.10.250:9160:9160 -e CASSANDRA_CLUSTER_NAME=MyCluster -e CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch -e CASSANDRA_DC=datacenter1 cassandra:3.11`

`docker run --name cas2 -p 172.16.10.250:9043:9042 -e CASSANDRA_SEEDS="$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' cas1)" -e CASSANDRA_CLUSTER_NAME=MyCluster -e CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch -e CASSANDRA_DC=datacenter1 -d cassandra:3.11`

Or we can run 2 command lines to get the IP of container in docker network
get IP of cas1, it could return an IP of container ex: 192.168.1.5, then run docker with the IP we've got

`docker inspect --format='{{ .NetworkSettings.IPAddress }} cas1` 
`docker run --name cas2 -p 172.16.10.250:9043:9042 -e CASSANDRA_SEEDS=192.168.1.5 -e CASSANDRA_CLUSTER_NAME=MyCluster -e CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch -e CASSANDRA_DC=datacenter1 -d cassandra:3.11`

**Step 2 On 2nd machine, IP: 172.16.10.141**

`docker run --name cas3 -d -e CASSANDRA_BROADCAST_ADDRESS=172.16.10.141 -p 172.16.10.141:7000:7000 -p 172.16.10.141:7001:7001 -p 172.16.10.141:9042:9042 -p 172.16.10.141:7199:7199 -p 172.16.10.141:9160:9160 -e CASSANDRA_CLUSTER_NAME=MyCluster -e CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch -e CASSANDRA_DC=datacenter2 -e CASSANDRA_SEEDS=172.16.10.250 cassandra:3.11`

**Step 3**

we can check the result by using this command in 1st machine 

`docker exec -ti cas1 nodetool status`

## Deploy cassandra nodes using “GossipingPropertyFileSnitch” on the same machines for local testing with bridge networks:

`docker network create --driver bridge incident_playground
docker run -itd --name cas0 --net-alias cassandra0 --net incident_playground -e CASSANDRA_DC=dev -e CASSANDRA_RACK=rack0 -e CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch -p 9042:9042 cassandra:3.11
docker run -itd --name cas1 --net-alias cassandra1 --net incident_playground -e CASSANDRA_DC=dev -e CASSANDRA_RACK=rack1 -e CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch -p 9043:9042 -e CASSANDRA_SEEDS=cassandra0 cassandra:3.11
docker run -itd --name cas2 --net-alias cassandra2 --net incident_playground -e CASSANDRA_DC=dev -e CASSANDRA_RACK=rack2 -e CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch -p 9044:9042 -e CASSANDRA_SEEDS=cassandra0 cassandra:3.11`

## Ports which is used by cassandra
7199 - JMX (was 8080 pre Cassandra 0.8.xx)
7000 - Internode communication (not used if TLS enabled)
7001 - TLS Internode communication (used if TLS enabled)
9160 - Thrift client API
9042 - CQL native transport port

References:
[http://gokhanatil.com/2018/02/build-a-cassandra-cluster-on-docker.html](http://gokhanatil.com/2018/02/build-a-cassandra-cluster-on-docker.html)
