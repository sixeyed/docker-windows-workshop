using System;
using NServiceBus;

namespace SignUp.Messaging.Endpoints
{
    public static class TransportConfigurationFactory
    {
        public static TransportExtensions Configure(EndpointConfiguration endpointConfiguration, string transport, string endpointName, bool usePubSub = false)
        {
            //TODO - use DI & config
            switch (transport)
            {
                case nameof(RabbitMQTransport):
                    return RabbitMQTransportConfiguration.Configure(endpointConfiguration, endpointName, usePubSub);

                case nameof(LearningTransport):
                    return LearningTransportConfiguration.Configure(endpointConfiguration);

                default:
                    throw new ApplicationException("Missing config setting - NServiceBus:Transport");
                    
            }
        }
    }
}
