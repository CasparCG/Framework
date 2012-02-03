using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using System.Xml.XPath;

namespace Svt.Caspar
{
	public class CasparItem : System.Xml.Serialization.IXmlSerializable
	{
		public CasparItem(string clipname)
		{
			clipname_ = clipname;
		}
		public CasparItem(string clipname, Transition transition)
		{
			clipname_ = clipname;
			if (transition != null)
			{
				transition_.Type = transition.Type;
				transition_.Duration = transition.Duration;
			}
		}

		public static CasparItem Create(System.Xml.XmlReader reader)
		{
			CasparItem item = new CasparItem();
			item.ReadXml(reader);
			return item;
		}
		private CasparItem()
		{}

		private string clipname_;
		public string Clipname
		{
			get { return clipname_; }
			set { clipname_ = value; }
		}

		private bool loop_ = false;
		public bool Loop
		{
			get { return loop_; }
			set { loop_ = value; }
		}

		private Transition transition_ = new Transition();
		public Transition Transition
		{
			get { return transition_; }
		}

		#region IXmlSerializable Members
		public System.Xml.Schema.XmlSchema GetSchema()
		{
			throw new Exception("The method or operation is not implemented.");
		}

		public void ReadXml(System.Xml.XmlReader reader)
		{
			reader.MoveToContent();
			string clipname = reader["clipname"];
			if (!string.IsNullOrEmpty(clipname))
				Clipname = clipname;
			else
				Clipname = "";

			string loop = reader["loop"];
			bool bLoop = false;
			Boolean.TryParse(loop, out bLoop);
			Loop = bLoop;

			reader.ReadStartElement();
			if (reader.Name == "transition")
			{
				int duration = 0;

				string typeString = reader["type"];
				string durationString = reader["duration"];
				if (Int32.TryParse(durationString, out duration) && Enum.IsDefined(typeof(TransitionType), typeString.ToUpper()))
				{
					transition_ = new Transition((TransitionType)Enum.Parse(typeof(TransitionType), typeString.ToUpper()), duration);
				}
				else
					transition_ = new Transition();
			}
		}

		public void WriteXml(System.Xml.XmlWriter writer)
		{
			writer.WriteStartElement("item", Properties.Resources.CasparPlayoutSchemaURL);
			writer.WriteAttributeString("clipname", Clipname);
			writer.WriteAttributeString("loop", Loop.ToString());

			writer.WriteStartElement("transition");
			writer.WriteAttributeString("type", Transition.Type.ToString());
			writer.WriteAttributeString("duration", Transition.Duration.ToString());
			writer.WriteEndElement();
	
			writer.WriteEndElement();
		}
		#endregion
	}
}
