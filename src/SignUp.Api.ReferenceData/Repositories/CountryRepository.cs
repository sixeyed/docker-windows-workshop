using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using SignUp.Entities;

namespace SignUp.Api.ReferenceData.Repositories
{
    public class CountryRepository : RepositoryBase<Country>
    {
        public CountryRepository(IConfiguration configuration, ILogger<CountryRepository> logger) : base(configuration, logger)
        {
        }

        protected override string GetAllSqlQuery => "SELECT* FROM Countries";
    }
}
