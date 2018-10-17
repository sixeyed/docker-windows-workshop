using System.Threading.Tasks;
using NServiceBus;
using SignUp.Entities;
using SignUp.Messaging.Messages.Commands;

namespace SignUp.Web.ProspectSave
{
    public class NServiceBusProspectSave : IProspectSave
    {
        private readonly IEndpointInstance _endpointInstance;

        public NServiceBusProspectSave(IEndpointInstance endpointInstance)
        {
            _endpointInstance = endpointInstance;
        }

        public void SaveProspect(Prospect prospect)
        {
            var command = new CreateNewProspect
            {
                Prospect = prospect
            };

            Task.Run(() => _endpointInstance.Send(command));
        }
    }
}