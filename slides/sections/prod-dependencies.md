# Production Readiness - Dependencies

---

<section data-background-image="/img/prod/Slide7.png">

---

Old apps used to be written with the **assumption of availability** - they didn't check dependencies were available, they just tried to use them in the expectation they would exist.

That assumption doesn't work in dynamic cloud and container environments. Apps should check their dependencies are available before they start, and they should exit if they're not available.

We'll add that functionality to our old ASP.NET app by packaging a dependency checker utility in the Docker image.

---

## The dependency checker

The utility is just a .NET Framework console app. It uses the same configuration structure as the ASP.NET app, so it will use the same settings as the app.

In the [Program class](./src/Utilities.DependencyCheck/Program.cs) the app uses [Polly](https://github.com/App-vNext/Polly) to wrap a SQL connection check. It retries three times to connect to SQL Server, and if the third attempt fails, the utility returns an exit code of `1`.

---

## Packaging the dependency checker

A new stage in the [updated Dockerfile](./docker/prod-dependencies/signup-web/Dockerfile) builds the dependency checker from source. The output is copied into the final Docker image, alongside the original ASP.NET app.

There's also a new environment variable `DEPENDENCY_CHECK_ENABLED`, used to turn the dependency check off in dev environments.

In the [startup script](./docker/prod-dependencies/signup-web/startup.ps1) that flag gets checked, and if it's set then the dependency checker gets run.

---

## Build the new image

_ Tag the image as `v6`, which includes the depencency check: _

```
docker image build `
  -t dwwx/signup-web:v6 `
  -f ./docker/prod-dependencies/signup-web/Dockerfile .
```

---

## Kill the database container

We can test the dependency check by removing the database container, so when we run the new web app it should fail.

_ Remove the database container: _

```
docker container rm -f app_signup-db_1
```

---

## Test the dependency check

Now run the app container on its own, so you can see the dependecy check in action.

_ Run the container interactively to see the output: _

```
docker container run -it `
  -e DEPENDENCY_CHECK_ENABLED=1 `
  dwwx/signup-web:v6 
```

> You'll see the check fires and fails, and then the container exits

---

## Wait, what about all our data?

Ah. It was stored in the filesystem of that container we've just destroyed, so it's gone forever.

Let's make sure that doesn't happen again. This [Dockerfile for the database](./docker/prod-dependencies/signup-db/Dockerfile) is based on the same SQL Server image, but it adds a Docker volume for data storage.

The [initialization script](./docker/prod-dependencies/signup-db/Initialize-Database.ps1) checks that storage location, and it will either create a new database, or attach existing database files if they exist.

---

## Build the database image

We can run persistent database containers from this image by mapping the volume, or run it without a volume map to get a disposable database.

_ Build the image from the Dockerfile: _

```
docker image build `
  -t dwwx/signup-db `
  -f ./docker/prod-dependencies/signup-db/Dockerfile .
```

---

## Run the app with the new images

The [v9 manifest](./app/v9.yml) uses the upgraded web app and database images. It also mounts the database volume from a folder on the host.

_ Create the folder and update the application: _

```
mkdir C:\mssql

docker-compose -f .\app\v9.yml up -d
```

---

## Check the logs

The database container will start before the web container because we're using Docker Compose on a single machine. 

You'll see the database container and web container logging startup instructions:

```
docker container logs app_signup-db_1
docker container logs app_signup-web_1
```

> In a cluster you don't have ordering guarantees, which is why we need the dependency check in the web app.

---

## Browse to the app

Let's just check the app is still working. Browse and add a new sign up:

```
firefox "http://localhost:8020"
```

---

## Is the data there? 

We have a new SQL Server database container.

_Check the new data has been saved:_

```
docker container exec app_signup-db_1 `
  powershell `
  "Invoke-SqlCmd -Query 'SELECT * FROM Prospects' -Database SignUp"
```

---

## Check the database files

The database is writing file at the path `C:\data` inside the container, but that's a volume which is being mapped fo `C:\mssql` on the VM.

The SQL Server `.mdf` and `.ldf` files actually exists on the VM.

_ You can see the same data from the host: _

```
ls C:\mssql
```

> You could use a RAID array on the server to get redundant storage for container data.

---

## Making dependencies explicit

This pattern makes your old apps ready to run in a dynamic environment. In a production cluster you can't have ordering depenencies, it's too limiting for the platform.

Explicit dependencies mean the container stops if the app can't work. The cluster starts a replacement container - the dependencies may be available by then. If not, the new container stops and the cluster starts another one.

It's important to keep this functionality optional, so in dev and test environments you can run just part of the stack without the container constantly failing.