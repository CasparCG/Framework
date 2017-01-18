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

import com.casparcg.framework.server.amcp.BidirectionalEquationBinder;

import javafx.beans.property.DoubleProperty;
import javafx.beans.property.SimpleDoubleProperty;

/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public class PointView implements Point {
    private final Point mDelegate;
	private final double mXScale;
	private final double mYScale;
	private final DoubleProperty mPositionX = new SimpleDoubleProperty();
	private final DoubleProperty mPositionY = new SimpleDoubleProperty();

	public PointView(Point backingPoint, double xScale, double yScale) {
		mDelegate = backingPoint;
		mXScale = xScale;
		mYScale = yScale;

		BidirectionalEquationBinder.bidirectionalBind(
				mPositionX,
				delegate().positionX(),
				mPositionX.divide(mXScale),
				delegate().positionX().multiply(mXScale));
		BidirectionalEquationBinder.bidirectionalBind(
				mPositionY,
				delegate().positionY(),
				mPositionY.divide(mYScale),
				delegate().positionY().multiply(mYScale));
	}

	protected Point delegate() {
	    return mDelegate;
	}

	private double scaledX(double x) {
		return x / mXScale;
	}

	private double scaledY(double y) {
		return y / mYScale;
	}

	@Override
	public void position(double x, double y) {
		delegate().position(scaledX(x), scaledY(y));
	}

	@Override
	public DoubleProperty positionX() {
		return mPositionX;
	}

	@Override
	public DoubleProperty positionY() {
		return mPositionY;
	}
}
