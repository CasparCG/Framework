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

import se.svt.caspar.Adjustments;
import se.svt.caspar.EaseableDouble;

/**
 * TODO document
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public class AmcpAdjustments implements Adjustments {
	private final AmcpLayer mLayer;
	private final EaseableDouble mOpacity;
	private final EaseableDouble mBrightness;
	private final EaseableDouble mContrast;
	private final EaseableDouble mSaturation;
	private final EaseableDouble mVolume;

	/**
	 * Constructor.
	 *
	 */
	public AmcpAdjustments(AmcpLayer layer) {
		mLayer = layer;
		mOpacity = new AdjustmentDouble(layer, 1.0, "OPACITY");
		mBrightness = new AdjustmentDouble(layer, 1.0, "BRIGHTNESS");
		mContrast = new AdjustmentDouble(layer, 1.0, "CONTRAST");
		mSaturation = new AdjustmentDouble(layer, 1.0, "SATURATION");
		mVolume = new AdjustmentDouble(layer, 1.0, "VOLUME");
	}

	/** {@inheritDoc} */
	@Override
	public AmcpLayer layer() {
		return mLayer;
	}

	/** {@inheritDoc} */
	@Override
	public void setStale() {
		mOpacity.setStale();
		mBrightness.setStale();
		mContrast.setStale();
		mSaturation.setStale();
		mVolume.setStale();
	}

	/** {@inheritDoc} */
	@Override
	public void reset() {
		mOpacity.reset();
		mBrightness.reset();
		mContrast.reset();
		mSaturation.reset();
		mVolume.reset();
	}

	/** {@inheritDoc} */
	@Override
	public EaseableDouble opacity() {
		return mOpacity;
	}

	/** {@inheritDoc} */
	@Override
	public EaseableDouble brightness() {
		return mBrightness;
	}

	/** {@inheritDoc} */
	@Override
	public EaseableDouble contrast() {
		return mContrast;
	}

	/** {@inheritDoc} */
	@Override
	public EaseableDouble saturation() {
		return mSaturation;
	}

	/** {@inheritDoc} */
	@Override
	public EaseableDouble volume() {
		return mVolume;
	}
}
