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

import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

import com.casparcg.framework.server.CasparDevice;
import com.casparcg.framework.server.Channel;
import com.casparcg.framework.server.Layer;
import com.casparcg.framework.server.VideoMode;

/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public class AmcpChannel implements Channel {
	private final AmcpCasparDevice mDevice;
	private final int mChannelId;
	private final ConcurrentMap<Integer, AmcpLayer> mLayers =
			new ConcurrentHashMap<Integer, AmcpLayer>();

	/**
	 * Constructor.
	 */
	public AmcpChannel(AmcpCasparDevice device, int channelId) {
		mDevice = device;
		mChannelId = channelId;
	}

	/** {@inheritDoc} */
	@Override
	public int channelId() {
		return mChannelId;
	}

	public AmcpCasparDevice getDevice() {
		return mDevice;
	}

	@Override
	public CasparDevice device() {
		return mDevice;
	}

	@Override
	public VideoMode videoMode() {
		List<String> lines = mDevice.sendCommand("INFO");

		for (String line : lines) {
			String[] tokens = line.split(" ");

			if (tokens.length != 3)
				continue;

			int chId = Integer.parseInt(tokens[0]);
			String mode = tokens[1];

			if (chId == mChannelId) {
				return VideoMode.forName(mode);
			}
		}

		throw new RuntimeException("Channel not found on device");
	}

	public int getChannelId() {
		return mChannelId;
	}

	@Override
	public Layer layer(int layerId) {
		AmcpLayer layer = mLayers.get(layerId);

		if (layer == null) {
			layer = new AmcpLayer(this, layerId);
			AmcpLayer old = mLayers.putIfAbsent(layerId, layer);

			if (old != null) {
				layer = old;
			}
		}

		return layer;
	}

	/** {@inheritDoc} */
	@Override
	public Layer defaultCgLayer() {
		return layer(9999);
	}

	@Override
	public void clear() {
		mDevice.sendCommand("CLEAR " + mChannelId);
	}

	/** {@inheritDoc} */
	@Override
	public void clearMixer() {
		mDevice.sendCommand("MIXER " + mChannelId + " CLEAR");

		for (AmcpLayer layer : mLayers.values()) {
			layer.mixerCleared();
		}
	}

	/** {@inheritDoc} */
	@Override
	public void commitDeffered() {
		mDevice.sendCommand("MIXER " + mChannelId + " COMMIT");
	}
}
