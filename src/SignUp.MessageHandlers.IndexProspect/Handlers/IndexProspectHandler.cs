using System;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using NServiceBus;
using Prometheus;
using SignUp.MessageHandlers.IndexProspect.Indexer;
using SignUp.Messaging.Messages.Events;

namespace SignUp.MessageHandlers.IndexProspect.Handlers
{
    public class IndexProspectHandler : IHandleMessages<ProspectCreated>
    {
        private static Counter _EventCounter = Metrics.CreateCounter("IndexHandler_Events", "Event count", "host", "status");
        private static string _Host = Environment.MachineName;

        private readonly IConfiguration _config;
        private readonly Index _index;

        public IndexProspectHandler(IConfiguration config, Index index)
        {
            _config = config;
            _index = index;
        }
        
        public async Task Handle(ProspectCreated message, IMessageHandlerContext context)
        {
            Console.WriteLine($"Received ProspectCreated message, MessageId: {context.MessageId}");
            _EventCounter.Labels(_Host, "received").Inc();
                        
            Console.WriteLine($"Indexing prospect, signed up at: {message.SignedUpAt}; MessageId: {context.MessageId}");

            var prospect = new Documents.Prospect
            {
                CompanyName = message.Prospect.CompanyName,
                CountryName = message.Prospect.Country.CountryName,
                EmailAddress = message.Prospect.EmailAddress,
                FullName = $"{message.Prospect.FirstName} {message.Prospect.LastName}",
                RoleName = message.Prospect.Role.RoleName,
                SignUpDate = message.SignedUpAt
            };

            try
            {
                await _index.CreateDocumentAsync(prospect);
                Console.WriteLine($"Prospect indexed; MessageId: {context.MessageId}");
                _EventCounter.Labels(_Host, "processed").Inc();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Index prospect FAILED, email address: {prospect.EmailAddress}, ex: {ex}");
                _EventCounter.Labels(_Host, "failed").Inc();
            }
        }
    }
}
