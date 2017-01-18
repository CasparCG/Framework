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
package com.casparcg.framework.server;

/**
 * The available video modes.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public enum VideoMode {
	PAL        ("PAL",        720,  576, 25,    1,    true),
	NTSC       ("NTSC",       720,  480, 30000, 1001, true),
	x720p5000  ("720p5000",  1280,  720, 50,    1,    false),
	x720p5994  ("720p5994",  1280,  720, 60000, 1001, false),
	x1080i5000 ("1080i5000", 1920, 1080, 25,    1,    true),
	x1080p5000 ("1080p5000", 1920, 1080, 50,    1,    false),
    x1080p2500 ("1080p2500", 1920, 1080, 25,    1,    false),
	x1080i5994 ("1080i5994", 1920, 1080, 30000, 1001, true),
	x1080p5994 ("1080p5994", 1920, 1080, 60000, 1001, false);

	private final String mName;
	private final int mWidth;
	private final int mHeight;
	private final int mScale;
	private final int mDuration;
	private final boolean mInterlaced;

	private VideoMode(
			String name,
			int width,
			int height,
			int scale,
			int duration,
			boolean interlaced) {
		mName = name;
		mWidth = width;
		mHeight = height;
		mScale = scale;
		mDuration = duration;
		mInterlaced = interlaced;
	}

	public static VideoMode forName(String name) {
		try {
			return valueOf(name);
		} catch (IllegalArgumentException e) {
			return valueOf("x" + name);
		}
	}

	public String getName() {
		return mName;
	}

	public int getWidth() {
		return mWidth;
	}

	public int getHeight() {
		return mHeight;
	}

	public double getFps() {
		return (double) mScale / (double) mDuration;
	}

	public double getMillisecondsPerFrame() {
		return 1000 / getFps();
	}

	public boolean isInterlaced() {
		return mInterlaced;
	}
}
