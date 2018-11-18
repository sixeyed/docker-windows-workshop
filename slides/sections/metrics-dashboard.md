# Running a Metrics Dashboard

---

Exposing metrics endpoints from all your app containers is the first step to getting consistent monitoring.

Next you need to run two other components - a metrics server, which grabs and stores all the metrics from your containers, and a dashboard which presents the data in a usable way.

We'll do that by running Promtheus and Grafana - the leading tools in this space - in containers alongside our app.

---

<section data-background-image="/img/metrics/Slide1.png">

---

## About Prometheus

Prometheus is a metrics server. It runs a time-series database to store instrumentation data, polls configured endpoints to collect data, and provides an API (and a simple Web UI) to retrieve the raw or aggregated data.

The Prometheus team maintain a Docker image for Linux, but we'll use a Windows Docker image from [dockersamples/aspnet-monitoring](https://github.com/dockersamples/aspnet-monitoring).

---

## Build the Prometheus image

Prometheus uses a simple configuration file, listing the endpoints to scrape for metrics. 

We'll use [this Dockerfile](./docker/metrics-dashboard/prometheus/Dockerfile) to bundle a custom [prometheus.yml](./docker/metrics-dashboard/prometheus/prometheus.yml) file on top of the existing Prometheus image..

```
cd $env:workshop; `

docker image build -t dwwx/prometheus `
  -f ./docker/metrics-dashboard/prometheus/Dockerfile .
```

> Now you have a Docker image that will run Prometheus with your custom config.

---

## About Grafana

Grafana is a dashboard server. It can connect to data sources and provide rich dashboards to show the overall health of your app. 

There isn't an official Windows variant of the Grafana image, but we can use the one from [dockersamples/aspnet-monitoring](https://github.com/dockersamples/aspnet-monitoring). 

Grafana has an API you can use to automate setup, and we'll use that to build a custom Docker image.

---

## Customizing Grafana

To make a custom Grafana image, you need to configure a data source, create users and deploy your own dashboard. The [Grafana Dockerfile](./docker/metrics-dashboard/grafana/Dockerfile) does that.

It uses a [data source provisioning](TODO) and [dashboard provisioning](TODO), which is standard Grafana functionality, and the Grafana API to set up a read-only user.

---

## Build the Grafana image

_ Build the custom Grafana image: _

```
cd $env:workshop; `

docker image build -t dwwx/grafana `
  -f ./docker/metrics-dashboard/grafana/Dockerfile .
```

---

## Run the app with metrics

Now you can deploy the updated application. The [v6 manifest](./app/v6.yml) uses the upgraded web app and message handlers, and includes containers for Prometheus and Grafana.

_ Update the running application: _

```
docker-compose -f .\app\v6.yml up -d
```

> Compose will recreate changed services and start new ones.

---

## Use the app to record some metrics

Browse to the new proxy container, and send some load - refresh the sign up page a few times, and then submit the form:

```
$ip = docker container inspect `
  --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_proxy_1

firefox "http://$ip"
```

---

## Check the data in Prometheus

The web application and the message handlers are collecting metrics now, and Prometheus is scraping them. 

_ Browse to the Prometheus UI to see the metrics:_

```
$ip = docker container inspect `
  --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_prometheus_1

firefox "http://$($ip):9090"
```

---

## CPU metrics in Prometheus

Try looking at the `process_cpu_seconds_total` metric in Graph view. This shows the amount of CPU in the message handlers, which is exported from a standard .NET performance counter. 

The Prometheus UI is good for browsing the collected metrics and building up complex queries.

But the Prometheus UI isn't featured enough for a dashboard - that's why we have Grafana. 

---

## Browse to Grafana

The Grafana container is already running with a custom dashboard, reading the application and runtime metrics from Prometheus.

_ Browse to the Grafana container: _

```
$ip = docker container inspect `
  --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_grafana_1

firefox "http://$($ip):3000"
```

---

## Open the dashboard

Login with the credentials for the read-only account created in the Grafana Docker image:

- _Username:_ **viewer**
- _Password:_ **readonly**

> You'll see the dashboard showing real-time data from the app. The app dashboard is set as the homepage for this user.

---

## Check out the dashboard

The dashboard shows how many HTTP requests are coming in to the web app, and how many events the handlers have received, processed and failed.

It also shows memory and CPU usage for the apps inside the containers, so at a glance you can see how hard your containers are working and what they're doing.

---

## Ready for production

Containerized apps run on dynamic container platforms. maybe with hundreds of containers running across dozens of servers in production.

A metrics dashboard like this is essential to being ready for production - so when you go live you can be confident that your app is working correctly.

> There's one missing piece from this dashboard - metrics from the Docker platform itself. I cover that in [Monitoring Containerized Application Health](https://pluralsight.pxf.io/c/1197078/424552/7490?u=https%3A%2F%2Fwww.pluralsight.com%2Fcourses%2Fmonitoring-containerized-app-health-docker).