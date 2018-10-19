# `nsb` branch

> This is a branch of the workshop code with NServiceBus used to break down the original monolith

# Docker Windows Workshop

The latest release is published at https://dwwx.space

> This is the full workshop content, which can be tailored for individual deliveries.

## Docker on Windows Workshop: From 101 to Production

Docker is a platform for running applications in lightweight units of compute called containers. You can run new and old apps in containers, and get increased portability, security and efficiency for your software. The platform supports the full development and deployment lifecycle - with Docker you can build, ship and run any app anywhere.

Docker has production support for containers on Windows Server 2016, and Windows containers don't need separate licencing. Migrating your apps to Docker is a great way to increase utilization in your datacenter, or to prepare for a move to the cloud. When your app is running in Docker, it's easy to break features out and run them in separate containers, so you can deploy updates to your app without a full regression test.

In this workshop you'll use Docker EE on Windows Server 2016*. In the morning you'll learn:

- how Docker containers work on Windows
- how to package existing .NET apps using Docker
- how to break features out from a monolith into separate containers
- how to add monitoring to your containers

For full-day workshops, in the afternoon you'll carry on and learn:

- how Docker supports resilience and scale on a single server
- how to run a full CI pipeline using Docker
- how Docker swarm mode provides production-grade orchestration.

> It doesn't matter if you're from a dev or an ops background, you'll learn how the Docker platform benefits all aspects of IT.

_* - you don't need your own Windows Server machine, you'll be provided with a VM in the cloud. You just need a Remote Desktop client so you can connect._

### Previous versions

This workshop is a living thing. There are tags or branches for previous versions.

#### 2018

- [techoramanl18](https://github.com/sixeyed/docker-windows-workshop/tree/techoramanl18) - Techorama NL 2018, hosted [here](https://techoramanl18--dwwx.netlify.com) 

- [slcnet](https://github.com/sixeyed/docker-windows-workshop/tree/slcnet) - Salt Lake City .NET user group, hosted [here](https://slcnet--dwwx.netlify.com) 

- [dcus18](https://github.com/sixeyed/docker-windows-workshop/tree/dcus18) - DockerCon 2018, hosted [here](https://dcus18--dwwx.netlify.com) 

- [devsum18](https://github.com/sixeyed/docker-windows-workshop/tree/devsum18) - DevSum 2018, hosted [here](https://devsum18--dwwx.netlify.com) 

- [docker-bangalore-18](https://github.com/sixeyed/docker-windows-workshop/tree/docker-bangalore-18) - From the [Docker Bangalore MeetUp](https://www.meetup.com/Docker-Bangalore/events/249634763/), April

- [winops-feb18](https://github.com/sixeyed/docker-windows-workshop/tree/winops-feb18) - From the [London WinOps MeetUp #19](https://www.meetup.com/WinOps/events/247873979/), February

#### 2017

- [xpirit-17](https://github.com/sixeyed/docker-windows-workshop/tree/xpirit-17) - From Xpirit's [Docker on Microsoft MeetUp](https://www.meetup.com/Docker-with-Microsoft-Technologies/events/244448740)

- [dockercon-eu-17](https://github.com/sixeyed/docker-windows-workshop/tree/dockercon-eu-17) - from [DockerCon EU](https://europe-2017.dockercon.com)

- [winops-17](https://github.com/sixeyed/docker-windows-workshop/tree/winops-17) - from [WinOps Conference](https://www.winops.org/london/#dockerWS)

- [containercamp-17](https://github.com/sixeyed/docker-windows-workshop/tree/containercamp-17) - from [Container Camp](https://2017.container.camp/uk/) London

- [devsum-17](https://github.com/sixeyed/docker-windows-workshop/tree/devsum-17) - from [DevSum 2017](http://www.devsum.se/)


### Repo Structure

```
├───app
├───docker
├───slides
├───src
├───workshop
└───_archive
```

* `app` - Docker Compose files covering the evolution of the demo app
* `docker` - Dockerfiles and content for the container images
* `slides` - workshop content published with Reveal.js to [dwwx.space](https://dwwx.space)
* `src` - source code for the .NET solution
* `workshop` - logistics for in-person workshops
* `_archive` - all the old content, preserved during transition to Reveal.js
