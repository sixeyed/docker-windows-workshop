using System.Collections.Generic;

namespace SignUp.Api.ReferenceData.Repositories
{
    public interface IRepository<T>
    {
        IEnumerable<T> GetAll();
    }
}
