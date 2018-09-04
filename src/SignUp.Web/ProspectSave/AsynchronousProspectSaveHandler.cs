using SignUp.Entities;
using SignUp.Messaging;
using SignUp.Messaging.Messages.Events;
using System;

namespace SignUp.Web.ProspectSave
{
    public class AsynchronousProspectSaveHandler : IProspectSaveHandler
    {
        public void SaveProspect(Prospect prospect)
        {
            var eventMessage = new ProspectSignedUpEvent
            {
                Prospect = prospect,
                SignedUpAt = DateTime.UtcNow
            };

            MessageQueue.Publish(eventMessage);
        }
    }
}