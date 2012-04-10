using System;
using System.Collections.Generic;
using System.Text;

namespace Svt.Caspar
{
	public class Channel
	{
		int id_ = 0;
		CasparDevice device_ = null;
		CGManager cgManager_ = null;
		internal Channel(CasparDevice device, int id, VideoMode v)
		{
			id_ = id;
			videoMode_ = v;
			device_ = device;
			cgManager_ = new CGManager(this);
		}

		internal CasparDevice Device
		{
			get { return device_; }
		}

		public int ID
		{
			get { return id_; }
		}

		VideoMode videoMode_ = VideoMode.PAL;
		public VideoMode VideoMode
		{
			get { return videoMode_; }
			internal set { videoMode_ = value; }
		}

		public CGManager CG
		{
			get { return cgManager_; }
		}

/*		CasparItem currentItem_ = null;
		CasparItem CurrentItem
		{
			get { return currentItem_; }
			set { currentItem_ = value; }
		}

		CasparItem nextItem_ = null;
		CasparItem NextItem
		{
			get { return nextItem_; }
			set { nextItem_ = value; }
		}
*/
		public bool Load(string clipname, bool loop)
		{
			Device.Server.SendString("LOAD " + ID + "  " + clipname + (string)(loop ? " LOOP" : ""));
			return true;
		}
        public bool Load(int videoLayer, string clipname, bool loop)
        {
            if (videoLayer == -1)
                Load(clipname, loop);
            else
                Device.Server.SendString("LOAD " + ID + "-" + videoLayer + "  " + clipname + (string)(loop ? " LOOP" : ""));

            return true;
        }
		public bool Load(CasparItem item)
		{
            if (item.VideoLayer == -1)
                Device.Server.SendString("LOAD " + ID + "  " + item.Clipname + (string)(item.Loop ? " LOOP" : ""));
            else
			    Device.Server.SendString("LOAD " + ID + "-" + item.VideoLayer + "  " + item.Clipname + (string)(item.Loop ? " LOOP" : ""));
			return true;
		}
       





		public bool LoadBG(CasparItem item)
		{
            item.Clipname = '"' + item.Clipname.Replace("\\", "\\\\") + '"';
            if (item.VideoLayer == -1)
			    Device.Server.SendString("LOADBG " + ID + "  " + item.Clipname + (string)(item.Loop ? " LOOP" : "") + " " + item.Transition);
            else
                Device.Server.SendString("LOADBG " + ID + "-" + item.VideoLayer + "  " + item.Clipname + (string)(item.Loop ? " LOOP" : "") + " " + item.Transition);

			return true;
		}
        public bool LoadBG(int videoLayer, string clipname, bool loop)
        {
            clipname = '"' + clipname.Replace("\\", "\\\\") + '"';
            if (videoLayer == -1)
                Device.Server.SendString("LOADBG " + ID + "  " + clipname + (string)(loop ? " LOOP" : ""));
            else
                Device.Server.SendString("LOADBG " + ID + "-" + videoLayer + "  " + clipname + (string)(loop ? " LOOP" : ""));
           
            return true;
        }
        public bool LoadBG(int videoLayer, string clipname, bool loop, uint seek, uint length)
        {
            clipname = '"' + clipname.Replace("\\", "\\\\") + '"';
            if (videoLayer == -1)
                Device.Server.SendString("LOADBG " + ID + "  " + clipname + (string)(loop ? " LOOP" : "") + " SEEK " + seek.ToString() + " LENGTH " + length.ToString());
            else
                Device.Server.SendString("LOADBG " + ID + "-" + videoLayer + "  " + clipname + (string)(loop ? " LOOP" : "") + " SEEK " + seek.ToString() + " LENGTH " + length.ToString());

            return true;
        }
        public bool LoadBG(int videoLayer, string clipname, bool loop, TransitionType transition, uint transitionDuration)
		{
            clipname = '"' + clipname.Replace("\\", "\\\\") + '"';
            if (videoLayer == -1)
			    Device.Server.SendString("LOADBG " + ID + "  " + clipname + (string)(loop ? " LOOP" : "") + " " + transition.ToString() + " " + transitionDuration.ToString());
            else
                Device.Server.SendString("LOADBG " + ID + "-" + videoLayer + "  " + clipname + (string)(loop ? " LOOP" : "") + " " + transition.ToString() + " " + transitionDuration.ToString());

			return true;
		}
        public bool LoadBG(int videoLayer, string clipname, bool loop, TransitionType transition, uint transitionDuration, TransitionDirection direction)
        {
            clipname = '"' + clipname.Replace("\\", "\\\\") + '"';
            if (videoLayer == -1)
                Device.Server.SendString("LOADBG " + ID + "  " + clipname + (string)(loop ? " LOOP" : "") + " " + transition.ToString() + " " + transitionDuration.ToString() + " " + direction.ToString());
            else
                Device.Server.SendString("LOADBG " + ID + "-" + videoLayer + "  " + clipname + (string)(loop ? " LOOP" : "") + " " + transition.ToString() + " " + transitionDuration.ToString() + " " + direction.ToString());

            return true;
        }
        public bool LoadBG(int videoLayer, string clipname, bool loop, TransitionType transition, uint transitionDuration, TransitionDirection direction, uint seek, uint length)
        {
            clipname = '"' + clipname.Replace("\\", "\\\\") + '"';
            if (videoLayer == -1)
                Device.Server.SendString("LOADBG " + ID + "  " + clipname + (string)(loop ? " LOOP" : "") + " " + transition.ToString() + " " + transitionDuration.ToString() + " " + direction.ToString() + " SEEK " + seek.ToString() + " LENGTH " + length.ToString());
            else
                Device.Server.SendString("LOADBG " + ID + "-" + videoLayer + "  " + clipname + (string)(loop ? " LOOP" : "") + " " + transition.ToString() + " " + transitionDuration.ToString() + " " + direction.ToString() + " SEEK " + seek.ToString() + " LENGTH " + length.ToString());

            return true;
        }

		public void Play()
		{
			Device.Server.SendString("PLAY " + ID);
		}
        public void Play(int videoLayer)
        {
            if (videoLayer == -1)
                Play();
            else
                Device.Server.SendString("PLAY " + ID + "-" + videoLayer);
        }

		public void Stop()
		{
			Device.Server.SendString("STOP " + ID);
		}
        public void Stop(int videoLayer)
        {
            if (videoLayer == -1)
                Stop();
            else
                Device.Server.SendString("STOP " + ID + "-" + videoLayer);
        }

		public void Clear()
		{
			Device.Server.SendString("CLEAR " + ID);
		}
        public void Clear(int videoLayer)
        {
            if (videoLayer == -1)
                Clear();
            else
                Device.Server.SendString("CLEAR " + ID + "-" + videoLayer);
        }

		public void SetMode(VideoMode mode)
		{
			Device.Server.SendString("SET " + ID + " MODE " + ToAMCPString(mode));
		}

		private string ToAMCPString(VideoMode mode)
		{
			string result = string.Empty;
			switch (mode)
			{
				case VideoMode.Unknown:
				case VideoMode.PAL:
				case VideoMode.NTSC:
					result = mode.ToString();
					break;

				default:
					{
						string modestr = mode.ToString();
						result = (modestr.Length > 2) ? modestr.Substring(2) : modestr;
						break;
					}
			}

			return result;
		}
	}

	public enum VideoMode
	{
		PAL,
		NTSC,
		SD576p2500,
		HD720p5000,
		HD1080i5000,
		Unknown
	}
	public enum ChannelStatus
	{
		Playing,
		Stopped
	}
	internal class ChannelInfo
	{
		public ChannelInfo(int id, VideoMode vm, ChannelStatus cs, string activeClip)
		{
			ID = id;
			VideoMode = vm;
			Status = cs;
			ActiveClip = activeClip;
		}

		private int id_;
		public int ID
		{
			get { return id_; }
			set { id_ = value; }
		}

		private VideoMode mode_;
		public VideoMode VideoMode
		{
			get { return mode_; }
			set { mode_ = value; }
		}

		private ChannelStatus status_;
		public ChannelStatus Status
		{
			get { return status_; }
			set { status_ = value; }
		}

		private string activeClip_;
		public string ActiveClip
		{
			get { return activeClip_; }
			set { activeClip_ = value; }
		}
	}
}
