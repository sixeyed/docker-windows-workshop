# Running a Metrics Dashboard

---

Exposing metrics endpoints from all your app containers is the first step to getting consistent monitoring.

Next you need to run two other components - a metrics server, which grabs and stores all the metrics from your containers, and a dashboard which presents the data in a usable way.

We'll do that with Promtheus and Grafana, the leading tools in this space.

---

## About Prometheus

Prometheus is a metrics server. It runs a time-series database to store instrumentation data, polls configured endpoints to collect data, and provides an API (and a simple Web UI) to retrieve the raw or aggregated data.

The Prometheus team maintain a Docker image for Linux, but we'll use a Windows Docker image from [dockersamples/aspnet-monitoring](TODO).

---

## Build the Prometheus image

Prometheus uses a simple configuration file, listing the endpoints it should scrape for metrics. We'll use an existing Prometheus image, and bundle a custom [prometheus.yml](TODO) file on top.

.exercise[
    ```
    cd "$env:workshop\part-4\prometheus"

    docker image build --tag $env:dockerId/signup-prometheus .
    ```]

---

## About Grafana

Grafana is a dashboard server. It can connect to various data sources and provide rich dashboards to show the overall health of your app. There isn't an official Windows variant of the Grafana image, but it's easy to build your own. 

The [Dockerfile for Grafana](part-4/grafana/Dockerfile) is a good example of how to package third-party apps to run in containers.

---

## Build the Grafana image

.exercise[
    ```
    cd "$env:workshop\part-4\grafana"

    docker image build --tag $env:dockerId/signup-grafana .
    ```]

---

## Upgrade the app

Now you can deploy the updated application. Use Docker Compose to update the containers to [version 1.6](app/docker-compose-1.6.yml) of the solution:

.exercise[
    ```
    cd "$env:workshop\app"

    docker-compose -f .\docker-compose-1.6.yml up -d
    ```]

---

## Use the app to record some metrics

Browse to the new application container, and send some load - refresh the homepage a few times, and then submit a form:

.exercise[
    ```
    $ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_signup-web_1

    firefox "http://$ip"
    ```]

---

## Check the data in Prometheus

The web application and the message handlers are collecting metrics now, and Prometheus is scraping them. You can see the metrics data collected in the basic Prometheus UI:

.exercise[
    ```
    $ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_prometheus_1

    firefox "http://$($ip):9090"
    ```]

---

## CPU metrics in Prometheus

Try looking at the `process_cpu_seconds_total` metric in Graph view:

![Prometheus UI](/img/prometheus-metrics.png)

This shows the amount of CPU in the message handlers, which is exported from a standard .NET performance counter. 

The Prometheus UI is good for sanity-checking the metrics collection. Prometheus itself records metrics, so you can look at the `scrape_samples_scraped` metric to see how many times Prometheus has polled the container endpoints.

But the Prometheus UI isn't featured enough for a dashboard - for that we'll set up Grafana. 

## Browse to Grafana

First browse to the Grafana container:

.exercise[
    ```
    $ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_grafana_1

    firefox "http://$($ip):3000"
    ```]

---

## Set up the Grafana data source

- Login with credentials `admin` / `admin`

- Select _Add data source_ and configure a new Prometheus data source as follows:

![Grafana data source](/img/grafana-add-data-source.PNG)

- Name: `Sign Up`
- Type: `Prometheus`
- Url: `http://prometheus:9090`
- Access: `proxy`

That sets up Grafana so it can read the metrics collected by Prometheus. You can build your own dashboard to show whatever metrics you like, but I have one prepared for the workshop which you can import.

---

## Configure the Grafana dashboard

From the main menu select _Dashboards...Import_, load the `SignUp-dashboard.json` file in `C:\scm\docker-windows-workshop\part-4\grafana` and connect it to the Prometheus data source:

![Grafana dashboard import](/img/grafana-import-dashboard.png)

You'll see an overall dashboard showing the status and performance of the web application and the message handlers.

---

## Check out the dashboard

![Grafana dashboard](/img/grafana-dashboard.png)

The dashboard shows how many HTTP requests are coming in to the web app, and how many events the handlers have received, processed and failed.

It also shows memory and CPU usage for the apps inside the containers, so at a glance you can see how hard your containers are working and what they're doing.

---

## Next Up

For a half-day workshop, we're done! You've seen how to run Windows apps in Docker containers, add third-party components to your solution, break features out of monoliths, and add consistent instrumentation. 

You've done what you need to move your own apps to Docker in production. Next steps:

- try one of the [Docker labs on GitHub](https://github.com/docker/labs)
- follow [@EltonStoneman](https://twitter.com/EltonStoneman) and [@stefscherer](https://twitter.com/stefscherer) on Twitter
- read [Docker on Windows](https://www.amazon.co.uk/Docker-Windows-Elton-Stoneman/dp/1785281658), the book
- watch [Modernizing .NET Apps with Docker on Pluralsight](https://pluralsight.pxf.io/c/1197078/424552/7490?u=https%3A%2F%2Fwww.pluralsight.com%2Fcourses%2Fmodernizing-dotnet-framework-apps-docker), the video course (don't have Pluralsight? Ping @EltonStoneman on Twitter to get a free trial).

For a whole-day workshop, we'll continue after lunch. In [Part 5](part-5.md) you'll learn how to add resilience and scalability to your apps with Docker Compose.