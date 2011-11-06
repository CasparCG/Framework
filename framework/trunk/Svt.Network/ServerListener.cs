using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Net.Sockets;
using System.Net;

namespace Svt.Network
{
    public class ServerListener
    {
        AsyncCallback readCallback = null;
        AsyncCallback writeCallback = null;
        AsyncCallback asyncAcceptCallback = null;


        TcpListener listener = null;
        List<RemoteHostState> clients = null;

        public event EventHandler<ClientConnectionEventArgs> ClientConnectionStateChanged;
        public event EventHandler<EventArgs> UnexpectedStop;
        public IProtocolStrategy ProtocolStrategy { get; set; }
        
        public ServerListener()
        {
            clients = new List<RemoteHostState>();
            asyncAcceptCallback = new AsyncCallback(AcceptCallback);
            readCallback = new AsyncCallback(ReadCallback);
            writeCallback = new AsyncCallback(WriteCallback);
        }

        public void Start(int port)
        {
            if (listener != null)
                Stop();

            IPAddress localAddr = IPAddress.Parse("127.0.0.1");
            listener = new TcpListener(localAddr, port);
            listener.Start();
            DoBeginAccept();
        }
        public void Stop()
        {
            try
            {
                listener.Stop();
            }
            catch { }

            CloseAll();
        }

        void DoBeginAccept()
        {
            try
            {
                listener.BeginAcceptTcpClient(asyncAcceptCallback, null);
            }
            catch (SocketException)
            {
                Stop();
                OnUnexpectedStop();
            }
            catch { }
        }

        void AcceptCallback(IAsyncResult ar)
        {
            RemoteHostState state = null;
            bool beginNewAccept = true;
            try
            {
                if (ar.IsCompleted)
                {
                    state = new RemoteHostState(listener.EndAcceptTcpClient(ar));
                    state.GotDataToSend += state_GotDataToSend;

                    //no need to protect, state is not availible to any other threads yet
                    state.Stream.BeginRead(state.ReadBuffer, 0, state.ReadBuffer.Length, readCallback, state);
                }
                else
                    beginNewAccept = false;
            }
            catch (SocketException se)
            {
                if (se.SocketErrorCode == SocketError.Interrupted)
                {
                    beginNewAccept = false;
                }
            }
            catch (ObjectDisposedException)
            {
                beginNewAccept = false;
            }
            catch (Exception ex)
            {
                CloseConnection(state, ex);
                state = null;
            }

            if (state != null)
            {
                lock(clients)
                    clients.Add(state);
				
				OnClientConnectionStateChanged(state.EndPoint, true, null, true);
			}

            if(beginNewAccept)
                DoBeginAccept();
        }

        void HandleIOException(System.IO.IOException ioe, RemoteHostState state)
        {
            if (ioe.InnerException.GetType() == typeof(System.Net.Sockets.SocketError))
            {
                System.Net.Sockets.SocketException se = (System.Net.Sockets.SocketException)ioe.InnerException;
                CloseConnection(state, (se.SocketErrorCode == SocketError.Interrupted) ? null : se);
            }
            else
                CloseConnection(state, ioe);
        }

        void ReadCallback(IAsyncResult ar)
        {
            RemoteHostState state = (RemoteHostState)ar.AsyncState;
            try
            {
                int len = 0;
                
                {   //READ-LOCKS THE STREAM-PROPERTY
                    state.streamLock.EnterReadLock();
                    try
                    {
                        len = state.Stream.EndRead(ar);
                    }
                    finally { state.streamLock.ExitReadLock(); }
                }

                if (len == 0)
                    CloseConnection(state, true);
                else
                {
                    try
                    {
                        if (ProtocolStrategy != null)
                        {
                            if (ProtocolStrategy.Encoding != null)
                                ProtocolStrategy.Parse(ProtocolStrategy.Encoding.GetString(state.ReadBuffer, 0, len), state);
                            else
                                ProtocolStrategy.Parse(state.ReadBuffer, len, state);
                        }
                    }
                    catch { }

                    {   //READ-LOCKS THE STREAM-PROPERTY
                        state.streamLock.EnterReadLock();
                        try
                        {
                            state.Stream.BeginRead(state.ReadBuffer, 0, state.ReadBuffer.Length, readCallback, state);
                        }
                        finally { state.streamLock.ExitReadLock(); }
                    }
                }
            }
            catch (System.IO.IOException ioe)
            {
                HandleIOException(ioe, state);
            }
            //We dont need to take care of ObjectDisposedException. 
            //ObjectDisposedException would indicate that the state has been closed, and that means it has been disconnected already
            catch { }
        }

        #region Send
        void state_GotDataToSend(object sender, EventArgs e)
        {
            RemoteHostState state = (RemoteHostState)sender;
            DoSend(state);
        }

        void DoSend(RemoteHostState state)
        {
            try
            {
                lock (state.SendQueue)
                {
                    if (state.SendQueue.Count > 0)
                    {
                        byte[] data = state.SendQueue.Peek();

                        {   //READ-LOCKS THE STREAM-PROPERTY
                            state.streamLock.EnterReadLock();
                            try
                            {
                                state.Stream.BeginWrite(data, 0, data.Length, writeCallback, state);
                            }
                            finally { state.streamLock.ExitReadLock(); }
                        }
                    }
                }
            }
            catch (System.IO.IOException ioe)
            {
                HandleIOException(ioe, state);
            }
            //We dont need to take care of ObjectDisposedException. 
            //ObjectDisposedException would indicate that the state has been closed, and that means it has been disconnected already
            catch { }
        }

        void WriteCallback(IAsyncResult ar)
        {
            RemoteHostState state = (RemoteHostState)ar.AsyncState;

            {   //READ-LOCKS THE STREAM-PROPERTY
                state.streamLock.EnterReadLock();
                try
                {
                    state.Stream.EndWrite(ar);
                }
                catch (System.IO.IOException ioe)
                {
                    HandleIOException(ioe, state);
                    return;
                }
                //We dont need to take care of ObjectDisposedException. 
                //ObjectDisposedException would indicate that the state has been closed, and that means it has been disconnected already
                catch { }
                finally { state.streamLock.ExitReadLock(); }
            }

            bool doSendMore = false;
            lock (state.SendQueue)
            {
                if (state.SendQueue.Count > 0)   //This should always be true, since the currently sending data is left in the queue until this point
                    state.SendQueue.Dequeue();

                if (state.SendQueue.Count > 0)
                    doSendMore = true;
            }

            if (doSendMore)
                DoSend(state);
        }

        public void SendTo(string str, RemoteHostState client)
        {
            byte[] data = null;
            try
            {
                if (ProtocolStrategy != null && ProtocolStrategy.Encoding != null)
                    data = ProtocolStrategy.Encoding.GetBytes(str + ProtocolStrategy.Delimiter);
                else
                    data = Encoding.ASCII.GetBytes(str);
            }
            catch { }

            SendTo(data, client);
        }

        public void SendTo(byte[] data, RemoteHostState client)
        {
            client.Send(data);
        }

        public void SendToAll(string str)
        {
            byte[] data = null;
            try
            {
                if (ProtocolStrategy != null)
                    data = ProtocolStrategy.Encoding.GetBytes(str + ProtocolStrategy.Delimiter);
                else
                    data = Encoding.ASCII.GetBytes(str);
            }
            catch { }

            SendToAll(data);
        }
        public void SendToAll(byte[] data)
        {
            if (data != null)
            {
                RemoteHostState[] hosts = null;
                lock(clients)
                    hosts = clients.ToArray();

                if(hosts != null)
                    foreach (RemoteHostState state in hosts)
                        SendTo(data, state);
            }
        }
        #endregion

        public RemoteHostState[] GetClientsAsArray()
        {
            RemoteHostState[] hosts = null;
            lock (clients)
                hosts = clients.ToArray();

            return hosts;
        }

        void CloseConnection(RemoteHostState state, bool remote)
        {
            CloseConnection(state, remote, null);
        }
        void CloseConnection(RemoteHostState state, Exception ex)
        {
            CloseConnection(state, false, ex);
        }
        void CloseConnection(RemoteHostState state, bool remote, Exception ex)
        {
            if (state != null)
            {
                lock (clients)
                    clients.Remove(state);
                IPEndPoint remoteHost = state.EndPoint;
                state.GotDataToSend -= state_GotDataToSend;
                state.Close();

                OnClientConnectionStateChanged(remoteHost, false, ex, remote);
            }
        }

        public void CloseAll()
        {
            lock (clients)
            {
                foreach (RemoteHostState client in clients)
                {
                    IPEndPoint remoteHost = client.EndPoint;
                    client.GotDataToSend -= state_GotDataToSend;
                    client.Close();

                    OnClientConnectionStateChanged(remoteHost, false, null, false);
                }

                clients.Clear();
            }
        }

        protected void OnClientConnectionStateChanged(IPEndPoint remoteHost, bool connected, Exception ex, bool remote)
        {
            try
            {
                if (ClientConnectionStateChanged != null)
                    ClientConnectionStateChanged(this, new ClientConnectionEventArgs(remoteHost.Address.ToString(), remoteHost.Port, connected, ex, remote));
            }
            catch { } 
        }
        protected void OnUnexpectedStop()
        {
            try
            {
                if (UnexpectedStop != null)
                    UnexpectedStop(this, EventArgs.Empty);
            }
            catch { }
        }
    }
}
