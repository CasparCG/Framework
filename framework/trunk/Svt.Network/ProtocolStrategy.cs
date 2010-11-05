using System;
using System.Collections.Generic;
using System.Text;

namespace Svt.Network
{
	public interface IProtocolStrategy
	{
		void ParseResponse(string data);

		System.Text.Encoding Encoding {
			get;
		}
		string Delimiter {
			get;
		}
	}
}
