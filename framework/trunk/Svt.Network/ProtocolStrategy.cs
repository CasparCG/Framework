using System;
using System.Collections.Generic;
using System.Text;

namespace Svt.Network
{
	public interface IProtocolStrategy
	{
        void Parse(string str);
        void Parse(byte[] data, int length);

		System.Text.Encoding Encoding {
			get;
		}
		string Delimiter {
			get;
		}
	}
}
