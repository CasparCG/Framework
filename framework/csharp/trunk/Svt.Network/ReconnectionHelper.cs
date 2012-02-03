using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Svt.Network
{
	public class ReconnectionHelper : IDisposable
	{
		System.Timers.Timer Timer { get; set; }
		ServerConnection Connection { get; set; }

		public event EventHandler<ConnectionEventArgs> Reconnected;

		public ReconnectionHelper(ServerConnection connection, int interval)
		{
			Connection = connection;
			Connection.ConnectionStateChanged += Connection_ConnectionStateChanged;

			Timer = new System.Timers.Timer(interval);
			Timer.AutoReset = false;
			Timer.Elapsed += Timer_Elapsed;
		}

		public void Start()
		{
			Timer.Start();
		}

		public void Close()
		{
			if (Timer != null)
			{
				Timer.Stop();
				Timer.Elapsed -= Timer_Elapsed;
				Timer.Close();
				Timer = null;
			}

			if (Connection != null)
			{
				Connection.ConnectionStateChanged -= Connection_ConnectionStateChanged;
				Connection = null;
			}
		}

		void Connection_ConnectionStateChanged(object sender, ConnectionEventArgs e)
		{
			if (e.Connected)
			{
				OnReconnected(e);
			}
			else
				Timer.Start();
		}

		void Timer_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
		{
			Connection.InitiateConnection(Connection.Hostname, Connection.Port);
		}

		protected void OnReconnected(ConnectionEventArgs e)
		{
			try
			{
				if (Reconnected != null)
					Reconnected(this, e);
			}
			catch { }
		}

		public void Dispose()
		{
			Close();
		}
	}
}
