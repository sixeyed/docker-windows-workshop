using NServiceBus;
using SignUp.Entities;
using System;

namespace SignUp.Messaging.Messages.Events
{
    public class ProspectCreated : IEvent
    {
        public DateTime SignedUpAt { get; set; }

        public Prospect Prospect { get; set; }
    }
}
