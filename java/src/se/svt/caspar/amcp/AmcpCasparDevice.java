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
package se.svt.caspar.amcp;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import se.svt.caspar.CasparDevice;
import se.svt.caspar.Channel;
import se.svt.caspar.GL;

/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public class AmcpCasparDevice implements CasparDevice {
	private final Map<Integer, Channel> mChannels = new HashMap<>();
	private final Socket mSocket;
	private final TelnetLineReader mReader;
	private final BufferedWriter mWriter;
	private final GL mGL;

	/**
	 * Constructor.
	 */
	public AmcpCasparDevice(String host, int port) {
		try {
			mSocket = new Socket(host, port);			mSocket.setKeepAlive(true);
			mReader = new TelnetLineReader(new InputStreamReader(
					mSocket.getInputStream(), "UTF-8"));
			mWriter = new BufferedWriter(new OutputStreamWriter(
					mSocket.getOutputStream(), "UTF-8"));
			mGL = new AmcpGL(this);
		} catch (UnknownHostException e) {
			throw new RuntimeException(e);
		} catch (IOException e) {
			throw new RuntimeException(e);
		}

		/*for (String line : sendCommand("INFO")) {
			int channelId = Integer.parseInt(line.split(" ")[0]);
			mChannels.put(channelId, new AmcpChannel(this, channelId));
		}*/

		mChannels.put(1, new AmcpChannel(this, 1));
        mChannels.put(2, new AmcpChannel(this, 2));
	}

	@Override
	public Channel channel(int channelId) {
		Channel channel = mChannels.get(channelId);

		if (channel == null) {
			throw new IllegalArgumentException(
					"channel " + channelId + " does not exist");
		}

		return channel;
	}

	/** {@inheritDoc} */
	@Override
	public List<Channel> channels() {
		return new ArrayList<>(mChannels.values());
	}

	/** {@inheritDoc} */
	@Override
	public List<String> mediaFiles() {
	    return sendCommand("cls")
	            .stream()
	            .map(line -> line.split(" ")[0].replace('\\', '/'))
	            .collect(Collectors.toList());
	}

	/** {@inheritDoc} */
	@Override
	public String dataRetrieve(String dataFile) {
		return sendCommand("DATA RETRIEVE \"" + dataFile.replace("\\", "\\\\") + "\"").get(0);
	}

	/** {@inheritDoc} */
	@Override
	public List<String> thumbnailRetrieve(String thumbnailFile) {
		return sendCommand("THUMBNAIL RETRIEVE \"" + thumbnailFile.replace("\\", "\\\\") + "\"");
	}

	/** {@inheritDoc} */
	@Override
	public GL gl() {
	    return mGL;
	}

	public List<String> sendCommand(String singleLine) {
		return sendCommand(Arrays.asList(singleLine));
	}

	public String sendCommandExpectSingle(String singleLine) {
		List<String> reply = sendCommand(singleLine);

		if (reply.isEmpty()) {
			throw new RuntimeException("Expected 1 line in response to " + singleLine + " but got nothing");
		}

		if (reply.size() > 1) {
			throw new RuntimeException("Expected 1 line in response to " + singleLine + " but got more: " + reply);
		}

		return reply.get(0);
	}

	public List<String> sendCommand(List<String> lines) {
		String reply;

		try {
			mWriter.append(lines.get(0)).append("\r\n").flush();

			reply = mReader.readLine();
		} catch (IOException e) {
			throw new RuntimeException(e);
		}

		if (reply == null) {
			throw new RuntimeException("Unexpected end of transmission");
		}

		String[] tokens = reply.split(" ");
		int returnCode = Integer.parseInt(tokens[0]);

		switch (returnCode) {
		case 202:
			return Collections.emptyList();
		case 201:
			try {
				return Arrays.asList(mReader.readLine());
			} catch (IOException e) {
				throw new RuntimeException(e);
			}
		case 200:
			List<String> result = new ArrayList<>();

			try {
				String line;

				while ((line = mReader.readLine()) != null) {
					if ("".equals(line))
						break;

					result.add(line);
				}
			} catch (IOException e) {
				throw new RuntimeException(e);
			}

			return result;
		default:
			throw new RuntimeException(reply);
		}
	}

	@Override
	public void close() {
		try {
			mSocket.close();
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}
}
