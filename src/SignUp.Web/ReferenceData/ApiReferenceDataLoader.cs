using RestSharp;
using SignUp.Core;
using SignUp.Entities;
using System.Collections.Generic;
using System.Configuration;

namespace SignUp.Web.ReferenceData
{
    public class ApiReferenceDataLoader : IReferenceDataLoader
    {
        public IEnumerable<Country> GetCountries()
        {
            var client = new RestClient(Config.Current["ReferenceDataApi:Url"]);
            var request = new RestRequest("countries");
            var response = client.Execute<List<Country>>(request);
            return response.Data;
        }        

        public IEnumerable<Role> GetRoles()
        {
            var client = new RestClient(Config.Current["ReferenceDataApi:Url"]);
            var request = new RestRequest("roles");
            var response = client.Execute<List<Role>>(request);
            return response.Data;
        }
    }
}