using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using SignUp.Api.ReferenceData.Repositories;
using SignUp.Entities;
using System.Collections.Generic;

namespace SignUp.Api.ReferenceData.Controllers
{
    [Produces("application/json")]
    [Route("api/countries")]
    public class CountriesController : Controller
    {
        private readonly IRepository<Country> _repository;
        private readonly ILogger _logger;

        public CountriesController(IRepository<Country> repository, ILogger<CountriesController> logger)
        {
            _repository = repository;
            _logger = logger;
        }

        [HttpGet]
        public IEnumerable<Country> Get()
        {
            _logger.LogInformation("Received request: get");
            return _repository.GetAll();
        }
    }
}