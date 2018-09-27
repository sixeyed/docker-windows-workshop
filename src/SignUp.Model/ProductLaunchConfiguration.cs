using System;
using System.Data.Entity;
using System.Data.Entity.SqlServer;
using Microsoft.Extensions.Configuration;
using SignUp.Core;

namespace SignUp.Model
{
    public class SignUpConfiguration : DbConfiguration
    {
        public SignUpConfiguration()
        {
            var maxRetryCount = Config.Current.GetValue<int>("Database:MaxRetryCount");
            var maxDelaySeconds = Config.Current.GetValue<int>("Database:MaxDelaySeconds");

            Console.WriteLine($"- Setting DbConfiguration - maxRetryCount: {maxRetryCount}, maxDelaySeconds: {maxDelaySeconds}");

            SetExecutionStrategy("System.Data.SqlClient", () =>
                new SqlAzureExecutionStrategy(maxRetryCount, TimeSpan.FromSeconds(maxDelaySeconds)));
        }
    }
}
