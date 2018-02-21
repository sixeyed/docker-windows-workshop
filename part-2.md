# Part 2 - Modernizing .NET apps - the platform

In this section we have an existing app, already packaged as an MSI. We'll Dockerize a few versions of the app using different approaches, seeing how to do service updates and the benefits of Dockerfiles over MSIs.

## Goals

* Learn how to package .NET apps to run in Docker
* Learn how to use Docker Compose to manage distributed applications
* Learn how Docker uses healthchecks to test your application's status
* Learn how multi-stage Dockerfiles make your application portable

## Steps

* [1. Package an ASP.NET MSI as a Docker image](#1)
* [2. Update the ASP.NET site with a new image version](#2)
* [3. Use Docker to build the source and package without an MSI](#3)

## <a name="1"></a>Step 1. Package an ASP.NET MSI as a Docker image

It's easy to package an MSI into a Docker image - use `COPY` to copy the MSI into the image, and `RUN` to install the application using `msiexec`, which is already bundled in the Windows base image.

Version 1.0 of our demo app is ready to go - check out the [Dockerfile](part-2/web-1.0/Dockerfile). 

Packaging the app with Docker is the same `build` command - you'll use an image tag to identify the version:

```
cd "$env:workshop\part-2\web-1.0"
docker image build --tag $env:dockerID/signup-web:1.0 .
```

The app uses SQL Server in a Windows container, but rather than start individual containers, you'll use [Docker Compose](https://docs.docker.com/compose/) to organize all the parts of the solution. The [version 1.0 compose file](app/docker-compose-1.0.yml) specifies the database and application containers.

```
cd "$env:workshop\app"
docker-compose -f docker-compose-1.0.yml up -d
```

Compose will start the SQL Server container and then the web app container. Get the web app's IP address and browse to it:

```
$ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_signup-web_1
firefox "http://$ip/SignUp"
```

> You may see an error from the ASP.NET site saying it can't access SQL Server. This is a timing issue with version 1.0 of the app - it  expects SQL Server to be always available, but here the web container may have launched before the SQL Server container is ready to open a connection. Refresh the page and it will load correctly. **We'll fix this in the next part of the workshop.**

Click on the 'Sign up' button and register your details - that will write a row to SQL Server. The SQL Server container is only available to other Docker containers, it can't be accessed from the outside world because no ports are published. You can use Docker to execute a PowerShell command inside the container to see your data:

```
docker container exec app_signup-db_1 powershell `
 "Invoke-SqlCmd -Query 'SELECT * FROM Prospects' -Database SignUp"
```

Version 1.0 has a pretty basic UI. Next you'll upgrade to a new app release.

## <a name="2"></a>Step 2. Update the ASP.NET site with a new image version

For the new app version there's a new MSI. The [Dockerfile](part-2/web-1.1/Dockerfile) is exactly the same as v1.0, just using a different MSI. This scenario is where you have a new application release but you want to keep the same underlying Windows version.

Build the new app version:

```
cd "$env:workshop\part-2\web-1.1"

docker image build --tag $env:dockerId/signup-web:1.1 .
```

You'll use Docker Compose to upgrade the solution. [The version 1.1 compose file](app/docker-compose-1.1.yml) uses the same database definition, but updates the web app image to version 1.1. The `up` command can be used to start or upgrade apps:

```
cd "$env:workshop\app"
docker-compose -f docker-compose-1.1.yml up -d
```

You'll see in the output that compose compares the current state of the application resources against the desired state in the YAML file. Here the SQL server container definition hasn't changed, so only the web application container is replaced. You'll see this output from compose:

```
app_signup-db_1 is up-to-date
Recreating app_signup-web_1 ...
Recreating app_signup-web_1 ... done
```

Now the new version of the app is running in new container. It has the same name as the previous one but it's a new instance with a new IP address. Check out the new app version by browsing to the container:

```
$ip = docker inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_signup-web_1
firefox "http://$ip/SignUp"
```

Sign up with another set of details, and when you repeat the SQL query you'll see that the new data is there, along with the original data:

```
docker container exec app_signup-db_1 powershell `
 "Invoke-SqlCmd -Query 'SELECT * FROM Prospects' -Database SignUp"
```

The app is looking better, but the Dockerfile isn't very useful. It should describe everything that's needed to package the app, but most of the work is done in the MSI. That's opaque, it could be doing anything - to find out what actually happens in the MSI you need to trawl through this huge [Wix script](signup/src/SignUp.Web.Setup/Product.wxs).

Next you'll see how to package the same content in a different way, and upgrade the app container to a new version of Windows at the same time.

## <a name="3"></a>Step 3. Use Docker to build the source and package without an MSI

Docker 17.05 and up supports multi-stage builds, which we use now. The [Dockerfile](part-2/web-1.2/Dockerfile) has two stages. The first uses a generic MSBuild image to compile and publish the Web project. The second packages the published output into an application image.

The Dockerfile approach removes the need for an MSI, or any build pre-requisites. Anyone with Docker can build and run the application, you don't need Visual Studio, MSBuild or even .NET installed on your machine. The toolchain to compile the app is built into the MSBuild image.

It's also clear from the Dockerfile exactly how the app is built and installed, and this new version has a `HEALTHCHECK` which is good practice for production workloads.

Multi-stage builds run in the same way, but only the final image is tagged:

```
cd "$env:workshop"
docker image build --tag $env:dockerId/signup-web:1.2 --file part-2\web-1.2\Dockerfile .
```

> Note that this image gets built from the base directory. That's so the full `src` folder gets is used in the build and the source code is available to the build stage.

This build will take a few minutes - it uses NuGet to restore all the packages the app uses, and then compiles and publishes the web app with MSBuild. You'll see all the output in the PowerShell window.

When the build is done, you can upgrade the running application using Docker Compose. [Version 1.2](app/docker-compose-1.2.yml) of the compose file just updates the web app definition to use the new v1.2 image:

```
cd "$env:workshop\app"
docker-compose -f docker-compose-1.2.yml up -d
```

Now the whole solution is portable, and the deployment process is much cleaner. Anyone can build and run the app from source, all you need on your laptop or CI server is Docker - you don't need Visual Studio, MSBuild or even .NET installed. We've also upgraded Windows to get the latest hotfixes and security patches, just by bumping the Windows version in the `FROM` image. Browse to the app, and you'll see the UI is the same:

```
$ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_signup-web_1
firefox "http://$ip"
```

The UX is the same too, so when you sign up you'll see a new set of details in the SQL container:

```
docker container exec app_signup-db_1 powershell `
 "Invoke-SqlCmd -Query 'SELECT * FROM Prospects' -Database SignUp"
```

## Next Up

That's it for Part 2. In [Part 3](part-3.md) we'll modernize the app architecture, making use of the Docker platform to break features out of the monolith, and run them in lightweight containers.
