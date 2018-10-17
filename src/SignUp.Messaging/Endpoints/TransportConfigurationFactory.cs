using System;
using System.Collections.Generic;
using System.Text;
using NServiceBus;

namespace SignUp.Messaging.Endpoints
{
    public static class TransportConfigurationFactory
    {
        public static TransportExtensions SetTransport(EndpointConfiguration endpointConfiguration, string transport)
        {
            //TODO - use DI
            switch (transport)
            {
                case nameof(LearningTransport):
                    return LearningTransportConfiguration.SetTransport(endpointConfiguration);

                default:
                    throw new ApplicationException("Missing config setting - NServiceBus:Transport");
                    
            }
        }
    }
}
