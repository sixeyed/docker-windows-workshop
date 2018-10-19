using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using Dapper;
using Microsoft.Extensions.Configuration;

namespace SignUp.MessageHandlers.ReferenceData.Repositories
{
    public abstract class RepositoryBase<T> : IRepository<T>
    {
        protected readonly IConfiguration _configuration;

        protected abstract string GetAllSqlQuery { get; }

        public RepositoryBase(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public IDbConnection Connection
        {
            get
            {
                var connectionString = _configuration.GetConnectionString("SignUpDb");
                return new SqlConnection(connectionString);
            }
        }

        public async Task<IEnumerable<T>> GetAllAsync()
        {
            Console.WriteLine("GetAll - executing SQL query: '{0}'", GetAllSqlQuery);
            using (IDbConnection dbConnection = Connection)
            {
                dbConnection.Open();
                return await dbConnection.QueryAsync<T>(GetAllSqlQuery);
            }
        }
    }
}
