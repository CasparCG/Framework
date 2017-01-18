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
package com.casparcg.framework.server.producer;

import com.casparcg.framework.server.Call;
import com.casparcg.framework.server.CallWithReturn;
import com.casparcg.framework.server.Producer;


/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public class Video implements Producer {
	private final String mName;
	private boolean mLoop;
	private int mSeek = -1;
	private int mLength = -1;

	public Video(String name) {
		mName = name;
	}

	public Video loop() {
		mLoop = true;

		return this;
	}

	public Video loop(boolean shouldLoop) {
		mLoop = shouldLoop;

		return this;
	}

	public Video seek(int startFrame) {
		mSeek = startFrame;

		return this;
	}

	public Video length(int length) {
		mLength = length;

		return this;
	}

	@Override
	public String getParameters() {
		return "\"" + mName + "\""
				+ (mLoop ? " LOOP" : "")
				+ (mSeek >= 0 ? " SEEK " + mSeek : "")
				+ (mLength >= 0 ? " LENGTH " + mLength : "");
	}

	public static class Seek implements Call {
		private final int mFrameNumber;

		public Seek(int frameNumber) {
			mFrameNumber = frameNumber;
		}

		/** {@inheritDoc} */
		@Override
		public String getParameters() {
			return "SEEK " + mFrameNumber;
		}
	}

	public static class Loop implements CallWithReturn<Boolean> {
		private final Boolean mLoop;

		public Loop(boolean loop) {
			mLoop = loop;
		}

		public Loop() {
			mLoop = null;
		}

		/** {@inheritDoc} */
		@Override
		public String getParameters() {
			if (mLoop == null)
				return "LOOP";
			else
				return "LOOP " + (mLoop ? "1" : "0");
		}

		/** {@inheritDoc} */
		@Override
		public Boolean parseResult(String result) {
			return "1".equals(result);
		}

	}
}
