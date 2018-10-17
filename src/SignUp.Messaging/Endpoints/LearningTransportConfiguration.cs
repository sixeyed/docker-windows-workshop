using System;
using System.Collections.Generic;
using System.Text;
using NServiceBus;

namespace SignUp.Messaging.Endpoints
{
    class LearningTransportConfiguration
    {
        public static TransportExtensions SetTransport(EndpointConfiguration endpointConfiguration)
        {            
            var transport = endpointConfiguration.UseTransport<LearningTransport>();
            transport.StorageDirectory("/nsb");
            return transport;
        }
    }
}
