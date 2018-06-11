using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SignUp.MessageHandler.IndexProspect.Indexer;
using SignUp.MessageHandler.IndexProspect.Workers;

namespace SignUp.MessageHandler.IndexProspect
{
    class Program
    {
        static void Main(string[] args)
        {
            IConfiguration config = new ConfigurationBuilder()
                .AddJsonFile("appsettings.json")
                .Build();

            var serviceProvider = new ServiceCollection()
                .AddSingleton(config)
                .AddSingleton<Index>()
                .AddSingleton<QueueWorker>()
                .BuildServiceProvider();

            var worker = serviceProvider.GetService<QueueWorker>();
            worker.Start();
        }
    }
}
