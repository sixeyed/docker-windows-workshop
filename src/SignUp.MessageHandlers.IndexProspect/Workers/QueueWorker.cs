using System;
using System.Threading;
using Microsoft.Extensions.Configuration;
using NATS.Client;
using Prometheus;
using SignUp.Core;
using SignUp.MessageHandlers.IndexProspect.Indexer;
using SignUp.Messaging;
using SignUp.Messaging.Messages.Events;

namespace SignUp.MessageHandlers.IndexProspect.Workers
{
    public class QueueWorker
    {
        private static ManualResetEvent _ResetEvent = new ManualResetEvent(false);

        private const string QUEUE_GROUP = "index-handler";

        private static Counter _EventCounter = Metrics.CreateCounter("IndexHandler_Events", "Event count", "host", "status");
        private static string _Host = Environment.MachineName;

        private readonly IConfiguration _config;
        private readonly Index _index;

        public QueueWorker(IConfiguration config, Index index)
        {
            _config = config;
            _index = index;
        }

        public void Start()
        {
            if (_config.GetValue<bool>("Metrics:Enabled"))
            {
                StartMetricServer();
            }            

            Console.WriteLine($"Connecting to message queue url: {Config.Current["MessageQueue:Url"]}");
            using (var connection = MessageQueue.CreateConnection())
            {
                var subscription = connection.SubscribeAsync(ProspectSignedUpEvent.MessageSubject, QUEUE_GROUP);
                subscription.MessageHandler += IndexProspect;
                subscription.Start();
                Console.WriteLine($"Listening on subject: {ProspectSignedUpEvent.MessageSubject}, queue: {QUEUE_GROUP}");

                _ResetEvent.WaitOne();
                connection.Close();
            }
        }

        private void IndexProspect(object sender, MsgHandlerEventArgs e)
        {
            _EventCounter.Labels(_Host, "received").Inc();

            Console.WriteLine($"Received message, subject: {e.Message.Subject}");
            var eventMessage = MessageHelper.FromData<ProspectSignedUpEvent>(e.Message.Data);
            Console.WriteLine($"Indexing prospect, signed up at: {eventMessage.SignedUpAt}; event ID: {eventMessage.CorrelationId}");

            var prospect = new Documents.Prospect
            {
                CompanyName = eventMessage.Prospect.CompanyName,
                CountryName = eventMessage.Prospect.Country.CountryName,
                EmailAddress = eventMessage.Prospect.EmailAddress,
                FullName = $"{eventMessage.Prospect.FirstName} {eventMessage.Prospect.LastName}",
                RoleName = eventMessage.Prospect.Role.RoleName,
                SignUpDate = eventMessage.SignedUpAt
            };

            try
            {
                _index.CreateDocument(prospect);
                Console.WriteLine($"Prospect indexed; event ID: {eventMessage.CorrelationId}");
                _EventCounter.Labels(_Host, "processed").Inc();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Index prospect FAILED, email address: {prospect.EmailAddress}, ex: {ex}");
                _EventCounter.Labels(_Host, "failed").Inc();
            }
        }
        
        private void StartMetricServer()
        {
            var metricsPort = Config.Current.GetValue<int>("Metrics:Port");
            var server = new MetricServer(metricsPort);
            server.Start();
            Console.WriteLine($"Metrics server listening on port ${metricsPort}");
        }
    }
}
