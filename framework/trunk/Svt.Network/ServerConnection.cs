using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;
using System.Net;
using System.Net.Sockets;

namespace Svt.Network	
{
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
		[Browsable(true),
		Description("Occurs when a connection is established. It is not guaranteed that this event will be fired in the main GUI-thread.")]
		public event EventHandler<NetworkEventArgs> Connected;

		[Browsable(true),
		Description("Occurs when we get disconnected. It is not guaranteed that this event will be fired in the main GUI-thread.")]
		public event EventHandler<NetworkEventArgs> Disconnected;

		[Browsable(true),
		Description("Occurs when an attempted connection fails. It is not guaranteed that this event will be fired in the main GUI-thread.")]
		public event EventHandler<NetworkEventArgs> FailedConnect;

		[Browsable(true),
		Description("Occurs when an exception is thrown during an async network call. It is not guaranteed that this event will be fired in the main GUI-thread.")]
		public event EventHandler<ExceptionEventArgs> CaughtAsyncException;

		private string hostname_ = "localhost";
		private int port_ = 5250;
		private IProtocolStrategy strategy_ = null;

		TcpClient myClient = null;
		NetworkStream myStream = null;
		byte[] recvBuffer = new byte[1024];

		public ServerConnection() 
		{}
		public ServerConnection(string hostname, int port)
		{
			Hostname = hostname;
			Port = port;
		}

		public void Connect(string hostname, int port)
		{
			Hostname = hostname;
			Port = port;
			Connect();
		}

		public void Connect() {
			try
			{
				myClient = new TcpClient();
				myClient.BeginConnect(Hostname, Port, new AsyncCallback(ConnectCallback), null);
			}
			catch {
				if(myClient != null) {
					myClient.Close();
					myClient = null;
				}

				OnFailedConnect();
				throw;
			}
		}

		private void ConnectCallback(IAsyncResult ar) {
			try
			{
				myClient.EndConnect(ar);

				myClient.NoDelay = true;
				myStream = myClient.GetStream();
				myStream.BeginRead(recvBuffer, 0, recvBuffer.Length, new AsyncCallback(RecvCallback), null);

				try
				{
					OnConnected();
				}
				catch (Exception e)
				{
					OnAsyncException(new ExceptionEventArgs(e));
				}
			}
			catch(Exception)
			{
				if(myStream != null) {
					myStream.Close();
					myStream = null;
				}

				if(myClient != null) {
					myClient.Close();
					myClient = null;
				}

				try
				{
					OnFailedConnect();
				}
				catch (Exception e)
				{
					OnAsyncException(new ExceptionEventArgs(e));
				}
			}

		}

		public void Disconnect() {

			if(myStream != null) {
				myStream.Close();
			}

			if(myClient != null) {
				myClient.Close();

				OnDisconnected();
			}
		}

		public bool SendString(string str) {
			try
			{
				if (myStream != null && myStream.CanWrite)
				{
					String data = str;
					if (strategy_ != null)
						data += strategy_.Delimiter;

					byte[] sendBytes = strategy_.Encoding.GetBytes(data);
					myStream.Write(sendBytes, 0, sendBytes.Length);
					return true;
				}
			}
			catch { }
			
			return false;
		}

		private void RecvCallback(IAsyncResult ar) {
			try
			{
				if (myStream.CanRead)
				{
					int len = myStream.EndRead(ar);
					if (len == 0)
					{
						Disconnect();
					}
					else
					{
						string data = "";
						if (strategy_ != null)
						{
							data = strategy_.Encoding.GetString(recvBuffer, 0, len);
							strategy_.ParseResponse(data);
						}

						myStream.BeginRead(recvBuffer, 0, recvBuffer.Length, new AsyncCallback(RecvCallback), null);
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
					catch (NullReferenceException ne)
					{ }
					catch (Exception e)
					{
						OnAsyncException(new ExceptionEventArgs(e));
					}
				}
			}
			catch (NullReferenceException ne)
			{ }
			catch (Exception e)
			{
				OnAsyncException(new ExceptionEventArgs(e));
			}
		}

		protected void OnConnected()
		{
			//Signal that we got connected
			if (Connected != null)
				Connected(this, new NetworkEventArgs(Hostname, Port));
		}

		protected void OnDisconnected()
		{
			//Signal that we got disconnected
			if (Disconnected != null)
				Disconnected(this, new NetworkEventArgs(Hostname, Port));
		}

		protected void OnFailedConnect()
		{
			//Signal that we failed to connected
			if (FailedConnect != null)
				FailedConnect(this, new NetworkEventArgs(Hostname, Port));
		}

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

		#region Properties
		public string Hostname {
			get { return hostname_; }
			set { hostname_ = (value == null || value == string.Empty) ? "localhost" : value; }
		}
		public int Port {
			get { return port_; }
			set { port_ = value; }
		}
		public bool IsConnected {
			get { return (myClient != null) ? myClient.Connected : false; }
		}
		public IProtocolStrategy ProtocolStrategy {
			get { return strategy_; }
			set { strategy_ = value; }
		}
		#endregion Properties
	}
}
