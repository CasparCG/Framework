/*
* Copyright (c) 2011 Sveriges Television AB <info@casparcg.com>
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
* Author: Helge Norberg
*/
package se.svt.caspar.amcp;

import se.svt.caspar.EaseableDouble;

class AdjustmentDouble extends EaseableDouble {
	private final String mMixerProperty;
    private final AmcpLayer mLayer;

	public AdjustmentDouble(AmcpLayer layer, double defaultValue, String mixerProperty) {
		super(defaultValue);

		mLayer = layer;
		mMixerProperty = mixerProperty;
	}

	@Override
	protected double doFetch() {
		return Double.parseDouble(
				mLayer.sendCommandExpectSingle("MIXER", mMixerProperty));
	}

	/** {@inheritDoc} */
	@Override
	protected void doSubmit(double value) {
		mLayer.sendCommand("MIXER", mMixerProperty + " " + value
				+ AmcpUtils.getEasingSuffix(this)
				+ (defer() ? " DEFER" : ""));
	}
}