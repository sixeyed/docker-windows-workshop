using System.Collections.Generic;
using System.Threading.Tasks;

namespace SignUp.MessageHandlers.ReferenceData.Repositories
{
    public interface IRepository<T>
    {
        Task<IEnumerable<T>> GetAllAsync();
    }
}
