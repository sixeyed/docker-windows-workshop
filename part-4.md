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

Also look at the contents of `C:\mssql` on the host, and you'll see the `.mdf` and `.ldf` SQL files there. The data is now persisted outside of the SQL container. Remove all running containers, and then bring the appup again, to create a new set of containers:

```
cd "$env:workshopRoot\app"

docker container rm -f $(docker container ls --quiet --all)

docker-compose -f docker-compose-1.6.yml up -d
```

The new SQL container attaches the database files on the host, so the existing data is intact. Repeat the SQL query and you'll see your prospect data is still there:

```
docker container exec app_signup-db_1 powershell `
 "Invoke-SqlCmd -Query 'SELECT * FROM Prospects' -Database SignUp"
```

## <a name="2"></a>2. Set application services to restart when Docker starts

Docker volumes allow data to persist outside of the container lifecycle. Containers stop when the process inside them stops - but you can set up containers to automatically restart if the application ends.

We'll run a simple example with IIS:

```
docker container run -d -P --name iis `
 --restart always `
 microsoft/iis:windowsservercore
```

The `restart` option means that if the IIS Windows Service stops and the container exits, it will be autimatically restarted. Check the site by grabbing the container's IP address:

```
$ip = docker inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' iis

iwr -useb http://$ip
```

Now kill the IIS Windows Service:

```
docker container ls 

docker exec iis powershell Stop-Service w3svc

docker container ls 
```

If you compare the two container listings, you'll see the container has been restarted, it has only been running for a few seconds in the second list. It's the same container. but Docker executed the startup command again when the container exited.

In [docker-compose-1.7.yaml](app/docker-compose-1.7.yaml) I've added the `restart` option to the application services. It works in the same way with Docker Compose:

```
cd "$env:workshopRoot\app"

docker-compose -f docker-compose-1.7.yml up -d
```

## <a name="3"></a>3. Scale message handlers up to increase throughput

Compose is a management tool for multiple containers running on a single Docker node. You define services rather than individual containers, so that you can run multiple instances of the same workload.

The message handlers are good candidates for scaling up - multiple containers will share the workload. Scale up the SQL Server handler to 3 instances:

```
cd "$env:workshopRoot\app"

docker-compose -f docker-compose-1.7.yml scale signup-save-handler=3

docker container ls
```

Now browse to the site and enter some prospects:

```
$ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_signup-web_1
start "http://$ip"
```

Check the container logs, and you'll see the prospect signup messages have been distributed among the three containers:

```
docker container logs app_signup-save-handler_1
docker container logs app_signup-save-handler_2
docker container logs app_signup-save-handler_3
```

Compose is a useful tool for verifying distributed solutions on a single machine. It's a client-side tool; when it creates services Docker only sees them as a set of unrelated containers.

## Next Up

We'll make use of another feature of compose in [Part 5](part-5.md), when we build out a full CI pipeline, with all the parts running in Docker containers on Windows.