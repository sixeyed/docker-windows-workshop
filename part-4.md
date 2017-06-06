# Part 4 - Resilience and Scalability with Docker Compose

In this part we'll see how to use Docker Compose to scale our app and make the containers, and data, resilient to hardware failure. Compose is a client-side tool that works against a single Docker engine. At the end of the workshop we'll look at resilience and scale across multiple nodes in a Docker swarm.

## Steps

* [1. Add persistent storage to SQL Server](#1)
* [2. Set application services to restart when Docker starts](#2)
* [3. Scale message handlers up to increase throughput](#3)


## <a name="1"></a>Step 1. Add persistent storage to SQL Server

Every time we restart the SQL Server container, any data stored in the database is lost. Docker images are read-only so they can be shared - writing data in a container doesn' affect the image. Each container adds a writeable layer on top of the image layers for its own data. When you remove the container you lose the data.

Docker provides [volumes]() for storing data outside of containers. A volume can simply be a mount, where a directory in the container is actually mapped to a directory on the host.

As a simple example, create a new IIS container with the log directory mapped to the host:

```
mkdir C:\iis-logs

docker container run --detach --name iis --publish-all `
 --volume "C:\iis-logs:C:\inetpub\logs" `
 microsoft/iis:nanoserver
```

Make a web request to the container, and check the contents of the log folder on the host:

```
$ip = docker inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' iis

iwr -useb http://$ip

ls C:\iis-logs\LogFiles\W3SVC1
```

IIS running inside the container has created a log file in the `LogFiles` directory, which is actually mapped to the host. You can do the same with SQL Server to store the data and log files on the host.

> It's slightly more complicated with SQL Server because you can't mount a directory from the host if the directory on the image already contains data. You can't override the existing SQL Server data directory, so instead we'll make a custom SQL Server image.

The [Dockerfile](part-4/db/Dockerfile) for the database image is based from Microsoft' SQL Server image. It adds an [initialization script](part-4/db/Initialize-Database.ps1) as the entrypoint. That script creates the SignUp database a known file location.

Build the image, which is now suited to using data volumes:

```
cd "$env:workshopRoot\part-4\db"

docker image build --tag "$env:dockerId/signup-db" .
```

I've added a volume mount to the database service definition in [docker-compose-1.6.yml](app/docker-compose-1.6.yml). Create a directory on the host for the SQL Server data, and bring up the application: 

```
mkdir C:\mssql

cd "$env:workshopRoot\app"

docker-compose -f docker-compose-1.6.yml up -d
```

The database container is replaced, as the definition has changed. The app container is replace too, because the database dependency has been updated. Browse to the app:

```
$ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_signup-web_1
start "http://$ip"
```

Add a new prospect in the website, and then check the data is saved to SQL Server:

```
docker container exec app_signup-db_1 powershell `
 "Invoke-SqlCmd -Query 'SELECT * FROM Prospects' -Database SignUp"
```

Also look at the contents of `C:\mssql` on the host, and you'll see the `.mdf` and `.ldf` SQL files there. The data is now persisted outside of the SQL container. Bring the app down and then up again, to create a new set of containers:

```
cd "$env:workshopRoot\app"

docker-compose -f docker-compose-1.6.yml down

docker-compose -f docker-compose-1.6.yml up -d
```

The new SQL container attaches the database files on the host, so the existing data is intact. Repeat the SQL query and you'll see your prospect data is still there:

```
docker container exec app_signup-db_1 powershell `
 "Invoke-SqlCmd -Query 'SELECT * FROM Prospects' -Database SignUp"
```


>>> TO HERE

## <a name="2"></a>2. Set application services to restart when Docker starts

restart based on exit condition, not external commands.

sample:

```
docker container run -d -P --name iis `
 --restart always `
 microsoft/iis:windowsservercore
```

get ip & test

kill w3svc:

```
docker container ls 

docker exec iis powershell Stop-Service w3svc

docker container ls 
```

check out 1.7 yaml. Upgrade to 1.7:


```
cd "$env:workshopRoot\app"

docker-compose -f docker-compose-1.7.yml up -d
```

## <a name="3"></a>3. Scale message handlers up to increase throughput

```
cd "$env:workshopRoot\app"

docker-compose -f docker-compose-1.7.yml scale signup-save-handler=3

docker container ls
```

enter some data

```
$ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_signup-web_1
start "http://$ip"
```

check logs
```
docker container logs app_signup-save-handler_1
```