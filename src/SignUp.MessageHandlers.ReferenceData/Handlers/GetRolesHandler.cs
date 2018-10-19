using System;
using System.Threading.Tasks;
using NServiceBus;
using Prometheus;
using SignUp.Entities;
using SignUp.MessageHandlers.ReferenceData.Repositories;
using SignUp.Messaging.Messages.RequestResponse;

namespace SignUp.MessageHandlers.ReferenceData.Handlers
{
    public class GetRolesHandler : IHandleMessages<GetRolesRequest>
    {
        private static Counter _EventCounter = Metrics.CreateCounter("GetRolesHandler_Events", "Event count", "host", "status");
        private static string _Host = Environment.MachineName;

        private readonly IRepository<Role> _repository;

        public GetRolesHandler(IRepository<Role> repository)
        {
            _repository = repository;
        }

        public async Task Handle(GetRolesRequest message, IMessageHandlerContext context)
        {
            Console.WriteLine($"Received GetRolesRequest message, MessageId: {context.MessageId}");
            _EventCounter.Labels(_Host, "received").Inc();

            try
            {
                var roles = await _repository.GetAllAsync();
                var response = new GetRolesResponse
                {
                    Roles = roles
                };
                await context.Reply(response);

                Console.WriteLine($"Sent GetRolesResponse reply; MessageId: {context.MessageId}");
                _EventCounter.Labels(_Host, "processed").Inc();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"GetRolesRequest FAILED, MessageId: {context.MessageId}, ex: {ex}");
                _EventCounter.Labels(_Host, "failed").Inc();
            }
        }
    }
}
