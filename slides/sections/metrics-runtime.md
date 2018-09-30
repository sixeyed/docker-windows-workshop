# Exposing Runtime Metrics

---

Containerized applications give you new opportunities for monitoring. You expose metrics from each container, collect them centrally and showyour whole application health in a dashboard.

The metrics collector and dashboard run in containers too, so now you can run the exact same metrics stack in dev that you use in production.

---

## Application runtime metrics

Apps running in Windows containers already collect metrics. Windows Performance Counters run in containers in the same way that they do on Windows Server.

You can export IIS Performance Counters from web containers to get key metrics without having to change your code - you package an exporter utility alongside your web application.

---

## Expose IIS metrics from the web app

Here's a new version of the [web application Dockerfile](./docker/metrics-runtime/signup-web/Dockerfile). It packages a metrics exporter utility.

The utilit app reads from Windows Performance Counters and publishes them as an API on port `50505`.

> The web code is unchanged. The exporter comes from the [dockersamples/aspnet-monitoring](TODO) sample app.

---

## Build the new web app image

The new version includes the metrics exporter:

```
cd $env:workshop; `

docker image build --tag dwwx/signup-web:v3 `
 --file ./docker/metrics-runtime/signup-web/Dockerfile .
```

---

## Run the new web app

You can run the new version in a container just to check the metrics you get out.

```
docker container run -d -P --name web-v3 dwwx/signup-web:v3
```

> Windows containers connect to the same default Docker network, so this container will use the existing database and message queue.

---

## Generate some load

Browse to the app and refresh the page a few times:

```
$ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' web-v3; `

firefox "http://$ip"
```

> This starts the `w3wp` worker process, which will start recording metrics in IIS and .NET Performance Counters.

---

## Check out the runtime metrics

Now you can look at the metrics which the exporter utility makes available:

```
firefox "http://$($ip):50505/metrics"
```

> The metrics API uses the Prometheus format. Prometheus is the most popular metrics server for cloud-native apps, and the format is widely used.

---

## Key metrics for legacy apps

Runtime metrics can tell you how hard your app is working. In this case there are key details from the IIS runtime, which you can put into your application dashboard:

- requests per second processed
- amount of virtual memory used
- amount of CPU used
- number of active threads

> Using the exporter utility gives you all this without changing code - perfect for legacy apps. 