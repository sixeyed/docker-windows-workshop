using NServiceBus;

namespace SignUp.Messaging.Endpoints
{
    public class LearningTransportConfiguration
    {
        //TODO - move to config
        private static readonly string _StorageDirectory = "/nsb";

        public static TransportExtensions Configure(EndpointConfiguration endpointConfiguration)
        {            
            var transport = endpointConfiguration.UseTransport<LearningTransport>();
            transport.StorageDirectory(_StorageDirectory);
            return transport;
        }
    }
}
