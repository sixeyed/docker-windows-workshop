using System;
using System.Data.Entity;
using System.Linq;
using System.Web;
using System.Web.Optimization;
using System.Web.Routing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SignUp.Core;
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
            ServiceProvider = new ServiceCollection()
                .AddTransient<DatabaseReferenceDataLoader>()
                .AddTransient<ApiReferenceDataLoader>()
                .AddTransient<SynchronousProspectSaveHandler>()
                .AddTransient<AsynchronousProspectSaveHandler>()
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
    }
}