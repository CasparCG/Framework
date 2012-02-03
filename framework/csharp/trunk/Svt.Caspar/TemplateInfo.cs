using System;
using System.Collections.Generic;
using System.Text;

namespace Svt.Caspar
{
	public class TemplateInfo
	{
		internal TemplateInfo(string folder, string name, Int64 size, DateTime updated)
		{
			Folder = folder;
			Name = name;
			Size = size;
			LastUpdated = updated;
		}

		private string folder_;
		public string Folder
		{
			get { return folder_; }
			internal set { folder_ = value; }
		}
		private string name_;
		public string Name
		{
			get { return name_; }
			internal set { name_ = value; }
		}
		public string FullName { get { return (Folder.Length > 0) ? (Folder + "/" + Name) : (Name); } }

		private Int64 size_;
		public Int64 Size
		{
			get { return size_; }
			internal set { size_ = value; }
		}

		private DateTime updated_;
		public DateTime LastUpdated
		{
			get { return updated_; }
			internal set { updated_ = value; }
		}

		public override string ToString()
		{
			return Name;
		}
	}
}
