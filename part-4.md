# Part 4 - Resilience and Scalability with Docker Compose

In this part we'll see how to use Docker Compose to scale our app and make the containers, and data, resilient to hardware failure. Compose is a client-side tool that works against a single Docker engine. At the end of the workshop we'll look at resilience and scale across multiple nodes in a Docker swarm.

## Steps

* [1. Add persistent storage to SQL Server](#1)
* [2. Set application services to restart when Docker starts](#2)
* [3. Scale message handlers up to increase throughput](#3)


## <a name="1"></a>Step 1. Add persistent storage to SQL Server

Every time we restart the SQL Server container, any data stored is lost. That's because Docker images are read-only and shared. Each container adds a writeable layer on top of the image layers for its own data. When you remove the container you lose the data.

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

IIS running inside the container has created a log file in the logs directory, which is actually mapped to the host. You can do the same with SQL Server to store the data and log files on the host.

> It's slightly more complicated with SQL Server because you can't mount a directory from the host if the directory on the container contains data. You can't override the existing SQL Server data directory, so instead we'll make a custom SQL Server image.

etc

```
cd "$env:workshopRoot\part-4\db"

docker image build --tag "$env:dockerId/signup-db" .
```

etc

```
cd "$env:workshopRoot\app"

docker-compose -f docker-compose-1.6.yml up -d
```

enter

```
$ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_signup-web_1
start "http://$ip"
```

check 

```
docker container exec app_signup-db_1 powershell `
 "Invoke-SqlCmd -Query 'SELECT * FROM Prospects' -Database SignUp"
```

delete, recreate:

```
cd "$env:workshopRoot\app"

docker-compose -f docker-compose-1.6.yml down

docker-compose -f docker-compose-1.6.yml up -d
```

check:

```
docker container exec app_signup-db_1 powershell `
 "Invoke-SqlCmd -Query 'SELECT * FROM Prospects' -Database SignUp"
```

## <a name="2"></a>2. Set application services to restart when Docker starts

```
docker container ls 
```

remove db & web containers

ETC

```
docker container ls 
```

start with 1.7:

```
cd "$env:workshopRoot\app"

docker-compose -f docker-compose-1.7.yml up -d
```