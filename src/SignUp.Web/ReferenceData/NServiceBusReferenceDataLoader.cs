using NServiceBus;
using RestSharp;
using SignUp.Core;
using SignUp.Entities;
using SignUp.Messaging.Messages.RequestResponse;
using System.Collections.Generic;
using System.Configuration;

namespace SignUp.Web.ReferenceData
{
    public class NServiceBusReferenceDataLoader : IReferenceDataLoader
    {
        private readonly IEndpointInstance _endpointInstance;

        public NServiceBusReferenceDataLoader(IEndpointInstance endpointInstance)
        {
            _endpointInstance = endpointInstance;
        }

        public IEnumerable<Country> GetCountries()
        {
            var message = new GetCountriesRequest();
            var responseTask = _endpointInstance.Request<GetCountriesResponse>(message, GetSendOptions());
            var response = responseTask.GetAwaiter().GetResult();
            return response.Countries;
        }

        public IEnumerable<Role> GetRoles()
        {
            var message = new GetRolesRequest();
            var responseTask = _endpointInstance.Request<GetRolesResponse>(message, GetSendOptions());
            var response = responseTask.GetAwaiter().GetResult();
            return response.Roles;
        }

        private static SendOptions GetSendOptions()
        {
            var sendOptions = new SendOptions();
            sendOptions.SetDestination("ReferenceData");
            return sendOptions;
        }

    }
}