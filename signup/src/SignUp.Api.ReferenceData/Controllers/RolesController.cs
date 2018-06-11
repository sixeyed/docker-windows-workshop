using Microsoft.AspNetCore.Mvc;
using SignUp.Api.ReferenceData.Repositories;
using SignUp.Entities;
using System.Collections.Generic;

namespace SignUp.Api.ReferenceData.Controllers
{
    [Produces("application/json")]
    [Route("api/Roles")]
    public class RolesController : Controller
    {
        private readonly IRepository<Role> _repository;

        public RolesController(IRepository<Role> repository)
        {
            _repository = repository;
        }

        [HttpGet]
        public IEnumerable<Role> Get()
        {
            return _repository.GetAll();
        }
    }
}