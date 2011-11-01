using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;
using System.Net;
using System.Net.Sockets;

namespace Svt.Network	
{
    [Obsolete()]
	public class ExceptionEventArgs : EventArgs
	{
		public ExceptionEventArgs(Exception e) {
			exception_ = e;
		}

		private Exception exception_;
		public Exception Exception {
			get { return exception_; }
		}
	}

    [Obsolete()]
    public class NetworkEventArgs : EventArgs
	{
		public NetworkEventArgs(string host, int port)
		{
			Hostname = host;
			Port = port;
		}

		private string host_;
		public string Hostname
		{
			get { return host_; }
			set { host_ = value; }
		}
		private int port_;
		public int Port
		{
			get { return port_; }
			set { port_ = value; }
		}
	}

	public class ServerConnection
    {
        #region obsolete
        [Browsable(true),
        Obsolete("Use ConnectionStateChanged instead"),
		Description("Occurs when a connection is established. It is not guaranteed that this event will be fired in the main GUI-thread.")]
		public event EventHandler<NetworkEventArgs> Connected;

		[Browsable(true),
        Obsolete("Use ConnectionStateChanged instead"),
        Description("Occurs when we get disconnected. It is not guaranteed that this event will be fired in the main GUI-thread.")]
		public event EventHandler<NetworkEventArgs> Disconnected;

		[Browsable(true),
        Obsolete("Use ConnectionStateChanged instead"),
        Description("Occurs when an attempted connection fails. It is not guaranteed that this event will be fired in the main GUI-thread.")]
		public event EventHandler<NetworkEventArgs> FailedConnect;

		[Browsable(true),
        Obsolete("Relevant exceptions are handled internally."),
        Description("Occurs when an exception is thrown during an async network call. It is not guaranteed that this event will be fired in the main GUI-thread.")]
		public event EventHandler<ExceptionEventArgs> CaughtAsyncException;

        [Obsolete("Use the default constructor instead")]
		public ServerConnection(string hostname, int port)
		{
			Hostname = hostname;
			Port = port;
		}

        [Obsolete("Use InitiateConnection instead")]
        public void Connect(string hostname, int port)
		{
			Hostname = hostname;
			Port = port;
			Connect();
		}

        [Obsolete("Use InitiateConnection instead")]
        public void Connect()
        {
			TcpClient client = new TcpClient();
			try
			{
				client.BeginConnect(Hostname, Port, new AsyncCallback(ConnectCallback_obsolete), client);
			}
			catch {
				if(client != null) {
					client.Close();
					client = null;
				}

				OnFailedConnect();
				throw;
			}
		}
        [Obsolete()]
        private void ConnectCallback_obsolete(IAsyncResult ar)
        {
			TcpClient client = null;
            try
            {
				client = (TcpClient)ar.AsyncState;
                client.EndConnect(ar);
                client.NoDelay = true;

				RemoteState = new RemoteHostState(client);
				RemoteState.Stream.BeginRead(RemoteState.ReadBuffer, 0, RemoteState.ReadBuffer.Length, new AsyncCallback(RecvCallback_obsolete), null);

                OnConnected();
            }
            catch
            {
				if (RemoteState != null)
				{
					RemoteState.Close();
					RemoteState = null;
				}
				else if (client != null)
                {
                    client.Close();
                    client = null;
                }

                OnFailedConnect();
            }
        }
        [Obsolete()]
        private void RecvCallback_obsolete(IAsyncResult ar)
        {
            try
            {
                if (RemoteState.Stream.CanRead)
                {
                    int len = RemoteState.Stream.EndRead(ar);
                    if (len == 0)
                    {
                        Disconnect();
                    }
                    else
                    {
                        string data = "";
                        if (ProtocolStrategy != null)
                        {
                            data = ProtocolStrategy.Encoding.GetString(RemoteState.ReadBuffer, 0, len);
                            ProtocolStrategy.Parse(data);
                        }

                        RemoteState.Stream.BeginRead(RemoteState.ReadBuffer, 0, RemoteState.ReadBuffer.Length, new AsyncCallback(RecvCallback_obsolete), null);
                    }
                }
            }
            catch (System.IO.IOException ioe)
            {
                if (ioe.InnerException.GetType() == typeof(System.Net.Sockets.SocketError))
                {
                    System.Net.Sockets.SocketException se = (System.Net.Sockets.SocketException)ioe.InnerException;

                    try
                    {
                        Disconnect();
                    }
                    catch (NullReferenceException)
                    { }
                    catch (Exception e)
                    {
                        OnAsyncException(new ExceptionEventArgs(e));
                    }
                }
            }
            catch (NullReferenceException)
            { }
            catch (Exception e)
            {
                OnAsyncException(new ExceptionEventArgs(e));
            }
        }

        [Obsolete("Use CloseConnection instead")]
		public void Disconnect()
		{
			if(RemoteState != null && RemoteState.Close())
			{
                try
                {
                    //Signal that we got disconnected
                    if (Disconnected != null)
                        Disconnected(this, new NetworkEventArgs(Hostname, Port));
                }
                catch { }
			}
		}

        [Obsolete()]
        protected void OnConnected()
        {
            try
            {
                //Signal that we got connected
                if (Connected != null)
                    Connected(this, new NetworkEventArgs(Hostname, Port));
            }
            catch { }
        }

        [Obsolete()]
        protected void OnFailedConnect()
        {
            try
            {
                //Signal that an exception was caught during an asynchronous network call
                if (FailedConnect != null)
                    FailedConnect(this, new NetworkEventArgs(Hostname, Port));
            }
            catch { }
        }

        [Obsolete()]
        protected void OnAsyncException(ExceptionEventArgs serverExceptionEventArgs)
        {
            try
            {
                //Signal that an exception was caught during an asynchronous network call
                if (CaughtAsyncException != null)
                    CaughtAsyncException(this, serverExceptionEventArgs);
            }
            catch { }
        }
        #endregion

        [Browsable(true),
        Description("Occurs when the state of the connection is changed. It is not guaranteed that this event will be fired in the main GUI-thread.")]
        public event EventHandler<ConnectionEventArgs> ConnectionStateChanged;

        public string Hostname { get; private set; }
        public int Port { get; private set; }
        public IProtocolStrategy ProtocolStrategy { get; set; }
		RemoteHostState RemoteState { get; set; }

        public bool IsConnected
        {
            get { return (RemoteState != null) ? RemoteState.Connected : false; }
        }


		public ServerConnection() 
		{}

        public void InitiateConnection(string hostName, int port)
        {
            if (RemoteState != null)
                CloseConnection();

			Hostname = (string.IsNullOrEmpty(hostName) ? "localhost" : hostName);
            Port = port;

			TcpClient client = new TcpClient();
			try
            {
                client.BeginConnect(Hostname, Port, new AsyncCallback(ConnectCallback), client);
            }
            catch(Exception ex)
            {
				if (client != null)
				{
					client.Close();
					client = null;
				}
                OnClosedConnection(ex);
            }
        }

		private void ConnectCallback(IAsyncResult ar) 
		{
			TcpClient client = null;
			try
			{
				client = (TcpClient)ar.AsyncState;
				client.EndConnect(ar);
				client.NoDelay = true;

				RemoteState = new RemoteHostState(client);
				RemoteState.Stream.BeginRead(RemoteState.ReadBuffer, 0, RemoteState.ReadBuffer.Length, new AsyncCallback(RecvCallback), null);

				OnOpenedConnection();
			}
			catch(Exception ex)
			{
				if (RemoteState != null)
				{
					DoCloseConnection();
				}
				else
				{
					if (client != null)
					{
						client.Close();
						client = null;
					}
				}
				OnClosedConnection(ex);
			}
		}

        private bool DoCloseConnection()
        {
            return (RemoteState != null) ? RemoteState.Close() : false;
        }

        public void CloseConnection()
        {
            //Only send notification if there actually was a connection to close
            if (DoCloseConnection())
                OnClosedConnection();
        }

		public bool SendString(string str) {
            try
            {
                if (RemoteState != null && RemoteState.Stream.CanWrite)
                {
                    String data = str;
                    byte[] sendBytes = null;
                    if (ProtocolStrategy != null)
                    {
                        data += ProtocolStrategy.Delimiter;
                        sendBytes = ProtocolStrategy.Encoding.GetBytes(data);
                    }
                    else
                        sendBytes = Encoding.ASCII.GetBytes(data);

                    if (sendBytes.Length > 0)
                        RemoteState.Stream.Write(sendBytes, 0, sendBytes.Length);

                    return true;
                }
            }
            catch (System.IO.IOException ioe)
            {
                if (ioe.InnerException.GetType() == typeof(System.Net.Sockets.SocketError))
                {
                    System.Net.Sockets.SocketException se = (System.Net.Sockets.SocketException)ioe.InnerException;
                    if (DoCloseConnection())
                        OnClosedConnection(se);                    
                }
                else
                    throw;
            }
            catch (System.ObjectDisposedException ode)
            {
                if (DoCloseConnection())
                    OnClosedConnection(ode);
            }
			
			return false;
		}

		private void RecvCallback(IAsyncResult ar) 
        {
            try
            {
                int len = RemoteState.Stream.EndRead(ar);
                if (len == 0)
                    CloseConnection();
                else
                {
                    try
                    {
                        if (ProtocolStrategy != null)
                        {
                            if (ProtocolStrategy.Encoding != null)
                                ProtocolStrategy.Parse(ProtocolStrategy.Encoding.GetString(RemoteState.ReadBuffer, 0, len));
                            else
                                ProtocolStrategy.Parse(RemoteState.ReadBuffer, len);
                        }
                    }
                    catch { }

                    RemoteState.Stream.BeginRead(RemoteState.ReadBuffer, 0, RemoteState.ReadBuffer.Length, new AsyncCallback(RecvCallback), null);
                }
            }
            catch (System.IO.IOException ioe)
            {
                if (ioe.InnerException.GetType() == typeof(System.Net.Sockets.SocketError))
                {
                    System.Net.Sockets.SocketException se = (System.Net.Sockets.SocketException)ioe.InnerException;

                    if (DoCloseConnection())
                        OnClosedConnection(se);
                }
            }
            catch { }
		}

		protected void OnOpenedConnection()
		{
            try
            {
                //Signal that we got connected
                if (ConnectionStateChanged != null)
                    ConnectionStateChanged(this, new ConnectionEventArgs(Hostname, Port, true));
            }
            catch { }
		}

        protected void OnClosedConnection()
        {
            OnClosedConnection(null);
        }
        protected void OnClosedConnection(Exception ex)
        {
            try
            {
                //Signal that we got diconnected
                if (ConnectionStateChanged != null)
                    ConnectionStateChanged(this, new ConnectionEventArgs(Hostname, Port, false, ex));
            }
            catch { }
 		}
	}
}
