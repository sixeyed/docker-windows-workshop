using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using NServiceBus;
using Prometheus;
using SignUp.Core;
using SignUp.MessageHandlers.IndexProspect.Indexer;
using SignUp.Messaging.Endpoints;

namespace SignUp.MessageHandlers.IndexProspect
{
    class Program
    {
        private static IEndpointInstance _EndpointInstance;
        private static ManualResetEvent _ResetEvent = new ManualResetEvent(false);

        static async Task Main(string[] args)
        {
            if (Config.Current.GetValue<bool>("Metrics:Enabled"))
            {
                StartMetricServer();
            }

            var services = new ServiceCollection()
                .AddSingleton(Config.Current)
                .AddSingleton(sp => _EndpointInstance)
                .AddSingleton<Index>();

            var transportType = Config.Current["NServiceBus:Transport"];
            var endpointConfiguration = new EndpointConfiguration("ProspectIndex");
            endpointConfiguration.UseContainer<ServicesBuilder>(
            customizations: customizations =>
            {
                customizations.ExistingServices(services);
            });

            var transport = TransportConfigurationFactory.SetTransport(endpointConfiguration, transportType);
            Console.WriteLine($"Connecting to NServiceBus, transport: {transportType}");
            _EndpointInstance = await Endpoint.Start(endpointConfiguration).ConfigureAwait(false);
            Console.WriteLine($"Listening.");

            _ResetEvent.WaitOne();
            await _EndpointInstance.Stop().ConfigureAwait(false);
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
