#INSTALL DOCKER
#uninstall old version if needed
sudo apt-get remove docker docker-engine docker.io  

#update apt package index
sudo apt-get update   

#allow use repository over https
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common    

#add docker official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

#verify key
sudo apt-key fingerprint 0EBFCD88

#add stable version of docker
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

#update apt index
sudo apt-get update

#install docker, auto answer yes 
sudo apt-get -y install docker-ce

#verify version of docker
sudo docker --version

#INSTALL DOCKER COMPOSE
#download latest docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

#allow excutable permission on directory
sudo chmod +x /usr/local/bin/docker-compose

#check version docker compose
docker-compose --version

#INSTALL DOTNET CORE
#install libicu 55
#if you are running ubuntu 18.04.1, you need to install libicu55
sudo add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"
sudo apt-get update
sudo apt-get install libicu55

#install dotnet sdk
wget -q https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb

sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get -y install dotnet-sdk-2.1

#install azure cli
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    sudo tee /etc/apt/sources.list.d/azure-cli.list

#get microsoft signing key
curl -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

#install azcli
sudo apt-get update
sudo apt-get -y install apt-transport-https azure-cli

#to login az, use below command line
#az login -u <username> -p <password>
