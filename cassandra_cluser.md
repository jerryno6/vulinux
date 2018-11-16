## Deploy cassandra nodes using “GossipingPropertyFileSnitch” across Virtual machines:


**Step 1 On 1st machine, IP: 172.16.10.250**

`docker run --name cas1 -d -e CASSANDRA_BROADCAST_ADDRESS=172.16.10.250 -p 172.16.10.250:7000:7000 -p 172.16.10.250:7001:7001 -p 172.16.10.250:9042:9042 -p 172.16.10.250:7199:7199 -p 172.16.10.250:9160:9160 -e CASSANDRA_CLUSTER_NAME=MyCluster -e CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch -e CASSANDRA_DC=datacenter1 cassandra:3.11`

docker run --name cas2 -p 172.16.10.250:9043:9042 -e CASSANDRA_SEEDS="$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' cas1)" -e CASSANDRA_CLUSTER_NAME=MyCluster -e CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch -e CASSANDRA_DC=datacenter1 -d cassandra:3.11

**Step 2 On 2nd machine, IP: 172.16.10.141**

`docker run --name cas3 -d -e CASSANDRA_BROADCAST_ADDRESS=172.16.10.141 -p 172.16.10.141:7000:7000 -p 172.16.10.141:7001:7001 -p 172.16.10.141:9042:9042 -p 172.16.10.141:7199:7199 -p 172.16.10.141:9160:9160 -e CASSANDRA_CLUSTER_NAME=MyCluster -e CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch -e CASSANDRA_DC=datacenter2 -e CASSANDRA_SEEDS=172.16.10.250 cassandra:3.11`

**Step 3**

we can check the result by using this command in 1st machine 

`docker exec -ti cas1 nodetool status`

References:
[http://gokhanatil.com/2018/02/build-a-cassandra-cluster-on-docker.html](http://gokhanatil.com/2018/02/build-a-cassandra-cluster-on-docker.html)
