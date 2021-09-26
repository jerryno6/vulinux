
--------------docker cli
docker login -u <user> -p <pwd> odacitest.azurecr.io
docker network create --driver bridge my_network_playground
docker network rm my_network_playground
docker network connect my_network_playground container1    #connect a running container to network
docker network disconnect my_network_playground container1

~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux
docker ps

docker run -d --name some_name --net NAME_OF_NETWORK abc.com/cassandra:3.11
docker run -d --name some_name abc.com/cassandra:3.11
docker run -d -p 5000:5000 --name registry registry:2   #-p host:container
docker build -t ledangvu/ledangvu_hello_docker:1.0
docker run -d -p 5000:80 ledangvu/ledangvu_hello_docker:1.0
docker tag hello-world localhost:5000/hello-world:1.0
docker push ledangvu/ledangvu_hello_docker:1.0

docker inspect containerid  //see the port that docker using
docker build -t my_project .
docker run -it --rm -p 5000:80 --name myprojectTest MyProject
docker exec -it 79 bash

//copy file or folder between docker & host
docker cp foo.txt mycontainer:/foo.txt  
docker cp mycontainer:/foo.txt foo.txt  
docker cp src/. mycontainer:/target
docker cp mycontainer:/src/. target

docker stop $(docker ps -a -q)      #stop all containers quietly
docker rm $(docker ps -a -q)        #remove all containers quietly
docker rm MY_CONTAINER  #remove container
docker rmi IMAGE_NAME   #remove image
docker stats            #status of containers: ID|name|%cpu|%mem usage|NetIO|PIDS
docker inspect MY_CONTAINER #get details of container
docker logs -f MY_CONTAINER    #view log of containers & follow up until we stop it by Ctrl + C
docker inspect CONTAINER_ID | grep "IPAddress" #display container IP

docker volume ls        #list all volumes
docker volume prune     #delete not used volumes
docker system prune     #remove unused/dangling images, containers, volumes, networks

-------------- docker compose
docker-compose -f docker-compose.yml -f docker-compose.docker-compose.override.yml build -d
docker-compose build
docker-compose up  --Builds, (re)creates, starts, and attaches to containers for a service.
docker-compose start 
docker-compose logs -f SERVICE_NAME     #view log container

-------------- dotnet core command line
+ cd to folder of api Project run 2 command line
cd Projects/MyProject/Company.Helloworld
dotnet publish -c Release
dotnet run

-------------- Entity Framework & Sql
dotnet ef migration list
dotnet ef database update
dotnet ef database update 20191018114616_SetDataCompressionOnEverything
dotnet ef database drop
dotnet ef migrations add

-------------- git
git help [fetch|pull|commit...]
git config --global core.excludesfile ~/.gitignore_global   //config for ignoring files globally
git clone -b <branch> --single-branch <url>
git commit -m "Commit message"
git merge develop       //merge develop branch to current branch
git push origin HEAD  	// or <branch_name>

git fetch origin --prune    //clean stale branches & fetch new from origin

git checkout -b feature_x   //create a new branch named "feature_x" and switch to it using
git checkout master 		//switch back to master
git checkout abc.txt        //revert file abc.txt
git checkout .              //discard all changes
git branch                  //-a : list all branches or local branches only
git branch -a               //list all branches including remote branch
git branch -d feature_x		//git delete branch
git branch -m <old-branch-name> <new-branch-name> //rename branch
git pull					//update repository
git pull origin develop     //pull from develop branch and merge to current branch (you are not standing at develop)
git log
git log --stat
git log [-5] --oneline      //show the last 5 logs 
git stash list|show|clear
git stash save -u 'Some changes'   //stash current changes -u=include UNTRACKED files
git stash pop                   //pop a stash, and apply it to current branch
git stash drop
git diff --cached --binary > mypatch.patch  //export stagged  to .patch file
git diff > mypatch.patch        //export diff to .patch file
git diff --staged               //show differences of staged items
git apply mypatch.patch         //apply patch file to current branch
git merge <branch>			//merge <branch> to active branch
git diff <source_branch> <target_branch>	//review merging changes
git diff HEAD path_to_file     //compare diff between current file and HEAD
git status 					//see status all changes
git add abc/abc.cs
git add *
git reset --remove all staged
git reset --hard origin/<branch_name> 	//delete commited in local
git clean -df                           //delete untracked files in local
git apply abc.diff  //apply a patch to current source
git diff --cached > mypatch.patch     //stage everything & create patch

git rebase -i HEAD~4                //update history of git upto 4 commits
press i for insert, edit file as you want
use :wq to write changes
git push --force                    //to update history

git rm -r --cached .                //remove everything from the repository to fix .gitignore
git add .                           //add only files you need to track
git commit -m '.gitignore fix'      //commit to update
git push                            //push to server to store code

git config --get remote.origin.url      //get the remote url of repository
git remote -v                           //display the fetch & push url of repository
git remote show origin                  //show all branches & url of repository & behind/uptodate status
git remote add origin https://github.com/user/repo.git //add a remote
git remote rm                           //remove a remote
git push -u ldv --all                    //push all to new remote branch

git config --global credential.helper osxkeychain --fix for wrong credential on mac
git config --global credential.helper wincred --fix for wrong credential on windows
git config --global --unset user.password

-------- linux command line
chmod a+x runmsv.sh   //allow running bash file
sh runmsv.sh          //run bash file
ssh -p 22 -l vule 172.16.10.252   //remote the pc If it says couldn’t connect on port XXX
ssh vule@172.16.10.252            //remote pc
sudo nano /etc/ssh/sshd_config    //edit ssh
sudo poweroff | reboot         
sudo service docker start
touch readme.txt    //create file readme.txt
vim readme.txt      //edit file with vim
nano readme.txt     //edit file with nano
less readme.txt     //view file 
hostname -I         //show IPs of machine
df -h --total       //check for free space of disk
sudo usermod -aG docker your-user    //add current user to docker group, so that dont need sudo each time
#script to install ssh
sudo apt-get -y install openssh-server
sudo service ssh status
hostname -I         //find out the ip of that server to connect
ssh vule@192.168.1.249            //remote to that pc


--windows service command line
sc.exe create "ABC.AccountService" binPath="C:\Apps\ABC.AccountService\ABC.AccountService.exe" start=auto;
sc.exe start "ABC.AccountService";
sc.exe stop "ABC.AccountService";
sc.exe QUERY "ABC.AccountService";
sc.exe delete "ABC.AccountService";

-------------- Database cassandra
docker run --name cas -d cassandra:3.11 -e CASSANDRA_BROADCAST_ADDRESS=192.168.43.218
docker run --name cas -p 9042-9043:9042-9043 -d cassandra:3.11.4

docker run --name some-cassandra -d cassandra:3.11.4		#run cassandra
docker run --name some-cassandra -d cassandra:latest		#run cassandra using latest version
docker exec -ti cas0 cqlsh  #run cqlsh on the docker to query data
desc keyspaces;             #list all keyspaces
use keyspace_name;          #must have the semi colon or the command won't be run
desc tables;                #list all tables

docker run --name mycas -d cassandra:3.11.1		#run cassandra
docker run --name some-app --link some-cassandra:cassandra -d app-that-uses-cassandra	 #connect to cassandra
docker run -e DS_LICENSE=accept --memory 4g --name my-dse -d datastax/dse-server -g -s -k

-------------- Database SQLServer docker
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=P@ssword' -p 1433:1433 --name sql1 -d mcr.microsoft.com/mssql/server:2017-latest  #run sql on docker
docker run -d -it --name mssql_tools mcr.microsoft.com/mssql-tools    #run sql tool on docker, to execute the .sql command
docker cp "/Users/vule/Downloads/dbscript/script.sql" mssql_tools:/script.sql     #copy the .sql file from host to container
docker exec mssql_tools sh -c  "/opt/mssql-tools/bin/sqlcmd -S 172.16.10.250 -U SA -P P@ssword -i script.sql"    #run .SQL file in container using sql-tool, you should change the IP of the sql instance
docker rm -f mssql_tools    #remove sqltool
docker exec -it 17a /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P P@ssword #start sql chmod
    1> SELECT SYSDATETIMEOFFSET();
    2> GO

# from now on, we can use MS SQLManagement or Azure Data Studio  to connect to the Sql instance running on container
SQL Server cli
SqlCmd -E -S MyServerMyInstance –Q “BACKUP DATABASE [MyDB] TO DISK=’D:BackupsMyDB.bak'”
SqlCmd -E -S MyServer –Q “RESTORE DATABASE [MyDB] FROM DISK=’D:BackupsMyDB.bak'”

-------------- windows Server 
sc.exe create "MyFirstWindowsService" binPath="C:\app\MyFirstWindowsService.exe" start=Auto type=system      --install windows service
sc.exe  "MyFirstWindowsService"      --delete a windows service
netstat -a -n -p tcp -o     --list all listening ports & app

net localgroup "Remote Desktop Users" "dev" /add  #add dev user to remote desktop group
net localgroup "Remote Desktop Users" "dev" /delete  #delete 'dev' user from remote desktop group

-------------- Nuget Restore package
nuget sources add -Name abcSource -Source https://nuget.dev.abc.com/nuget -UserName abc@abc.com -Password YourPasswordHere
nuget sources remove -Name abcSource
nuget restore -PackagesDirectory .
./nuget.exe push -source "PartsUnlimitedShared" -ApiKey VSTS "C:\PartsUnlimited.Shared.1.0.0.nupkg"

-------------- OSX
/private/etc/hosts      -- path to hosts file on OSX
du -sh *                -- list files/folder's size

-------------- Powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned     #enable run ps1 on windows
