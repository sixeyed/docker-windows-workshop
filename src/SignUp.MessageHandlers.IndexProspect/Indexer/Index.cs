using System;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Nest;
using SignUp.MessageHandlers.IndexProspect.Documents;

namespace SignUp.MessageHandlers.IndexProspect.Indexer
{
    public class Index
    {
        private readonly IConfiguration _config;
        private static bool _IndexCreated;

        public Index(IConfiguration config)
        {
            _config = config;
        }

        private async Task EnsureIndexAsync()
        {
            if (!_IndexCreated)
            {
                Console.WriteLine($"Initializing Elasticsearch. url: {_config["Elasticsearch:Url"]}");
                await GetClient().CreateIndexAsync("prospects");
                _IndexCreated = true;
            }
        }

        public async Task CreateDocumentAsync(Prospect prospect)
        {
            await EnsureIndexAsync();
            await GetClient().IndexAsync(prospect, idx => idx.Index("prospects"));
        }

        private ElasticClient GetClient()
        {
            var uri = new Uri(_config["Elasticsearch:Url"]);
            return new ElasticClient(uri);
        }
    }
}
