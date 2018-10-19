using System.Collections.Generic;
using NServiceBus;
using SignUp.Entities;

namespace SignUp.Messaging.Messages.RequestResponse
{
    public class GetRolesResponse : IMessage
    {
        public IEnumerable<Role> Roles { get; set; }
    }
}
