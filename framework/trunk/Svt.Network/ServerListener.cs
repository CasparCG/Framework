using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Sockets;
using System.Net;

namespace Svt.Network
{
    public class ServerListener
    {
        TcpListener listener = null;
        AsyncCallback asyncAcceptCallback = null;
        List<RemoteHostState> clients = null;

        public event EventHandler<ClientConnectionEventArgs> ClientConnectionStateChanged;
        public event EventHandler<EventArgs> UnexpectedStop;
        public IProtocolStrategy ProtocolStrategy { get; set; }

        public ServerListener()
        {
            clients = new List<RemoteHostState>();
            asyncAcceptCallback = new AsyncCallback(AcceptCallback);
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
					state.Stream.BeginRead(state.ReadBuffer, 0, state.ReadBuffer.Length, new AsyncCallback(ReadCallback), state);

					OnClientConnectionStateChanged(state.EndPoint, true, null, true);
				}
				else
					beginNewAccept = false;
            }
            catch(SocketException se)
            {
                if(se.SocketErrorCode == SocketError.Interrupted)
                {
                    beginNewAccept = false;
                }
            }
            catch(Exception ex)
            {
                CloseConnection(state, ex);
            }

            if(state != null)
                clients.Add(state);

            if(beginNewAccept)
                DoBeginAccept();
        }
       
        void ReadCallback(IAsyncResult ar)
        {
            RemoteHostState state = (RemoteHostState)ar.AsyncState;
            try
            {
                int len = state.Stream.EndRead(ar);
                if (len == 0)
                    CloseConnection(state, true);
                else
                {
                    if (ProtocolStrategy != null)
                    {
                        if (ProtocolStrategy.Encoding != null)
                            ProtocolStrategy.Parse(ProtocolStrategy.Encoding.GetString(state.ReadBuffer, 0, len));
                        else
                            ProtocolStrategy.Parse(state.ReadBuffer, len);
                    }

                    state.Stream.BeginRead(state.ReadBuffer, 0, state.ReadBuffer.Length, new AsyncCallback(ReadCallback), state);
                }
            }
            catch (System.IO.IOException ioe)
            {
                if (ioe.InnerException.GetType() == typeof(System.Net.Sockets.SocketError))
                {
                    System.Net.Sockets.SocketException se = (System.Net.Sockets.SocketException)ioe.InnerException;
                    CloseConnection(state, (se.SocketErrorCode == SocketError.Interrupted)?null:se);
                }
            }
            catch { }
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
                IPEndPoint remoteHost = state.EndPoint;
                clients.Remove(state);
                state.Close();

                OnClientConnectionStateChanged(remoteHost, false, ex, remote);
            }
        }

        public void SendTo(string str, RemoteHostState client)
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

            try
            {
                client.Send(data);
            }
            catch (System.IO.IOException ioe)
            {
                CloseConnection(client, ioe);
            }
            catch { }
        }
        public void SendTo(byte[] data, RemoteHostState client)
        {
            try
            {
                client.Send(data);
            }
            catch (System.IO.IOException ioe)
            {
                CloseConnection(client, ioe);
            }
            catch { }
        }

        public void SendToAllClients(string str)
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

            if (data != null)
            {
                foreach (RemoteHostState state in clients)
                {
                    try
                    {
                        state.Send(data);
                    }
                    catch (System.IO.IOException ioe)
                    {
                        CloseConnection(state, ioe);
                    }
                    catch { }
                }
            }
        }

        public void CloseAll()
        {
            foreach (RemoteHostState client in clients)
                CloseConnection(client, false);

            clients.Clear();
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
