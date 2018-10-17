using System;
using System.Linq;
using System.Threading.Tasks;
using NServiceBus;
using Prometheus;
using SignUp.Entities;
using SignUp.Messaging.Messages.Commands;
using SignUp.Messaging.Messages.Events;
using SignUp.Model;

namespace SignUp.MessageHandlers.SaveProspect.Handlers
{
    public class CreateNewProspectHandler : IHandleMessages<CreateNewProspect>
    {
        private static Counter _EventCounter = Metrics.CreateCounter("SaveHandler_Events", "Event count", "host", "status");
        private static string _Host = Environment.MachineName;

        public async Task Handle(CreateNewProspect message, IMessageHandlerContext context)
        {
            Console.WriteLine($"Received CreateNewProspect message, MessageId: {context.MessageId}");
            _EventCounter.Labels(_Host, "received").Inc();            
            
            var prospect = message.Prospect;
            try
            {
                await SaveProspect(prospect);
                Console.WriteLine($"Prospect saved. Prospect ID: {prospect.ProspectId}; MessageId: {context.MessageId}");
                _EventCounter.Labels(_Host, "processed").Inc();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Save prospect FAILED, email address: {prospect.EmailAddress}, ex: {ex}");
                _EventCounter.Labels(_Host, "failed").Inc();
            }

            var prospectCreated = new ProspectCreated
            {
                Prospect = prospect,
                SignedUpAt = DateTime.UtcNow
            };
            await context.Publish(prospectCreated);
        }

        private async Task SaveProspect(Prospect prospect)
        {
            using (var context = new SignUpContext())
            {
                //reload child objects:
                prospect.Country = context.Countries.Single(x => x.CountryCode == prospect.Country.CountryCode);
                prospect.Role = context.Roles.Single(x => x.RoleCode == prospect.Role.RoleCode);

                context.Prospects.Add(prospect);
                await context.SaveChangesAsync();
            }
        }
    }
}
