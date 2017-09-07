# Docker on Windows Workshop: From 101 to Production

Docker is a platform for running applications in lightweight units of compute called containers. You can run new and old apps in containers, and get increased portability, security and efficiency for your software. The platform supports the full development and deployment lifecycle - with Docker you can build, ship and run any app anywhere.

Docker has production support for containers on Windows Server 2016, and Windows containers don't need separate licencing. Migrating your apps to Docker is a great way to increase utilization in your datacenter, or to prepare for a move to the cloud. When your app is running in Docker, it's easy to break features out and run them in separate containers, so you can deploy updates to your app without a full regression test.

In this full-day workshop you'll use Docker EE on Windows Server 2016* and learn:

- how Docker containers work on Windows
- how to package existing .NET apps using Docker
- how to break features out from a monolith into separate containers
- how to add monitoring to your containers
- how Docker supports resilience and scale on a single server
- how to run a full CI pipeline using Docker
- how Docker swarm mode provides production-grade orchestration.

> It doesn't matter if you're from a dev or an ops background, you'll learn how the Docker platform benefits all aspects of IT.

_* - you don't need your own Windows Server machine, you'll be provided with a VM in the cloud. You just need a Remote Desktop client so you can connect._

## Agenda

The workshop starts with an overview presentation. I'll talk about Docker and Windows containers, and tailor the content to the group - it can be a Docker 101 for folks new to containers, or a comparison of Windows and Linux containers for folks already comfortable with Docker on Linux.

> During the presentation is a good time to make sure your environment is set up correctly

- [Check your setup](setup.md)

Then we'll work together through the tasks in the workshop.

For a morning workshop, we'll do Parts 1-4:

- [Part 1](part-1.md) - running Docker on Windows
- [Part 2](part-2.md) - packaging an existing ASP.NET app in Docker
- [Part 3](part-3.md) - modernizing the ASP.NET app with Docker
- [Part 4](part-4.md) - preparing for production with instrumentation

For a full day workshop, we continue in the afternoon with parts 5-7.

- [Part 5](part-5.md) - resilience and scalability with Docker Compose
- [Part 6](part-6.md) - containerized CI (and CD) with Docker
- [Part 7](part-7.md) - production-ready orchestration with Docker swarm mode


### Previous versions

This workshop is a living thing. There are tags for previous versions:

- [devsum-17](https://github.com/sixeyed/docker-windows-workshop/tree/devsum-17) - from the [DevSum Conference](http://www.devsum.se/), 2017

- [containercamp-17](https://github.com/sixeyed/docker-windows-workshop/tree/containercamp-17) - from [Container Camp](https://2017.container.camp/uk/) London, 2017