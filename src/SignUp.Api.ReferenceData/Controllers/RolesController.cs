using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
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
        private readonly ILogger _logger;

        public RolesController(IRepository<Role> repository, ILogger<RolesController> logger)
        {
            _repository = repository;
            _logger = logger;
        }

        [HttpGet]
        public IEnumerable<Role> Get()
        {
            _logger.LogInformation("Received request: get");
            return _repository.GetAll();
        }
    }
}