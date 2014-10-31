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

import javafx.beans.property.SimpleBooleanProperty;

import se.svt.caspar.Refreshable;

public class AdjustmentBoolean extends SimpleBooleanProperty implements Refreshable {
    private final boolean mDefaultValue;
    private boolean mAutoSubmit = true;
    private boolean mAutoFetch = true;
    private boolean mStale = true;
    private boolean mTouched = false;
	private final String mMixerProperty;
    private final AmcpLayer mLayer;

	public AdjustmentBoolean(AmcpLayer layer, boolean defaultValue, String mixerProperty) {
        mDefaultValue = defaultValue;
		mLayer = layer;
		mMixerProperty = mixerProperty;
	}

	private boolean doFetch() {
		return Integer.parseInt(
				mLayer.sendCommandExpectSingle("MIXER", mMixerProperty)) == 1;
	}

	/** {@inheritDoc} */
	private void doSubmit(boolean value) {
		mLayer.sendCommand("MIXER", mMixerProperty + " " + (value ? "1" : "0"));
	}

    /** {@inheritDoc} */
    @Override
    public final void autoSubmit(boolean on) {
        mAutoSubmit = on;
    }

    /** {@inheritDoc} */
    @Override
    public final boolean autoSubmit() {
        return mAutoSubmit;
    }

    /** {@inheritDoc} */
    @Override
    public final void submit() {
        if (mTouched) {
            doSubmit(get());
            mTouched = false;
        }
    }

    /** {@inheritDoc} */
    @Override
    protected void invalidated() {
        mTouched = true;

        if (mAutoSubmit) {
            submit();
        }
    }

    /** {@inheritDoc} */
    @Override
    public final void setStale() {
        mStale = true;

        if (mAutoFetch) {
            fetch();
        }
    }

    /** {@inheritDoc} */
    @Override
    public boolean stale() {
        return mStale;
    }

    /** {@inheritDoc} */
    @Override
    public void autoFetch(boolean on) {
        mAutoFetch = on;
    }

    /** {@inheritDoc} */
    @Override
    public boolean autoFetch() {
        return mAutoFetch;
    }

    /** {@inheritDoc} */
    @Override
    public final void fetch() {
        set(doFetch());
        mStale = false;
    }

    /** {@inheritDoc} */
    @Override
    public boolean get() {
        fetchIfStale();

        return super.get();
    }

    private void fetchIfStale() {
        if (mStale) {
            fetch();
        }
    }

    /** {@inheritDoc} */
    @Override
    public final void reset() {
        set(mDefaultValue);
    }

    /** {@inheritDoc} */
    @Override
    public final void wasReset() {
        boolean autoSubmit = mAutoSubmit;
        mAutoSubmit = false;

        try {
            set(mDefaultValue);
        } finally {
            mAutoSubmit = autoSubmit;
        }
    }
}