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

import com.casparcg.framework.server.ChromaKey;

import javafx.beans.Observable;
import javafx.beans.property.BooleanProperty;
import javafx.beans.property.DoubleProperty;
import javafx.beans.property.SimpleBooleanProperty;
import javafx.beans.property.SimpleDoubleProperty;

/**
 * TODO document
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public class AmcpChromaKey implements ChromaKey {
	private final AmcpLayer mLayer;
	private final BooleanProperty mEnable;
	private final DoubleProperty mTargetHue;
    private final DoubleProperty mMinSaturation;
    private final DoubleProperty mMinBrightness;
    private final DoubleProperty mHueWidth;
    private final DoubleProperty mSoftness;
    private final DoubleProperty mSpillSuppress;
    private final DoubleProperty mSpillSuppressSaturation;
    private final BooleanProperty mShowMask;

	/**
	 * Constructor.
	 *
	 */
	public AmcpChromaKey(AmcpLayer layer) {
		mLayer = layer;
		mEnable = new SimpleBooleanProperty(false);
		mTargetHue = new SimpleDoubleProperty(120);
        mMinSaturation = new SimpleDoubleProperty(0);
        mMinBrightness = new SimpleDoubleProperty(0);
		mHueWidth = new SimpleDoubleProperty(0.1);
        mSoftness = new SimpleDoubleProperty(0.1);
        mSpillSuppress = new SimpleDoubleProperty(0);
        mSpillSuppressSaturation = new SimpleDoubleProperty(1);
        mShowMask = new SimpleBooleanProperty(false);

        mEnable.addListener(this::send);
		mTargetHue.addListener(this::send);
        mMinSaturation.addListener(this::send);
        mMinBrightness.addListener(this::send);
        mHueWidth.addListener(this::send);
        mSoftness.addListener(this::send);
        mSpillSuppress.addListener(this::send);
        mSpillSuppressSaturation.addListener(this::send);
        mShowMask.addListener(this::send);
	}

	/** {@inheritDoc} */
	@Override
	public AmcpLayer layer() {
		return mLayer;
	}

	/** {@inheritDoc} */
	@Override
	public void reset() {
	    mEnable.set(false);
		mTargetHue.set(120);
        mMinSaturation.set(0);
        mMinBrightness.set(0);
        mHueWidth.set(0.1);
        mSoftness.set(0.1);
        mSpillSuppress.set(0);
        mSpillSuppressSaturation.set(1);
        mShowMask.set(false);
	}

	/** {@inheritDoc} */
	@Override
	public BooleanProperty enable() {
	    return mEnable;
	}

	/** {@inheritDoc} */
	@Override
	public DoubleProperty targetHue() {
	    return mTargetHue;
	}

	/** {@inheritDoc} */
	@Override
	public DoubleProperty minSaturation() {
	    return mMinSaturation;
	}

	/** {@inheritDoc} */
	@Override
	public DoubleProperty minBrightness() {
	    return mMinBrightness;
	}

	/** {@inheritDoc} */
	@Override
	public DoubleProperty hueWidth() {
	    return mHueWidth;
	}

	/** {@inheritDoc} */
	@Override
	public DoubleProperty softness() {
	    return mSoftness;
	}

	/** {@inheritDoc} */
	@Override
	public DoubleProperty spillSuppress() {
	    return mSpillSuppress;
	}

	/** {@inheritDoc} */
	@Override
	public DoubleProperty spillSuppressSaturation() {
	    return mSpillSuppressSaturation;
	}

	/** {@inheritDoc} */
	@Override
	public BooleanProperty showMask() {
	    return mShowMask;
	}

	private void send(Observable o) {
	    if (mEnable.get()) {
	        mLayer.executeCustomCommand("MIXER",
	                "CHROMA 1"
	                + " " + mTargetHue.get()
	                + " " + mHueWidth.get()
	                + " " + mMinSaturation.get()
	                + " " + mMinBrightness.get()
	                + " " + mSoftness.get()
	                + " " + mSpillSuppress.get()
	                + " " + mSpillSuppressSaturation.get()
	                + " " + (mShowMask.get() ? "1" : "0"));
	    } else {
            mLayer.executeCustomCommand("MIXER", "CHROMA 0");
	    }
	}
}
