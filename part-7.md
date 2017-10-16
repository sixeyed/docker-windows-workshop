# Part 7 - Docker Swarm - Native Clustering for High Availability and Scale

In production environments, you will run multiple Docker engines in a cluster and manage services rather than individual containers. The clustering technology built into Docker is called [swarm mode](https://docs.docker.com/engine/swarm/) - you can easily create a swarm across dozens of machines just by running one command on each.

In the final part of the workshop, we'll be using swarm mode to run the application.

## Steps

* [1. Run some sample services in swarm mode](#1)
* [2. Set up the production swarm](#2)
* [3. Deploy the application as services](#3)
* [4. Deploy the application as a stack](#4)

## <a name="1"></a>Step 1. Run some sample services in swarm mode

There are two ways to run applications in swarm mode. The first is to create individual services, which is a similar process to running containers on a single engine. (The second is to deploy a stack, which we'll do last of all).

You can run a single node swarm, which gives you all the functionality of swarm mode but without high availability or the opportunity to scale.

Switching to swarm mode is easy:

```
docker swarm init --advertise-addr 127.0.0.1
```

> Your RDP session will flicker here. That's to do with a network shift Windows does to support networking in swarm mode.

That makes your node a swarm manager. The output is the command you would use to join other nodes to the swarm, but in this step we'll stick with a single node.

Shortly we'll deploy the workshop app to the swarm, but before that we'll just explore swarm mode with a simple example.

In swarm mode you deploy containers are services. You create a service and specify its configuration, and Docker runs the service as containers on the swarm.

Create a simple service which runs in a single container that pings itself:

```
docker service create --entrypoint "ping -t localhost" --name pinger microsoft/nanoserver
```

Services are a first-class resource in swarm mode. You can list all services, list the containers running the service (called "tasks"), and check the logs for the service:

```
docker service ls

docker service ps pinger

docker service logs pinger
```

Services are an abstraction over containers. Working with services, you don't care which node is running the containers. You just specify a service level, and the swarm maintains it. If a server in the swarm goes down and takes containers with it, Docker spins up replacements on other servers.

You can scale up the service by running more replicas:

```
docker service update --replicas=3 pinger
```

Scaling up the service adds more task containers. This is a single node swarm so they will all be running on your VM. You can see the extra tasks, and their logs:

```
docker service ps pinger

docker service logs pinger
```

Swarm mode also supports automatic updates. You upgrade your app by updating the service with a new image. For services with multiple replicas, this is a zero-downtime update because Docker removes one container at a time, and replaces it with a new one:

```
docker service update --image microsoft/windowsservercore pinger
```

This replaces the container image, switching from Nano Server to Windows Server Core. The `entrypoint` definition for the service is still the same, so when new task containers start, they will run the same command. The service definition is stored in the swarm:

```
docker service inspect pinger
```

Check the task list for the service, and you can see the rollout happens gradually. Some containers will be using the original definition with Nano Server, and some will be using Windows Server Core:

```
docker service ps pinger
```

Because swarm saves the service definition, you can easily rollback an update if the new version of the app has a problem:

```
docker service update --rollback pinger
```

The rollback happens in the same way, with task containers being replaced with versions using the original definition:

```
docker service ps pinger
```

And you can see the logs are still collected from all the containers:

```
docker service logs pinger
```

You can stop and remove all the task containers just by removing the service:

```
docker service rm pinger
```

Now we're ready to deploy the real application to a real swarm.

## <a name="2"></a>Step 2. Set up the production swarm

It's time to buddy up! 

![Ferris & pals](img/ferris-buellers-day-off.jpg)
    
Your workshop VM is in the same virtual network as your neighbour's, so you can create a swarm between you. First you need to:

- push your application images to Docker Hub
- pick another person (or 2 or 3) to work with - **make sure your VMs all start with the same DNS prefix (e.g. `dceu2`)**
- choose who's going to be the manager and who will be the worker(s)

> If you can't or don't want to buddy up, it's no big deal. You can continue with the single-node swarm on your own VM, you just won't be able to test the high availability parts.

### Push your application images

Run this script to tag your local images and push them to Docker Hub:

```
$repositories = 'signup-db', 'signup-web', 'signup-save-handler', 'signup-index-handler', 'signup-prometheus', 'signup-grafana'

foreach ($repository in $repositories) {
    $sourceTag = "$($env:dockerId)/$($repository)"
    $targetTag = "$($env:dockerId)/$($repository):rtm"
    docker image tag $sourceTag $targetTag
    docker image push $targetTag
}
```

### Switch to swarm mode

> This part is for the **manager**

On the manager's VM, save the machine's IP address to a local variable (you will aready have this set if you've followed [Part 6](part-6.md)):

```
ipconfig
```

The server's internal IP address will start with `10.0.0`:

```
$ipAddress='<ip address - 10.0.0.x>'
```

Now leave the single-node swarm and initialize a swarm which other VMs can join:

```
docker swarm leave -f 

docker swarm init --listen-addr $ipAddress --advertise-addr $ipAddress
```

The output is a `swarm join` command which you need to share with your buddies. The workshop Slack channel is fine for that. Docker generates a unique join token for each swarm, and we'll be destroying all the VMs after the workshop.

> This part is for the **worker(s)**

Leave your single-node swarm:

```
docker swarm leave -f
```

And then run the `docker swarm join` command which your manager has shared with you. 

Now you can sit back for a while. In swarm mode all the work gets scheduled on the manager node, so you'll be a passenger for the next few steps.

> This part is for the **manager**

Check you have all the expected nodes in the swarm:

```
docker node ls
```

When your swarm is up and running, you can move on to deploying the app.


## <a name="3"></a>Step 3. Deploy the application as services

> This part is for the **manager**

You can create a distributed application as services, by joining all the services to an [overlay network](https://docs.docker.com/engine/swarm/networking/). Overlay networking lets containers running on different nodes communicate across the swarm, using the same service discovery built into the Docker platform.

Run the [create-services.ps1](part-7/create-services.ps1) deployment script to create the overlay network and all the services:

```
cd $env:workshop\part-7

.\create-services.ps1
```

When Docker schedules containers to run, it will pick nodes based on their available capacity. On a multi-node swarm you should find that containers are running on every node.

Find out which node is hosting the web application and which is hosting Kibana:

```
docker service ps signup-web

docker service ps kibana
```

> This part is for the **manager** and the **worker(s)**

List the containers running on your node:

```
docker container ls
```

These are containers scheduled by the swarm. You can connect to them and run commands just like ordinary containers, but typically you leave the swarm workers and the containers alone, and do operational tasks on the manager.

Browse to the web application **on your laptop** using the DNS name of the node hosting the web service (e.g. `http://dceu-00.westeurope.cloudapp.azure.com`). Enter some propect details.

Browse to Kibana **on your laptop** using the DNS name of the node hosting the Kibana service, and the Kibana port `5601` (e.g. `http://dceu-00.westeurope.cloudapp.azure.com:5601`). You should be able to set up the `Prospects` index in Elasticsearch and see all the details you've put in.

All the application containers are in the same overlay network, so they can communicate across nodes - without any change to the application code, the Docker images or the app configuration.

You can try killing containers, stopping the Docker service and leaving the swarm - on a multi-node cluster, the application will stay up.

> This part is for the **manager** 

Running services with a script isn't so good for ongoing management, because it's not clear that all the resources are part of the same solution.

We'll go on to fix that with a stack deployment, but first remove all the services:

```
docker service rm $(docker service ls -q)
```

## <a name="4"></a>Step 4. Deploy the application as a stack

Stacks use the same [Docker Compose file format](https://docs.docker.com/compose/compose-file/) we've used in the workshop. There are some attributes which only apply to swarm mode (like the `deploy` section), and some which are ignored in swarm mode (like `depends_on`).

You can combine multiple compose files together to make a single stack file. That's very useful for keeping a centralized solution definition in one compose file, and adding environment-specific overrides in other files.

For our production deployment we'll use these two files: [docker-compose.yml](part-7/docker-compose.yml) - which is much the same as the v1.8 compose file we deployed in [Part 5](part-5.md) - and [docker-compose.prod.yml](part-7/docker-compose.prod.yml), which contains swarm-specific deployment details.

> Everyone can do this part

Use Docker Compose to combine the two files into one stack file:

```
cd $env:workshop\part-7

docker-compose -f docker-compose.yml -f docker-compose.test.yml config > docker-stack.yml
```

You'll see the stack file joins the contents of the compose files, and adds the contents of the environment variables file. The passwords are in plain text which is obviously not good. The correct way is to use [Docker secrets](https://docs.docker.com/engine/swarm/secrets/), like in [this version](https://github.com/dockersamples/newsletter-signup) of the sample app.

> This part is for the **manager** 

Deploy the stack:

```
cd $env:workshop\part-7

docker stack deploy -c docker-stack.yml signup
```

Docker creates all the resources in the stack: an overlay network, and a set of services. As before, it will deploy service tasks across the swarm, so you should see containers running on many nodes.

The stack is a first-class object in swarm mode. You can see the stacks which are running, and the services which are in the stack:

```
docker stack ls

docker stack ps signup
```

You can navigate around the services, and make changes to the deployment. Here are a few things to try:

- scaling the message handlers up and down
- scaling the web application up, so there are as many replicas as you have nodes in the swarm
- scaling the web application up even more - what happens?
- saving some prospects and then removing the SQL Server container
- browsing to Grafana - is it showing the dashboard we set up earlier?

## And we're done!

That was a good day's work. 

You've seen how to run Windows apps in Docker containers, add third-party components to your solution, break features out of monoliths, add consistent instrumentation, run a CI pipeline, and deploy Dockerized solutions in a highly-available cluster.

You've done what you need to move your own apps to Docker in production!

> Want to hear more from your workshop team? **We're here all week!**

- [Stefan](https://twitter.com/stefscherer) has a group chat set up on the Hallway Track, I'm sure he'll be happy to field any questions about the workshop :) [Let's talk about Windows containers](https://hallwaytrack.dockercon.com/offers/31858) **tonight at 17:15**

- [Michael](https://twitter.com/friism) is presenting [Docker Multi-arch All the Things](https://dockerconeurope.smarteventscloud.com/connect/sessionDetail.ww?SESSION_ID=139237) with Docker Captain [Phil Estes](https://twitter.com/estesp) on **Tuesday at 14:00**

- [Elton](https://twitter.com/EltonStoneman) is presenting with the excellent [Iris Classon](https://twitter.com/IrisClasson) about using Docker to [Modernize .NET Apps](https://dockerconeurope.smarteventscloud.com/connect/sessionDetail.ww?SESSION_ID=131868) on **Tuesday at 17:10**

 Next steps:

- try one of the [Docker labs on GitHub](https://github.com/docker/labs)
- follow [@EltonStoneman](https://twitter.com/EltonStoneman), [@stefscherer](https://twitter.com/stefscherer) and [@friism](https://twitter.com/friism) on Twitter
- read [Docker on Windows](https://www.amazon.co.uk/Docker-Windows-Elton-Stoneman/dp/1785281658), the book
- go Dockerize!
