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
package com.casparcg.framework.server;

import javafx.beans.property.SimpleDoubleProperty;

/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public abstract class EaseableDouble extends SimpleDoubleProperty implements Easeable, Refreshable {
	private final double mDefaultValue;
	private boolean mAutoSubmit = true;
	private boolean mAutoFetch = true;
	private boolean mStale = true;
	private boolean mTouched = false;
	private Easing mEasing = Easing.easenone;
	private int mFrames = 0;
	private boolean mDefer = false;

	/**
	 * Constructor.
	 */
	public EaseableDouble(double defaultValue) {
		mDefaultValue = defaultValue;
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
	public double get() {
		fetchIfStale();

		return super.get();
	}

	protected final void fetchIfStale() {
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

	/** {@inheritDoc} */
	@Override
	public void easing(Easing easing, int frames) {
		mEasing = easing;
		mFrames = frames;
	}

	/** {@inheritDoc} */
	@Override
	public void resetEasing() {
		mEasing = Easing.easenone;
		mFrames = 0;
	}

	/** {@inheritDoc} */
	@Override
	public Easing easing() {
		return mEasing;
	}

	/** {@inheritDoc} */
	@Override
	public int frames() {
		return mFrames;
	}

	/** {@inheritDoc} */
	@Override
	public void defer(boolean on) {
		mDefer = on;
	}

	/** {@inheritDoc} */
	@Override
	public boolean defer() {
		return mDefer;
	}

	protected abstract void doSubmit(double value);
	protected abstract double doFetch();
}
