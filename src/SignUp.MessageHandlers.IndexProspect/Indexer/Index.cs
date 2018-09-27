using Microsoft.Extensions.Configuration;
using Nest;
using SignUp.MessageHandlers.IndexProspect.Documents;
using System;

namespace SignUp.MessageHandlers.IndexProspect.Indexer
{
    public class Index
    {
        private readonly IConfiguration _config;

        public Index(IConfiguration config)
        {
            _config = config;
            EnsureIndex();
        }

        private void EnsureIndex()
        {            
            Console.WriteLine($"Initializing Elasticsearch. url: {_config["Elasticsearch:Url"]}");
            GetClient().CreateIndex("prospects");
        }

        public void CreateDocument(Prospect prospect)
        {
            GetClient().Index(prospect, idx => idx.Index("prospects"));
        }

        private ElasticClient GetClient()
        {
            var uri = new Uri(_config["Elasticsearch:Url"]);
            return new ElasticClient(uri);
        }
    }
}
