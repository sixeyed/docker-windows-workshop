using SignUp.Entities;
using System.Collections.Generic;

namespace SignUp.Web.ReferenceData
{
    interface IReferenceDataLoader
    {
        IEnumerable<Country> GetCountries();

        IEnumerable<Role> GetRoles();
    }
}
