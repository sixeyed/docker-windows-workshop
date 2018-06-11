using Microsoft.AspNetCore.Mvc;
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

        public CountriesController(IRepository<Country> repository)
        {
            _repository = repository;
        }

        [HttpGet]
        public IEnumerable<Country> Get()
        {
            return _repository.GetAll();
        }
    }
}