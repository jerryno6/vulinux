#https://www.rosehosting.com/blog/how-to-install-apache-cassandra-on-ubuntu-16-04/
#update
sudo apt update && apt upgrade -y

#install dependencies
sudo apt-get install default-jdk -y

curl https://www.apache.org/dist/cassandra/KEYS | sudo apt-key add -
sudo apt-key adv --keyserver pool.sks-keyservers.net --recv-key A278B781FE4B2BDA

sudo apt-get update
sudo apt-get install cassandra

#start, stop  cassandra
#sudo systemctl start cassandra.service
#sudo systemctl stop cassandra.service


#start as service
#sudo systemctl enable cassandra.service

#test cassandra
#su - cassandra
#/usr/local/cassandra/bin/cassandra -f
#/usr/local/cassandra/bin/cqlsh localhost
#select cluster_name, listen_address from system.local;
