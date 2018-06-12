using Microsoft.Extensions.DependencyInjection;
using SignUp.Model;
using SignUp.Model.Initializers;
using SignUp.Web.ProspectSave;
using SignUp.Web.ReferenceData;
using System;
using System.Data.Entity;
using System.Web;
using System.Web.Optimization;
using System.Web.Routing;

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
            SignUp.PreloadStaticDataCache();
        }
    }
}