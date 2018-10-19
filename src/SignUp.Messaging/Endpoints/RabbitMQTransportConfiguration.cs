using System;
using NServiceBus;
using RabbitMQ.Client;

namespace SignUp.Messaging.Endpoints
{
    public class RabbitMQTransportConfiguration
    {
        //TODO - move to config
        private static readonly string _ConnectionString = "host=rabbitmq;username=guest;password=guest";
        private static readonly string _Uri = "amqp://guest:guest@rabbitmq:5672";
        private static readonly bool _UseDurableMessages = true;

        public static TransportExtensions Configure(EndpointConfiguration endpointConfiguration, string endpointName, bool usePubSub = false)
        {
            var transport = endpointConfiguration.UseTransport<RabbitMQTransport>();
            transport.UseConventionalRoutingTopology();
            transport.ConnectionString(_ConnectionString);

            CreateQueuesForEndpoint(endpointName, true);

            return transport;
        }

        private static void CreateQueuesForEndpoint(string endpointName, bool createExchanges)
        {
            // main queue
            CreateQueue(_Uri, endpointName, _UseDurableMessages, createExchanges);

            // callback queue
            CreateQueue(_Uri, $"{endpointName}-{Environment.MachineName}", _UseDurableMessages, createExchanges);

            // timeout queue
            CreateQueue(_Uri, $"{endpointName}.Timeouts", _UseDurableMessages, createExchanges);

            // timeout dispatcher queue
            CreateQueue(_Uri, $"{endpointName}.TimeoutsDispatcher", _UseDurableMessages, createExchanges);
        }


        private static void CreateQueue(string uri, string queueName, bool durableMessages, bool createExchange)
        {
            var connectionFactory = new ConnectionFactory
            {
                Uri = new Uri(uri)
            };

            using (var connection = connectionFactory.CreateConnection())
            using (var channel = connection.CreateModel())
            {
                channel.QueueDeclare(
                    queue: queueName,
                    durable: durableMessages,
                    exclusive: false,
                    autoDelete: false,
                    arguments: null);

                if (createExchange)
                {
                    CreateExchange(channel, queueName, durableMessages);
                }
            }
        }

        private static void CreateExchange(IModel channel, string queueName, bool durableMessages)
        {
            channel.ExchangeDeclare(queueName, ExchangeType.Fanout, durableMessages);
            channel.QueueBind(queueName, queueName, string.Empty);
        }
    }
}
