#update
sudo apt update && apt upgrade -y

#install dependencies
sudo apt install openjdk-8-jdk -y
sudo apt install python -y

#download cassandra
wget http://apache.claz.org/cassandra/3.11.3/apache-cassandra-3.11.3-bin.tar.gz

#untar it, and move to a better home
sudo tar -xzvf apache-cassandra-3.11.3-bin.tar.gz
sudo mv apache-cassandra-3.11.3 /usr/local/cassandra

#create cassandra user
sudo useradd cassandra
sudo groupadd cassandra
sudo usermod -aG cassandra cassandra
sudo chown root:cassandra -R /usr/local/cassandra/
sudo chmod g+w -R /usr/local/cassandra/

su - cassandra
/usr/local/cassandra/bin/cassandra -f
