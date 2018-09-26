using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using Dapper;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace SignUp.Api.ReferenceData.Repositories
{
    public abstract class RepositoryBase<T> : IRepository<T>
    {
        protected readonly IConfiguration _configuration;
        protected readonly ILogger _logger;

        protected abstract string GetAllSqlQuery { get; }

        public RepositoryBase(IConfiguration configuration, ILogger logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        public IDbConnection Connection
        {
            get
            {
                var connectionString = _configuration.GetConnectionString("SignUpDb");
                return new SqlConnection(connectionString);
            }
        }

        public IEnumerable<T> GetAll()
        {
            _logger.LogDebug("GetAll - executing SQL query: '{0}'", GetAllSqlQuery);
            using (IDbConnection dbConnection = Connection)
            {
                dbConnection.Open();
                return dbConnection.Query<T>(GetAllSqlQuery);
            }
        }
    }
}
