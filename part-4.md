# Part 4 - Preparing for Production with Instrumentation

The app is ready to be promoted to production now, but we'll have problems when we run at scale. Supporting production may mean running dozens of web containers and message handlers, and currently the only instruementation we have is text log entries. In Docker all containers look the same, whether they're running ASP.NET WebForms apps or .NET Core console apps - and you expose metrics from containers to give you a single dashboard for the performance of your app.

In this section we'll add metrics to the solution using Prometheus -a popular open-source monitoring server, and Grafana - a dashboard that plugs into Prometheus. We'll run those new components in Docker Windows containers too.

## Steps

* [1. Record custom metrics in the message handlers](#1)
* [2. Expose IIS metrics from the web application](#2)
* [3. Run the solution with Prometheus and Grafana](#3)

## <a name="1"></a>Step 1. Fix bottleneck by making the save asynchronous

The