using NServiceBus;
using SignUp.Entities;
using System;

namespace SignUp.Messaging.Messages.Commands
{
    public class CreateNewProspect : ICommand
    {
        public Prospect Prospect { get; set; }
    }
}
