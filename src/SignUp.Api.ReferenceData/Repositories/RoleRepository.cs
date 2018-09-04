using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using SignUp.Entities;

namespace SignUp.Api.ReferenceData.Repositories
{
    public class RoleRepository : RepositoryBase<Role>
    {
        public RoleRepository(IConfiguration configuration, ILogger<CountryRepository> logger) : base(configuration, logger)
        {
        }

        protected override string GetAllSqlQuery => "SELECT* FROM Roles";
    }
}
