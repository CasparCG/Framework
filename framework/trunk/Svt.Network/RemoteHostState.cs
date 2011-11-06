using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Sockets;
using System.Net;
using System.Threading;

namespace Svt.Network
{
    public class RemoteHostState
    {
        internal ReaderWriterLockSlim streamLock = new ReaderWriterLockSlim(LockRecursionPolicy.SupportsRecursion);

        internal RemoteHostState(TcpClient client)
        {
            SendQueue = new Queue<byte[]>();

            Client = client;
            Stream = client.GetStream();
            ReadBuffer = new byte[1024];
            EndPoint = (IPEndPoint)client.Client.RemoteEndPoint;
        }

        internal void Send(byte[] data)
        {
            if (!_closed)
            {
                bool doNotify = false;
                lock (SendQueue)
                {
                    SendQueue.Enqueue(data);
                    if (SendQueue.Count == 1)
                        doNotify = true;
                }

                if (doNotify)
                    OnGotDataToSend();
            }
        }

        internal bool Close()
        {
            bool result = true;

            {
                streamLock.EnterReadLock();
                try
                {
                    if (Stream != null)
                        Stream.Close();

                    result = (Client != null);
                    if (Client != null)
                        Client.Close();
                }
                finally
                {
                    streamLock.ExitReadLock();
                }
            }
            _closed = true;
            {
                //This is the only write-lock on streamLock
                streamLock.EnterWriteLock();
                try
                {
                    Stream = null;
                    Client = null;
                }
                finally
                {
                    streamLock.ExitWriteLock();
                }
            }

            lock (SendQueue)
                SendQueue.Clear();

            return result;
        }

        volatile bool _closed = false;

        //Protected by a ReaderWriterLock manually. Every access to the stream from ServerConnection/ServerListener need to be protected by a read-lock
        internal NetworkStream Stream { get; private set; }
        TcpClient Client { get; set; }

        //does not need protection. usage is synchronous
        internal byte[] ReadBuffer { get; private set; }

        //Is accessed by multiple threads, needs to be protected by a critical section
        internal Queue<byte[]> SendQueue { get; private set; }

        //this read of Client should be protected as well.
        public bool Connected 
        { 
            get 
            {
                streamLock.EnterReadLock();
                try
                {
                    return (Client != null) ? Client.Connected : false;
                }
                finally { streamLock.ExitReadLock(); }
            } 
        }

        public IPEndPoint EndPoint { get; private set; }
        public object ProtocolState { get; set; }

        internal event EventHandler<EventArgs> GotDataToSend;
        protected void OnGotDataToSend()
        {
            try
            {
                if (!_closed && GotDataToSend != null)
                    GotDataToSend(this, EventArgs.Empty);
            }
            catch { }
        }

        public override string ToString()
        {
            return EndPoint.Address.ToString();
        }
    }
}
