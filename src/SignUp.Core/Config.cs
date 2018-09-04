using Microsoft.Extensions.Configuration;

namespace SignUp.Core
{
    public class Config
    {
        public static IConfiguration Current { get; private set; }

        static Config()
        {
            Current = new ConfigurationBuilder()
                .AddJsonFile("appsettings.json")
                .AddEnvironmentVariables()
                .Build();
        }
    }
}
