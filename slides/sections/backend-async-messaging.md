# Switching to Asynchronous Messaging

---

<section data-background-image="/img/backend/Slide2.png">

---

Right now the app saves data by synchronously connecting to SQL Server. That's a bottleneck which will stop the app performing if there's a peak in traffic.

We'll fix that by using a message queue instead - running in a Docker container. 

When you sign up the web app will publish an event message on the queue, which a message handler picks up and actions. The message handler is a .NET Framework console app running in another container.

---

## The save message handler

The new component is a simple .NET Console app. You can browse the [source for the save message handler](./src/SignUp.MessageHandlers.SaveProspect) - the work is all done in the `Program` class.

This is a full .NET Framework app, so it can continue to use the original Entity Framework model from the monolith. It's a low-risk approach to updating the architecture.

---

## Build the message handler

Check out the [Dockerfile](./docker/backend-async-messaging/save-handler/Dockerfile) for the message handler. 

It uses the same principle to compile and package the app using containers, and the images use .NET Framework running on Windows Server Core. 

_Build the message handler image:_

```
docker image build `
  -t dwwx/save-handler `
  -f .\docker\backend-async-messaging\save-handler\Dockerfile .
```

---

## Using asynchronous messaging

Check out the [v4 manifest](./app/v4.yml) - it adds services for the message handler and the message queue.

The message queue is [NATS](https://nats.io), a high-performance in-memory queue which is ideal for communication between containers.

The manifest also configures the web app to use messaging - using Dependency Injection to load a different implementation of the prospect save handler.

---

## Upgrade to use the message handler

_Upgrade to v4:_

```
docker-compose -f .\app\v4.yml up -d
```

---

## Check the message handler

You now have a message queue and a message handler running in containers. 

The message handler writes console log entries, so you can see that it has connected to the queue and is listening for messages.

_Check the handler logs:_

```
docker container logs app_signup-save-handler_1
```

> You should see that the handler is connected and listening.

---

## Try the new distributed app

The entrypoint is still the proxy listening on port `8020`, so you can refresh your page or [open a new browser window](http:/localhost:8020):

```
firefox http:/localhost:8020
```

> Now when you submit data, the web app publishes an event and the handler makes the database save

---

## Try out the new version

Click the _Sign Up!_ button, fill in the form and click _Go!_ to save your details.

The UX is the same, but the save is asynchronous. You can see that in the logs for the message handler.

_Check the handler logs:_

```
docker container logs app_signup-save-handler_1
```

> You should see that the handler has receievd and actioned a message, and it gets an ID back from the database

---

## Let's just check that

To be sure, let's make sure the data has really been saved in the database.

_Check the new data is there in the SQL container:_

```
docker container exec app_signup-db_1 powershell `
  "Invoke-SqlCmd -Query 'SELECT * FROM Prospects' -Database SignUp"
```

---

## All good

Now we've got an event driven architecture! Well, not completely - but for one key path through our application, we have event publishing.

You can easily extend the app now by adding new message handlers which subscribe to the same event.

A new message handler could insert data into Elasticsearch and let users run their own analytics with Kibana...
