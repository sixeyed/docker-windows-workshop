using System.Collections.Generic;
using NServiceBus;
using SignUp.Entities;

namespace SignUp.Messaging.Messages.RequestResponse
{
    public class GetCountriesResponse : IMessage
    {
        public IEnumerable<Country> Countries { get; set; }
    }
}
