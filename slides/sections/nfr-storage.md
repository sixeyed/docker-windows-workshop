# NFR #1 - Persistent Storage

---

The filesystem in a Docker container has the same lifetime as the container. 

If you write data in your app and then replace the container - for an application or OS update - you'll lose all your data.

Next you'll learn how to keep data outside of a container using a [Docker volume](https://docs.docker.com/engine/admin/volumes/volumes/), which has a separate lifecycle to the container.

---

## Docker volumes for log files

As a simple example, create a new IIS container with a volume which maps the log directory in the container to a directory on the host:

```
mkdir C:\iis-logs; `

docker container run --detach --name iis --publish-all `
 --volume "C:\iis-logs:C:\inetpub\logs" `
 microsoft/iis:nanoserver
```

> When the container reads or writes data at `C:\inetpub\logs` it is actually using `C:\iis-logs` on the server.

---

## Generate some log entries

When you browse to IIS on the container, it will write log entries - and you will see the files on the server.

_ This script makes a web request and then checks the logs: _

```
$ip = docker inspect `
  --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' iis; `

iwr -useb http://$ip; `

ls C:\iis-logs\LogFiles\W3SVC1
```

> IIS running inside the container has created a log file in the `LogFiles` directory, which is actually mapped to the host. 

---

## Volumes for SQL Server data files

You can do the same with SQL Server to store the data and log files on the host.

> It's slightly more complicated with SQL Server because you can't mount a directory from the host if the directory on the image already contains data - which is true with the SQL data directory.

You can't override the existing SQL Server data directory, so instead we'll make a custom SQL Server image.

---

## Build the custom SQL image

The [Dockerfile](./docker/nfr-storage/signup-db/Dockerfile) adds a volume and an [initialization script](part-5/db/Initialize-Database.ps1) which creates the SignUp database in the volume directory.

_ Build the image: _

```
cd $env:workshop

docker image build --tag dwwx/signup-db `
  -f ./docker/nfr-storage/signup-db/Dockerfile .
```

---

## Run the database with a volume

Try running the database container on its own. Because the image has a volume defined, Docker will create a volume for the container.

_ Run the container with no extra configuration: _

```
docker container run -d --name db-1 dwwx/signup-db
```

> Docker provisions a volume, creates the container and connects it to the volume.

---

## Check the container output

The startup script in the SQL container writes logs as it sets up the database, and then it creates the data files in the volume directory.

_ Check the container logs: _

```
docker container logs db-1
```

> You'll see log entries saying the data files have been created at `C:\data`.

---

## Check the data in the volume

Docker creates the volume with a generated ID. You can get details about volumes attached to the container by inspecting it.

_ This shows details about the SQL container's volume: _

```
docker container inspect --format '{{ .Mounts }}' db-1
```

> One output field will be the physical path of the volume, starting `C:\ProgramData\Docker...`. List the contents and you'll see the database files.

---

## Run the database with a mapped volume

Volumes are useful for ensuring data gets saved, but you can override the volume path when you run a container, specifying a host path to mount.

_ Create the data folder and run the container: _

```
mkdir C:\mssql; `

docker container run -d -v C:\mssql:C:\data `
  --name db-2 dwwx/signup-db
```

---

## Check the container output

The startup script in the SQL container writes logs as it sets up the database, and then it creates the data files in the volume directory.

_ Check the container logs and the host directory: _

```
docker container logs db-2; `

ls /mssql
```

> You'll see log entries saying the data files have been created at `C:\data`, and you'll also see the files really live at `C:\mssql` on the server.

---

## Remove the database containers

Now we've seen how volumes work, we'll remove the database containers and use volumes for the full app.

```
@('db-1', 'db-2') | foreach { docker container rm -f $_ }
```

---

## Run the app with volumes for storage

The [v7 manifest](./app/v7.yml) includes two `volume` specifications - using `C:\mssql` on the host for SQL Server data files, `C:\prom` for Prometheus data and `C:\es` for Elasticsearch.

_ Create the new directories and run the app:_

```
mkdir C:\prom; mkdir C:\es; `

docker-compose -f .\app\v7.yml up -d
```

> Most of the containers will get recreated because of the dependencies.

---

## Try out the app

There's a new proxy container, so you'll need to get the IP address and browse to open the app.

```
$ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_proxy_1

firefox "http://$ip"
```

> Add a new prospect, and the databases will all write files on the server.

---

## Check the data files

When the message handlers have processed the event, and the metrics have been scraped, there will be data from SQL Server, Elasticsearch and Prometheus.

_ Check the data files on the server: _


```
ls C:\mssql; ls C:\es; ls C:\prom
```

> Now if you remove all your containers and start the app again, all your old data will be available to the new containers.

---

## Storage beyond single-node environments

You can map volumes to host directories, which is fine for dev and single-node test environments. You can also map volumes from different storage providers for production.

Docker volumes have a plug-in architecture, so with a production cluster you could map container volumes to storage units in the data center, or to storage services in the cloud.