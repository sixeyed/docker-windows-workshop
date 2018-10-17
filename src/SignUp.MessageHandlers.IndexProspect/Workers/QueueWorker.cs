using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using NServiceBus;
using Prometheus;
using SignUp.Core;
using SignUp.MessageHandlers.IndexProspect.Indexer;
using SignUp.Messaging.Endpoints;

namespace SignUp.MessageHandlers.IndexProspect.Workers
{
    public class QueueWorker
    {
        private static ManualResetEvent _ResetEvent = new ManualResetEvent(false);

        private readonly IConfiguration _config;
        private readonly Index _index;

        public QueueWorker(IConfiguration config, Index index)
        {
            _config = config;
            _index = index;
        }

        public async Task Start()
        {
            if (_config.GetValue<bool>("Metrics:Enabled"))
            {
                StartMetricServer();
            }

            var transportType = Config.Current["NServiceBus:Transport"];
            Console.WriteLine($"Connecting to NServiceBus, transport: {transportType}");

            var endpointConfiguration = new EndpointConfiguration("ProspectIndex");
            var transport = TransportConfigurationFactory.SetTransport(endpointConfiguration, transportType);
            var endpointInstance = await Endpoint.Start(endpointConfiguration).ConfigureAwait(false);

            Console.WriteLine($"Listening.");

            _ResetEvent.WaitOne();
            await endpointInstance.Stop().ConfigureAwait(false);
        }

        
        private void StartMetricServer()
        {
            var metricsPort = Config.Current.GetValue<int>("Metrics:Port");
            var server = new MetricServer(metricsPort);
            server.Start();
            Console.WriteLine($"Metrics server listening on port ${metricsPort}");
        }
    }
}
