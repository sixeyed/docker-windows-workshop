using System;
using System.Data.Entity;
using System.Linq;
using System.Web;
using System.Web.Optimization;
using System.Web.Routing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using NServiceBus;
using SignUp.Core;
using SignUp.Messaging.Endpoints;
using SignUp.Messaging.Messages.Commands;
using SignUp.Model;
using SignUp.Model.Initializers;
using SignUp.Web.Logging;
using SignUp.Web.ProspectSave;
using SignUp.Web.ReferenceData;

namespace SignUp.Web
{
    public class Global : HttpApplication
    {
        public static ServiceProvider ServiceProvider { get; private set; }

        static Global()
        {
            var endpointInstance = InitializeEndpoint();

            ServiceProvider = new ServiceCollection()
                .AddSingleton(endpointInstance)
                .AddTransient<DatabaseReferenceDataLoader>()
                .AddTransient<ApiReferenceDataLoader>()
                .AddTransient<SynchronousProspectSave>()
                .AddTransient<NServiceBusProspectSave>()
                .BuildServiceProvider();
        }

        void Application_Start(object sender, EventArgs e)
        {
            // Code that runs on application startup
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);

            Database.SetInitializer<SignUpContext>(new StaticDataInitializer());
            EnsureDatabaseCreated();
            SignUp.PreloadStaticDataCache();
        }

        private static void EnsureDatabaseCreated()
        {
            Log.Info("Ensuring database exists");
            try
            {
                var connectionString = Config.Current.GetConnectionString("SignUpDb").ToLower();
                var server = connectionString.Split(';').First(x => x.StartsWith("server=")).Split('=')[1];
                Log.Debug($"Connecting to database server: {server}");
                using (var context = new SignUpContext())
                {
                    context.Countries.ToListAsync().Wait();
                }
                Log.Info("Database connection is OK");
            }
            catch(Exception ex)
            {
                Log.Fatal($"Database connection failed, exception: {ex}");
            }            
        }

        private static IEndpointInstance InitializeEndpoint()
        {
            var endpointConfiguration = new EndpointConfiguration("SignUp.Web");
            var transport = TransportConfigurationFactory.SetTransport(endpointConfiguration, Config.Current["NServiceBus:Transport"]);

            var routing = transport.Routing();
            routing.RouteToEndpoint(typeof(CreateNewProspect), "ProspectSave");

            return Endpoint.Start(endpointConfiguration).GetAwaiter().GetResult();
        }
    }
}