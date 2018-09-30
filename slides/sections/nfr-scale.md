# NFR #3 - Scale

---

Compose uses the abstraction of "services" to define the parts of your app. Each service is deployed as one or more containers.

Even on a single-node Docker environment you can run multiple containers for a service to get high-availability and scale.

---

## Scale up the services that can

Scaling a service meansd running multiple instances of the same container. Your app needs to support being run that way.

Not all components support this - you can't run multiple web containers on a single server if they all publish the same port. Only one process can listen on a port, and that's true for containers.

Message handlers are good candidates for scaling up. Multiple containers can share the workload from the queue.

---

## Scale up the save handlers

You can use Docker Compose to scale running services up or down.

_ Scale up the save handlers to 3 instances: _

```
cd $env:workshop"

docker-compose -f v8.yml scale signup-save-handler=3
```

> Compose shows new containers starting to meet the scale request.

---

## Scale up the index handlers

_ Scale up the index handlers to 2 instances: _

```
cd $env:workshop"

docker-compose -f v8.yml scale signup-index-handler=2
```

> Compose shows new containers starting to meet the scale request.

---

##  Now browse to the site and enter some prospects:

It's the same proxy container for the app. Browse to the signup page and enter a few prospects:

```
$ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_proxy_1

firefox "http://$ip"
```

---

## Check the save handler logs

Check the container logs, and you'll see the prospect signup messages have been distributed among the three save handler containers:

```
docker container logs app_signup-save-handler_1
docker container logs app_signup-save-handler_2
docker container logs app_signup-save-handler_3
```

---

## Check the index handler logs

And the same messages have been received and processed by the index handlers:

```
docker container logs app_signup-index-handler_1
docker container logs app_signup-index-handler_2
```

---

## These handlers were built to scale

Docker isn't magic. It will run multiple containers for a service, but your application needs to work correctly when it scales. 

In this case the message handler uses [NATS queueing](http://nats.io/documentation/concepts/nats-queueing/) to share the load across multiple instances.

---

## Limitations of scaling with Docker Compose

Compose is a useful tool for running distributed solutions on a single machine. But it's a client-side tool.

When it creates services Docker only sees them as a set of unrelated containers, you need to manage the app through compose. 

You can use the Compose file format with [Docker swarm mode](https://docs.docker.com/engine/swarm/), which lets you manage solutions as a whole unit.

---

## Scale beyond single-node environments

Scaling up services on a single machine only makes sense if running more containers means you get more work done. If a process has to wait on a remote API, then having multiple instances could improve throughput.

But ultimately you're limited to the compute resources of that server. In a production cluster you can scale horizontally, and when you need more compute power you just add more nodes.
