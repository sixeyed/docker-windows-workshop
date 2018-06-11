using Dapper;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

namespace SignUp.Api.ReferenceData.Repositories
{
    public abstract class RepositoryBase<T> : IRepository<T>
    {
        protected abstract string GetAllSqlQuery { get; }

        public RepositoryBase(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }


        public IDbConnection Connection
        {
            get
            {
                var connectionString = Configuration.GetConnectionString("SignUpDb");
                return new SqlConnection(connectionString);
            }
        }

        public IEnumerable<T> GetAll()
        {
            using (IDbConnection dbConnection = Connection)
            {
                dbConnection.Open();
                return dbConnection.Query<T>(GetAllSqlQuery);
            }
        }
    }
}
