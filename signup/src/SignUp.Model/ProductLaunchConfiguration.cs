using SignUp.Core;
using System;
using System.Configuration;
using System.Data.Entity;
using System.Data.Entity.SqlServer;

namespace SignUp.Model
{
    public class SignUpConfiguration : DbConfiguration
    {
        public SignUpConfiguration()
        {
            var maxRetryCount = int.Parse(Config.Current["Database:MaxRetryCount"]);
            var maxDelaySeconds = int.Parse(Config.Current["Database:MaxDelaySeconds"]);

            Console.WriteLine($"- Setting DbConfiguration - maxRetryCount: {maxRetryCount}, maxDelaySeconds: {maxDelaySeconds}");

            SetExecutionStrategy("System.Data.SqlClient", () =>
                new SqlAzureExecutionStrategy(maxRetryCount, TimeSpan.FromSeconds(maxDelaySeconds)));
        }
    }
}
