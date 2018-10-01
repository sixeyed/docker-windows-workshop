# NFR #2 - Always On

---

Containers stop when the process inside them stops, or when the Docker Windows Service stops.

For single-node environments you can set up containers to automatically restart if the application ends, and to restart when the Docker Windows Service starts.

---

## Run a restarting container

You use the `restart` option to specify how containers should behave when they stop.

_ Start by running a simple example with IIS: _

```
docker container run -d --name iis-restart `
 --restart always `
 microsoft/iis:windowsservercore
```

> This setup means that if IIS stops and the container exits, it will be automatically restarted.

---

## Check the container is working

Check the application is actually running.

_ Make an HTTP request to the container: _

```
$ip = docker inspect `
 --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' iis-restart

iwr -useb http://$ip
```

> You should get status code 200, so the web server is working.

---

## Kill IIS!

Now check on the state of the application container, kill the IIS Windows Service and check the container again:

```
docker container ls --last 1
```

```
docker exec iis-restart powershell Stop-Service w3svc
```

```
docker container ls --last 1
```

> You'll see the container has been restarted, it has only been running for a few seconds in the second list. 

---

## Understanding restarts

The `restart` option comes into action when the container stops, or when the Docker service is restarted or the machine is rebooted.

Containers aren't removed when they stop, and Docker just restarts them by running the container startup command again.

**It's the same container**, but it's been rebooted.

---

## Defining restart policies

[v8 of the app manifest](./app/v8.yml) adds restart policies to all the containers:

- functional containers all use `restart: always`
- the monitoring containers use `restart: unless-stopped`

`unless-stopped` is good for optional components. If you explicitly stop them, they don't get restarted. The other options are `no` and `on-failure`.

---

## Run the app with always-on containers

All the service definitions have changed, so when you redeploy you'll get all new containers - but your data will still be there from the volumes.

_ Run the new stack: _

```
cd $env:workshop

docker-compose -f ./app/v8.yml up -d
```

---

## Try out the app

There's a new proxy container, so you'll need to get the IP address and browse to open the app.

```
$ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_proxy_1

firefox "http://$ip"
```

> It's the same app, but the containers will all come back online when Azure reboots your VM :)

---

## Resilience beyond single-node environments

The `restart` policy only applies to single-node Docker environments. It's useful for test environments or even for non-critical production workloads.

For real high availability and scale you'll run a cluster of machines all running Docker. The cluster orchestrator - Docker Swarm or Kubernetes - takes care of high availability for your services.
