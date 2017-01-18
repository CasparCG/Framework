/*
* Copyright (c) 2013 Sveriges Television AB <info@casparcg.com>
*
* This file is part of CasparCG (www.casparcg.com).
*
* CasparCG is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* CasparCG is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with CasparCG. If not, see <http://www.gnu.org/licenses/>.
*
* Author: Helge Norberg, helge.norberg@svt.se
*/
package com.casparcg.framework.server.amcp;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.Reader;

/**
 * Like {@link BufferedReader} but only considers CRLF as a line break.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public class TelnetLineReader extends BufferedReader {
	/**
	 * Constructor.
	 *
	 * @param in The reader to wrap.
	 */
	public TelnetLineReader(Reader in) {
		super(in);
	}

	/** {@inheritDoc} */
	@Override
	public String readLine() throws IOException {
		int ch;
		StringBuilder sb = new StringBuilder();
		boolean previousWasCr = false;

		while ((ch = read()) != -1) {
			boolean isLf = ch == '\n';

			if (previousWasCr && isLf)
				return sb.toString();

			if (previousWasCr && !isLf) {
				sb.append('\r');
				previousWasCr = false;
			}

			if (ch == '\r')
				previousWasCr = true;
			else
				sb.append((char) ch);
		}

		return sb.length() == 0 ? null : sb.toString();
	}
}
