using Microsoft.Extensions.Configuration;
using SignUp.Entities;

namespace SignUp.Api.ReferenceData.Repositories
{
    public class CountryRepository : RepositoryBase<Country>
    {
        public CountryRepository(IConfiguration configuration) : base(configuration)
        {
        }

        protected override string GetAllSqlQuery => "SELECT* FROM Countries";
    }
}
