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
package se.svt.caspar;

/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public abstract class AbstractEaseableRefreshable extends AbstractRefreshable implements Easeable {
	private Easing mEasing = Easing.easenone;
	private int mFrames = 0;
	private boolean mDefer = false;

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
}
