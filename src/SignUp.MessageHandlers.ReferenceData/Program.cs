using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using NServiceBus;
using Prometheus;
using SignUp.Core;
using SignUp.Entities;
using SignUp.MessageHandlers.ReferenceData.Repositories;
using SignUp.Messaging.Endpoints;

namespace SignUp.MessageHandlers.ReferenceData
{
    class Program
    {
        private static IEndpointInstance _EndpointInstance;
        private static ManualResetEvent _ResetEvent = new ManualResetEvent(false);
        private static readonly string _EndpointName = "ReferenceData";

        static async Task Main(string[] args)
        {
            if (Config.Current.GetValue<bool>("Metrics:Enabled"))
            {
                StartMetricServer();
            }

            var services = new ServiceCollection()
                .AddSingleton(Config.Current)
                .AddSingleton(sp => _EndpointInstance)
                .AddTransient<IRepository<Country>, CountryRepository>()
                .AddTransient<IRepository<Role>, RoleRepository>();

            var transportType = Config.Current["NServiceBus:Transport"];
            var endpointConfiguration = new EndpointConfiguration(_EndpointName);
            endpointConfiguration.UseContainer<ServicesBuilder>(
            customizations: customizations =>
            {
                customizations.ExistingServices(services);
            });

            var transport = TransportConfigurationFactory.Configure(endpointConfiguration, transportType, _EndpointName);
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