using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using SignUp.Core;
using SignUp.Entities;
using SignUp.Web.ProspectSave;
using SignUp.Web.ReferenceData;

namespace SignUp.Web
{
    public partial class SignUp : Page
    {
        private static Dictionary<string, Country> _Countries = new Dictionary<string, Country>();
        private static Dictionary<string, Role> _Roles = new Dictionary<string, Role>();
        private static Type _ProspectSaveType;

        static SignUp()
        {
            var prospectSaveType = Config.Current["Dependencies:IProspectSave"];
            _ProspectSaveType = Type.GetType(prospectSaveType);
        }

        public static void PreloadStaticDataCache()
        {
            var loaderType = Config.Current["Dependencies:IReferenceDataLoader"];
            var type = Type.GetType(loaderType);
            var loader = (IReferenceDataLoader)Global.ServiceProvider.GetService(type);

            var countries = loader.GetCountries();
            _Countries["-"] = countries.Single(x => x.CountryCode == "-");
            foreach (var country in countries.Where(x => x.CountryCode != "-").OrderBy(x => x.CountryName))
            {
                _Countries[country.CountryCode] = country;
            }
            
            var roles = loader.GetRoles();
            _Roles["-"] = roles.Single(x => x.RoleCode == "-");
            foreach (var role in roles.Where(x => x.RoleCode != "-").OrderBy(x => x.RoleName))
            {
                _Roles[role.RoleCode] = role;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                PopulateRoles();
                PopulateCountries();
            }
        }

        private void PopulateRoles()
        {
            ddlRole.Items.Clear();
            ddlRole.Items.AddRange(_Roles.Select(x => new ListItem(x.Value.RoleName, x.Key)).ToArray()); 
        }

        private void PopulateCountries()
        {
            ddlCountry.Items.Clear();
            ddlCountry.Items.AddRange(_Countries.Select(x => new ListItem(x.Value.CountryName, x.Key)).ToArray());
        }

        protected void btnGo_Click(object sender, EventArgs e)
        {
            var country = _Countries[ddlCountry.SelectedValue];
            var role = _Roles[ddlRole.SelectedValue];

            var prospect = new Prospect
            {
                CompanyName = txtCompanyName.Text,
                EmailAddress = txtEmail.Text,
                FirstName = txtFirstName.Text,
                LastName = txtLastName.Text,
                Country = country,
                Role = role
            };
                        
            var persister = (IProspectSave)Global.ServiceProvider.GetService(_ProspectSaveType);
            persister.SaveProspect(prospect);

            Server.Transfer("ThankYou.aspx");
        }
    }
}