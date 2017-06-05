# Part 3 - Modernizing .NET apps - the architecture

In this section we have an existing app, already packaged as an MSI. We'll Dockerize a few versions of the app, seeing how to do service updates and the benefits of Dockerfiles over MSIs.

## Steps

* [1. Fix database bottleneck by making the save asynchronous](#1)
* [2. Add self-service analytics with Elasticsearch and Kibana](#2)
* [3. Replace the home page with a refreshed design](#3)

## <a name="1"></a>Step 1. Fix bottleneck by making the save asynchronous

The current code makes a synchronous call to SQL Server to insert a row when a user signs up. That's a bottleneck which will stop the app performing if there's a peak in traffic.

We'll fix that by using a message queue instead - running in a Docker container. When you sign up the web app will drop a message on a queue, which a message handler picks up and actions. The message handler is a .NET console app running in a container.

First you need to change some code. Open`.\signup\src\SignUp.Web\SignUp.aspx.cs` in VS Code (or Notepad or whatever editor you like). Comment out the `SavePropsect` call at line 74, and uncomment the `PublishProspectSignedUpEvent` call at line 78. The section should look like this:

```
            /* synchronous */
            // SaveProspect(prospect);           

            /* aynchronous */
            PublishProspectSignedUpEvent(Prospect prospect);
```

That replaces the synchronous SQL insert with message publishing. You can see the code for the message handler which subscribes to the message in [Program.cs](src/ProductLaunch/ProductLaunch.MessageHandlers.SaveProspect/Program.cs). That will be packaged into a new image with this [Dockerfile](part-3/v1.3/save-handler/Dockerfile).

You need to build a new version of the web image, and a new message handler image:

```
cd C:\scm\github\sixeyed\dc-mta-workshop

docker build -t $Env:dockerId/mta-app:1.3 -f part-3\v1.3\web\Dockerfile .

docker build -t $Env:dockerId/mta-save-handler -f part-3\v1.3\save-handler\Dockerfile .

```

Then upgrade the application in the same way. This will replace the web app container and create new containers for the message queue and the handler. In the [v1.3 Docker Compose file](app/docker-compose-1.3.yml) you'll see we're using the [official image](https://hub.docker.com/_/nats/) for the [NATS](https://nats.io/) message queue:

```
cd C:\scm\github\sixeyed\dc-mta-workshop\app

docker-compose -f .\docker-compose-1.3.yml up -d
```

> This is a new web container, so there's time to finish that story while we wait for the healthcheck.

Browse to the application and you'll see the UI and UX haven't changed:

```
$ip = docker inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_mta-app_1
start "http://$ip/ProductLaunch"
```

When you save your details this time, they still get saved in SQL Server. But also check the logs of the message handler and you'll see that the insert was done by the console app when it received the message from the queue:

```
docker exec app_mta-db_1 powershell "Invoke-SqlCmd -Query 'SELECT * FROM Prospects' -Database ProductLaunch"

docker logs app_mta-save-handler_1
```

Now when there are spikes in traffic, the message queue will smooth them out. The web app won't slow down waiting for SQL Server, and SQL Server doesn't need to scale up to deal with load.

## <a name="2"></a>Step 2 - Add self-service analytics

The app performs better now, but all the data is stored in SQL Server which isn't very friendly for business users to get reports. Next we'll add self-service analytics, using more enterprise-grade open-source software on Docker Hub.

We'll be running [Elasticsearch](https://www.elastic.co/products/elasticsearch) for storage and [Kibana](https://www.elastic.co/products/kibana) to provide an accessible front-end. To populate Elasticsearch with data when a user signs up, we just need to add another message handler, which will listen to the same messages published by the web app.

The code for that is in another [Program.cs](src/ProductLaunch/ProductLaunch.MessageHandlers.IndexProspect/Program.cs). You'll build it in the same way, using this [Dockerfile](part-3/v1.4/index-handler/Dockerfile):

```
cd C:\scm\github\sixeyed\dc-mta-workshop

docker build -t $Env:dockerId/mta-index-handler -f part-3\v1.4\index-handler\Dockerfile .

```

And now when you ugrade the application to the [v1.4 Docker Compose file](app/docker-compose-1.4.yml), none of the existing containers get replaced - their configuration hasn't changed. Only the new containers get created:

```
cd :\scm\github\sixeyed\dc-mta-workshop\app

docker-compose -f .\docker-compose-1.4.yml up -d
```

Go back to the sign-up page in your browser to add another user and you'll see the data still gets added to SQL Server, but now both message handlers record dealing with the message:

```
docker logs app_mta-save-handler_1

docker exec app_mta-db_1 powershell "Invoke-SqlCmd -Query 'SELECT * FROM Prospects' -Database ProductLaunch"

docker logs app_mta-index-handler_1
```

You can add a few more users with different roles and countries, if you want to see the data nicely in Kibana. Kibana is also a web app running in a browser:

```
$ip = docker inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_kibana_1
start "http://$ip:5601"
```

The Elasticsearch index is called `prospects`, and you can navigate around the data from Kibana. 

Kibana has a great feature set and it's easy to pick up for power users. They can do their own analytics or build dashboards for other users - no more IT requests to get reports out from SQL Server!


## <a name="3"></a>Step 3 - Replace homepage

The last update we'll do is to replace the design of landing page, rendering it from a dedicated container. That allows for rapid iteration from the design team - the homepage can be replaced without regression testing the whole of the app.

There's a new image to build for the homepage component, which is just a static HTML site built with this [Dockerfile](part-3/v1.5/homepage/Dockerfile):

```
cd C:\scm\github\sixeyed\dc-mta-workshop\part-3\v1.5\homepage

docker build -t $Env:dockerId/mta-homepage .

```
In the [v1.5 Docker Compose file](app/docker-compose-1.5.yml) there's a new environment variable for the web application. That's used as a feature switch - the app already has the code to fetch homepage content from a separate component, if this variable is set.

Upgrade the application with compose again:

```
cd C:\scm\github\sixeyed\dc-mta-workshop\app

docker-compose -f .\docker-compose-1.5.yml up -d
```

And because the web app configuration has changed, there will be a new web container to browse to:

```
$ip = docker inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_mta-app_1
start "http://$ip/ProductLaunch"
```

Now you'll see the awesome new site design. You can still click through to the original sign up page, and enter details which get saved in SQL Server and Elasticsearch as before.

## Wrap Up

That's all! Thanks for coming. We hope you had a good time and learned plenty about Docker on Windows. 

> Have a great #dockercon!
