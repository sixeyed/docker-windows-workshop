using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using NServiceBus;
using Prometheus;
using SignUp.Core;
using SignUp.Messaging.Endpoints;

namespace SignUp.MessageHandlers.SaveProspect
{
    class Program
    {
        private static ManualResetEvent _ResetEvent = new ManualResetEvent(false);
                
        static async Task Main(string[] args)
        {
            if (Config.Current.GetValue<bool>("Metrics:Enabled"))
            {
                StartMetricServer();
            }

            var transportType = Config.Current["NServiceBus:Transport"];
            Console.WriteLine($"Connecting to NServiceBus, transport: {transportType}");

            var endpointConfiguration = new EndpointConfiguration("ProspectSave");
            var transport = TransportConfigurationFactory.SetTransport(endpointConfiguration, transportType);
            var endpointInstance = await Endpoint.Start(endpointConfiguration).ConfigureAwait(false);

            Console.WriteLine($"Listening.");

            _ResetEvent.WaitOne();
            await endpointInstance.Stop().ConfigureAwait(false);
        }

        private static void StartMetricServer()
        {
            var metricsPort = Config.Current.GetValue<int>("Metrics:Port");
            var server = new MetricServer(metricsPort);
            server.Start();
            Console.WriteLine($"Metrics server listening on port ${metricsPort}");
        }
    }
}