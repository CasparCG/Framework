using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Sockets;
using System.Net;

namespace Svt.Network
{
    public class RemoteHostState
    {
        internal RemoteHostState(TcpClient client)
        {
            Client = client;
            Stream = client.GetStream();
            ReadBuffer = new byte[1024];
            EndPoint = (IPEndPoint)client.Client.RemoteEndPoint;
        }

        internal void Send(byte[] data)
        {
            //TODO: Make async, keep track of send-queue
            if (data != null && data.Length > 0)
                Stream.Write(data, 0, data.Length);
        }

        internal bool Close()
        {
            if (Stream != null)
            {
                Stream.Close();
                Stream = null;
            }

            bool result = (Client != null);
            if (Client != null)
            {
                Client.Close();
                Client = null;
            }
            return result;
        }

        public NetworkStream Stream { get; private set; }
        public TcpClient Client { get; private set; }
        public byte[] ReadBuffer { get; private set; }
        public IPEndPoint EndPoint { get; private set; }
    }
}
