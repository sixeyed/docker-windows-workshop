# Exporting Runtime Metrics

---

Containerized applications give you new opportunities for monitoring. You export metrics from each container, collect them centrally and show your whole application health in a dashboard.

The metrics collector and dashboard run in containers too, so now you can run the exact same metrics stack in dev that you use in production.

---

## Application runtime metrics

Apps running in Windows containers already have metrics. Windows Performance Counters get collected in containers in the same way that they are on Windows Server.

You can export IIS Performance Counters from web containers to get key  metrics about the runtime without having to change your code. 

You do that by packaging an exporter utility alongside your web application.

---

## Expose IIS metrics from the web app

Here's a new version of the [web application Dockerfile](./docker/metrics-runtime/signup-web/Dockerfile). It packages a metrics exporter utility.

The utility app reads from Windows Performance Counters and publishes them as an API on port `50505`.

> The web code is unchanged. The exporter comes from the [dockersamples/aspnet-monitoring](https://github.com/dockersamples/aspnet-monitoring) sample app.

---

## Build the new web app image

The new version includes the metrics exporter utility. It's configured to run in the background, making the container's IIS and ASP.NET Performance Counter values available in Prometheus format.

_Build the updated web app:_

```
docker image build --tag dwwx/signup-web:v3 `
 --file ./docker/metrics-runtime/signup-web/Dockerfile .
```

---

## Run the new web app

You can run the new version in a container just to check the metrics it exposes.

_Run the new web app, connecting to the existing database:_

```
docker container run -d --publish-all `
  -e ConnectionStrings:SignUpDb='Server=signup-db;Database=SignUp;User Id=sa;Password=DockerCon!!!' `
  --name web-v3 dwwx/signup-web:v3
```

> `publish-all` publishes the container port to a random port on the host

---

## Generate some load

HTTP requests to the new container will start the ASP.NET worker process, and the Windows Performance Counters will be collected.

_Grab the port of the container and send in some requests:_

```
$port = $(docker container port web-v3 80).Replace('0.0.0.0:', '')

for ($i=0; $i -le 10; $i++) { Invoke-WebRequest "http://localhost:$port/app" -UseBasicParsing | Out-Null}
```

> This snippet just finds the container port and makes some GET requests

---

## Check out the runtime metrics

Now you can look at the metrics which the exporter utility makes available. You'll see stats in there from the IIS and .NET Performance Counters.

_Fetch the metrics port and browse to the exporter endpoint:_

```
$metricsPort = $(docker container port web-v3 50505).Replace('0.0.0.0:', '')

firefox "http://localhost:$metricsPort/metrics"
```

> This is Prometheus format. Prometheus is the most popular metrics server for cloud-native apps, and the format is widely used.

---

## Tidy up

The metrics endpoint isn't meant for humans to read, it's an API for Prometheus to consume. 

Now we know how the metrics look, let's remove the new container:

```
docker rm --force web-v3
```

> `force` removes a container even if it's still running

---

## Key metrics for legacy apps

Runtime metrics can tell you how hard your app is working. In this case there are key details from the IIS runtime, which you can put into your application dashboard:

- requests per second processed
- amount of virtual memory used
- amount of CPU used
- number of active threads

> Using an exporter utility gives you all this without changing code - perfect for legacy apps. 