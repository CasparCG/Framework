using System;
using System.Collections.Generic;
using System.Text;

namespace Svt.Caspar
{
	public class CasparDevice
	{
		private Svt.Network.ServerConnection server_ = new Svt.Network.ServerConnection();
		private TemplatesCollection templates_ = new TemplatesCollection();
		private List<MediaInfo> mediafiles_ = new List<MediaInfo>();
		private List<string> datafiles_ = new List<string>();
		private List<Channel> channels_ = new List<Channel>();
		private CasparDeviceSettings settings_ = new CasparDeviceSettings();
		private string version_ = "unknown";

		public event EventHandler<Svt.Network.NetworkEventArgs> Connected;
		public event EventHandler<Svt.Network.NetworkEventArgs> Disconnected;
		public event EventHandler<Svt.Network.NetworkEventArgs> FailedConnect;
		public event EventHandler<Svt.Network.ExceptionEventArgs> OnAsyncException;
		public event EventHandler<DataEventArgs> DataRetrieved;
		public event EventHandler<EventArgs> UpdatedChannels;
		public event EventHandler<EventArgs> UpdatedTemplates;
		public event EventHandler<EventArgs> UpdatedMediafiles;
		public event EventHandler<EventArgs> UpdatedDatafiles;

		public CasparDevice()
		{
			DoInitialize();
		}

		void DoInitialize()
		{
			server_.ProtocolStrategy = new AMCP.AMCPProtocolStrategy(this);
			server_.Connected += new EventHandler<Svt.Network.NetworkEventArgs>(server__Connected);
			server_.Disconnected += new EventHandler<Svt.Network.NetworkEventArgs>(server__Disconnected);
			server_.FailedConnect += new EventHandler<Svt.Network.NetworkEventArgs>(server__FailedConnect);
			server_.CaughtAsyncException += new EventHandler<Svt.Network.ExceptionEventArgs>(server__CaughtAsyncException);
		}

		#region Server notifications
		void server__Connected(object sender, Svt.Network.NetworkEventArgs e)
		{
			server_.SendString("VERSION");

			//Ask server for channels
			server_.SendString("INFO");

			//ask server for templates
			server_.SendString("TLS");

			if (Connected != null)
				Connected(this, e);
		}
		void server__Disconnected(object sender, Svt.Network.NetworkEventArgs e)
		{
			if (Disconnected != null)
				Disconnected(this, e);

			Channels.Clear();
			Templates.Clear();
		}
		void server__FailedConnect(object sender, Svt.Network.NetworkEventArgs e)
		{
			if (FailedConnect != null)
				FailedConnect(this, e);
		}
		void server__CaughtAsyncException(object sender, Svt.Network.ExceptionEventArgs e)
		{
			if (OnAsyncException != null)
				OnAsyncException(this, e);
		}
		#endregion

		public void RefreshMediafiles()
		{
			if (IsConnected)
				server_.SendString("CLS");
		}
		public void RefreshTemplates()
		{
			if (IsConnected)
				server_.SendString("TLS");
		}
		public void RefreshDatalist()
		{
			if (IsConnected)
				server_.SendString("DATA LIST");
		}
		public void StoreData(string name, ICGDataContainer data)
		{
			if (IsConnected)
				server_.SendString("DATA STORE \"" + name + "\" \"" + data.ToAMCPEscapedXml() + "\"");
		}
		public void RetrieveData(string name)
		{
			if (IsConnected)
				server_.SendString("DATA RETRIEVE \"" + name + "\"");
		}

		#region Properties
		public List<Channel> Channels
		{
			get { return channels_; }
		}
		public CasparDeviceSettings Settings
		{
			get { return settings_; }
		}
		public TemplatesCollection Templates
		{
			get { return templates_; }
		}
		public List<MediaInfo> Mediafiles
		{
			get { return mediafiles_; }
		}
		public List<string> Datafiles
		{
			get { return datafiles_; }
		}
		public bool IsConnected
		{
			get { return (server_ == null) ? false : server_.IsConnected; }
		}
		internal Svt.Network.ServerConnection Server
		{
			get { return server_; }
		}
		public string Version
		{
			get { return version_; }
		}
		#endregion

		#region Connection
		public bool Connect()
		{
			if (!IsConnected)
			{
				server_.Connect(Settings.Hostname, Settings.Port);
				return true;
			}
			return false;
		}

		public void Disconnect()
		{
			server_.Disconnect();
		}
		#endregion

		#region AMCP-protocol callbacks
		internal void OnUpdatedChannelInfo(List<ChannelInfo> channels)
		{
			foreach (ChannelInfo info in channels)
			{
				if (channels_.Count < info.ID)
					channels_.Add(new Channel(this, info.ID, info.VideoMode));
				else
					channels_[info.ID-1].VideoMode = info.VideoMode;
			}

			if (UpdatedChannels != null)
				UpdatedChannels(this, EventArgs.Empty);
		}
		internal void OnUpdatedTemplatesList(List<TemplateInfo> templates)
		{
			Templates.Populate(templates);

			if (UpdatedTemplates != null)
				UpdatedTemplates(this, EventArgs.Empty);
		}
		internal void OnUpdatedMediafiles(List<MediaInfo> mediafiles)
		{
			System.Threading.Interlocked.Exchange<List<MediaInfo>>(ref mediafiles_, mediafiles);

			if (UpdatedMediafiles != null)
				UpdatedMediafiles(this, EventArgs.Empty);
		}

		internal void OnVersion(string version)
		{
			version_ = version;
		}

		internal void OnLoad(string clipname)
		{
		}

		internal void OnLoadBG(string clipname)
		{
		}

		internal void OnUpdatedDataList(List<string> datafiles)
		{
			System.Threading.Interlocked.Exchange<List<string>>(ref datafiles_, datafiles);

			if (UpdatedDatafiles != null)
				UpdatedDatafiles(this, EventArgs.Empty);
		}

		internal void OnDataRetrieved(string data)
		{
			if(DataRetrieved != null)
				DataRetrieved(this, new DataEventArgs(data));
		}
		#endregion
	}

	public class DataEventArgs : EventArgs
	{
		public DataEventArgs(string data)
		{
			Data = data;
		}

		public string Data { get; set; }
	}

	public class CasparDeviceSettings
	{
		private string hostname_;
		public string Hostname
		{
			get { return hostname_; }
			set { hostname_ = value; }
		}

		private int port_;
		public int Port
		{
			get { return port_; }
			set { port_ = value; }
		}

		private bool autoconnect_;
		public bool AutoConnect
		{
			get { return autoconnect_; }
			set { autoconnect_ = value; }
		}
	}
}
