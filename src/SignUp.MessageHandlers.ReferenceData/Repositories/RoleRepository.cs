using Microsoft.Extensions.Configuration;
using SignUp.Entities;

namespace SignUp.MessageHandlers.ReferenceData.Repositories
{
    public class RoleRepository : RepositoryBase<Role>
    {
        public RoleRepository(IConfiguration configuration) : base(configuration)
        {
        }

        protected override string GetAllSqlQuery => "SELECT* FROM Roles";
    }
}
