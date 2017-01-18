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
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public class CornersView extends AbstractDelegatingCorners {
	private final Point mUpperLeft;
    private final Point mUpperRight;
    private final Point mLowerRight;
    private final Point mLowerLeft;
    private final double mXScale;
    private final double mYScale;

	public CornersView(
			Corners backingCorners, double xScale, double yScale) {
		super(backingCorners);

        mXScale = xScale;
        mYScale = yScale;

		mUpperLeft = new PointView(backingCorners.upperLeft(), xScale, yScale);
        mUpperRight = new PointView(backingCorners.upperRight(), xScale, yScale);
        mLowerRight = new PointView(backingCorners.lowerRight(), xScale, yScale);
        mLowerLeft = new PointView(backingCorners.lowerLeft(), xScale, yScale);
	}

    private double scaledX(double x) {
        return x / mXScale;
    }

    private double scaledY(double y) {
        return y / mYScale;
    }

	/** {@inheritDoc} */
	@Override
	public void modify(
	        double upperLeftX, double upperLeftY,
	        double upperRightX, double upperRightY,
	        double lowerRightX, double lowerRightY,
	        double lowerLeftX, double lowerLeftY) {
	    delegate().modify(
	            scaledX(upperLeftX), scaledY(upperLeftY),
	            scaledX(upperRightX), scaledY(upperRightY),
	            scaledX(lowerRightX), scaledY(lowerRightY),
	            scaledX(lowerLeftX), scaledY(lowerLeftY));
	}

	/** {@inheritDoc} */
	@Override
	public Point upperLeft() {
	    return mUpperLeft;
	}

	/** {@inheritDoc} */
	@Override
	public Point upperRight() {
        return mUpperRight;
	}

	/** {@inheritDoc} */
	@Override
	public Point lowerRight() {
        return mLowerRight;
	}

	/** {@inheritDoc} */
	@Override
	public Point lowerLeft() {
        return mLowerLeft;
	}
}
