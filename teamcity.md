1. Run a server
```docker run -it --name teamcity-server-instance  \
    -v /Users/vule/ProjectTests/TeamCity/Server/datadir:/data/teamcity_server/datadir \
    -v /Users/vule/ProjectTests/TeamCity/Server/logs:/opt/teamcity/logs  \
    -p 8111:8111 \
    jetbrains/teamcity-server```

2. While running the container, it will require us to config the server by going to the link it provides.
You will see a line like this:
>Startup confirmation is required. Open TeamCity web page in the browser. Server is running at http://localhost:8111

## You will need to setting up these things
- Choose database for teamcity (sqlserver, oracle, mysql, ...)
- Accept the license
- Create Administrator Account (for example: username=root, pw=password)
- Update the information for admin account (name=admin, email=someemail@mail.com & other configs)

## Things should be done if you see these lines:

>TeamCity initialized, server UUID: e97a4108-34db-4304-a54d-ae28690342d2, URL: http://localhost
>TeamCity is running in professional mode
>[TeamCity] Super user authentication token: 1333673163881963353 (use empty username with the token as the password to access >the server)

From now, we can login your teamcity at http://localhost:8111 by using *administrator account* or the *empty-username & 1333673163881963353 as password*

3. Run a teamcity agent connected to server to build projects
we can replace SERVER_URL=http://localhost:8111 by IP of the machine for example: SERVER_URL=http://192.168.1.15:8111 
```docker run -it --name teamcity-agent-instance \
    -e SERVER_URL=http://localhost:8111 \ 
    -v /Users/vule/ProjectTests/TeamCity/Agent/conf:/data/teamcity_agent/conf  \      
    jetbrains/teamcity-agent```

4. We need to authorize the agent in TeamcityServer
- run bash on the TeamcityAgentDocker, and open file /data/teamcity_agent/conf/buildAgent.properties to see the *authorizationToken* (type :q to exit the viewer)

```docker exec -it teamcity-agent-instance bash
less /data/teamcity_agent/conf/buildAgent.properties```
- Copy the value of *authorizationToken* (for example authorizationToken=4fcf1c123d4fe6383a9e97db1fb888d7)
- Go to teamcity server, on top left menu, Click *Agents*, There should be an Unauthorized agent, click on it, click authorize, paste the token an authorize it

Now , we start creating a project with team city
- Go to http://localhost:8111
- Sign in with admin account or token
- CREATE NEW project in Teamcity: BuildDotNetCoreHelloWorld
- Add *Version Control Settings* with github project https://github.com/jerryno6/DotnetCoreHelloWorld.git
- Build Step 1 : use command line to restore Nuget : dotnet restore DotnetCoreHelloWorld.sln
- Build Step 2 : use command line to build project : dotnet build DotnetCoreHelloWorld.sln
