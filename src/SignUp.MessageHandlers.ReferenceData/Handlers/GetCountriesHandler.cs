using System;
using System.Threading.Tasks;
using NServiceBus;
using Prometheus;
using SignUp.Entities;
using SignUp.MessageHandlers.ReferenceData.Repositories;
using SignUp.Messaging.Messages.RequestResponse;

namespace SignUp.MessageHandlers.ReferenceData.Handlers
{
    public class GetCountriesHandler : IHandleMessages<GetCountriesRequest>
    {
        private static Counter _EventCounter = Metrics.CreateCounter("GetCountriesHandler_Events", "Event count", "host", "status");
        private static string _Host = Environment.MachineName;

        private readonly IRepository<Country> _repository;

        public GetCountriesHandler(IRepository<Country> repository)
        {
            _repository = repository;
        }

        public async Task Handle(GetCountriesRequest message, IMessageHandlerContext context)
        {
            Console.WriteLine($"Received GetCountriesRequest message, MessageId: {context.MessageId}");
            _EventCounter.Labels(_Host, "received").Inc();

            try
            {
                var countries = await _repository.GetAllAsync();
                var response = new GetCountriesResponse
                {
                    Countries = countries
                };
                await context.Reply(response);

                Console.WriteLine($"Sent GetCountriesResponse reply; MessageId: {context.MessageId}");
                _EventCounter.Labels(_Host, "processed").Inc();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"GetCountriesRequest FAILED, MessageId: {context.MessageId}, ex: {ex}");
                _EventCounter.Labels(_Host, "failed").Inc();
            }            
        }
    }
}
