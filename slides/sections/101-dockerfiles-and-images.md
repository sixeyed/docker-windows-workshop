# Dockerfiles and Docker Images

---

You package your own Windows apps as Docker images, using a [Dockerfile](https://docs.docker.com/engine/reference/builder/). 

The Dockerfile syntax is straightforward. In this section you'll walk through two Dockerfiles which package websites to run in Windows Docker containers. 

---

## ASP.NET apps in Docker

Have a look at the [Dockerfile for this app](./docker/101-dockerfiles-and-images/hostname-app/Dockerfile). It builds a simple ASP.NET website that displays the host name of the server. There are only two instructions:

- [FROM](https://docs.docker.com/engine/reference/builder/#from) specifes the image to use as the starting point for this image
- [COPY](https://docs.docker.com/engine/reference/builder/#copy) copies a file from the host into the image, at a known location.

The Dockerfile copies a simple `.aspx` file into the content directory for the default IIS website. 

---

## Build a simple website image

You package an app by building a Docker image from a Dockerfile.

_ Switch to the directory and build the Dockerfile: _

```
cd "$env:workshop\docker\101-dockerfiles-and-images\hostname-app"

docker image build --tag hostname-app .
```

> The output shows Docker executing each instruction in the Dockerfile, and tagging the final image.

---

## Run the new app

Now you can run a container from your image to run the app.

_ Run a detached container with the HTTP port published:_

```
docker container run --detach --publish 8081:80 `
  --name app hostname-app
```

> Any traffic coming into the server on port 8081 will be managed by Docker and processed by the container.

---

## Browse to the app

The app in the container is listening on port 80, but you could be using that port on your host. 

So we've published port 80 on the container to port 8081 on the host. It's access from the Docker host and to external clients.

_Browse to the app: _

```
firefox "http://localhost:8081"
```

---

## Run multiple instances of the app

Let's see how lightweight the containerized application is. 

_ Run five containers from the same image:_

```
for ($i=0; $i -lt 5; $i++) {
  & docker container run --detach --publish-all --name "app-$i" hostname-app
}
```

> The `publish-all` flag publishes the container ports to random ports on the host. 

---

## Check all the containers

You now have multiple instances of the app running. The Docker image is the same, but each instance will show its own container ID.

_ Browse to all the new containers, using this script to find the random host port:_

```
for ($i=0; $i -lt 5; $i++) {
  $address = $(docker container port "app-$i" 80).Replace('0.0.0.0', 'localhost')  
  firefox "http://$address"
}
```

> You'll see that each site displays a different hostname, which is the ID of the container running the app. 

---

## See how much compute the containers use

On the host you have six `w3wp` processes running, which are the IIS worker processes for each container.  

_ Check the the memory and CPU usage for the apps: _

```
Get-Process -Name w3wp | select Id, Name, WorkingSet, Cpu
```

> The worker processes usually average around 40MB of RAM and <1 second of CPU time.

---

## Some issues to fix...

This is a simple ASP.NET website running in Docker, with just two lines in a Dockerfile. But there are two issues we need to fix:

- It took a few seconds for the site to load on first use
- We're not getting any IIS logs from the container

> The cold-start issue is because the IIS service doesn't start a worker process until the first HTTP request comes in.

---

## Logs inside containers

IIS stores request logs in the container filesystem, but Docker is only listening for logs on the standard output from the startup program.

_ Check the logs from one of the app containers: _    

```
docker container logs app-0
```

> Nothing. The logs are locked inside the container filesystem, Docker doesn't know about them.

---

## Build and run a more complex web app

The next [Dockerfile](./docker/101-dockerfiles-and-images/tweet-app/Dockerfile) fixes those issues. These are the main features:

- it configures IIS to write all log output to a single file
- it copies a [startup script](./docker/101-dockerfiles-and-images/tweet-app/start.ps1) and [HTML page](./docker/101-dockerfiles-and-images/tweet-app/index.html) into the image
- the startup script relays all the IIS log file entries to the console
- it adds a [HEALTHCHECK](https://docs.docker.com/engine/reference/builder/#healthcheck) which Docker will use to see if the app is healthy

---

## Build the Tweet app

Build an image from this new Dockerfile.

```
cd "$env:workshop\docker\101-dockerfiles-and-images\tweet-app"

docker image build --tag tweet-app .
```

---

## Run the new app

This is a static HTML site, but you run it in a container in the same way as the last app:

```
docker container run --detach --publish 8080:80 `
  --name tweet-app tweet-app
```

---

## Browse to the new app

You can reach the site by browsing to your `localhost` or to your computer externally on port `8080`

_ Browse to the app:_

```
firefox http://localhost:8080
```

> Feel free to hit the Tweet button, sign in and share your workshop progress :)

---


## Now you have your own Docker images

You've built your own images from Dockerfiles. Right now they only live on the computer where you ran the `docker image build` command.

Next you'll see how to share those images by pushing them to Docker Hub, so anyone can run your apps in containers.
