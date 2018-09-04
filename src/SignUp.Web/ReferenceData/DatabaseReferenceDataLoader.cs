using SignUp.Entities;
using SignUp.Model;
using System.Collections.Generic;
using System.Linq;

namespace SignUp.Web.ReferenceData
{
    public class DatabaseReferenceDataLoader : IReferenceDataLoader
    {
        public IEnumerable<Country> GetCountries()
        {
            using (var context = new SignUpContext())
            {
                return context.Countries.ToList();
            }
        }

        public IDictionary<string, Country> GetCountriesx()
        {
            var countries = new Dictionary<string, Country>();
            using (var context = new SignUpContext())
            {
                countries["-"] = context.Countries.Single(x => x.CountryCode == "-");
                foreach (var country in context.Countries.Where(x => x.CountryCode != "-").OrderBy(x => x.CountryName))
                {
                    countries[country.CountryCode] = country;
                }
            }
            return countries;
        }

        public IEnumerable<Role> GetRoles()
        {
            using (var context = new SignUpContext())
            {
                return context.Roles.ToList();
            }
        }

        public IDictionary<string, Role> GetRolesx()
        {
            var roles = new Dictionary<string, Role>();
            using (var context = new SignUpContext())
            {
                roles["-"] = context.Roles.Single(x => x.RoleCode == "-");
                foreach (var role in context.Roles.Where(x => x.RoleCode != "-").OrderBy(x => x.RoleName))
                {
                    roles[role.RoleCode] = role;
                }
            }
            return roles;            
        }
    }
}