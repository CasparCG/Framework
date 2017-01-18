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

import javafx.beans.property.DoubleProperty;

/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public class PositionView extends AbstractDelegatingPosition {
	private final PointView mPointView;

	public PositionView(
	        Position backingPosition, double xScale, double yScale) {
		super(backingPosition);

		mPointView = new PointView(backingPosition, xScale, yScale);
	}

	@Override
	public void position(double x, double y) {
	    mPointView.position(x, y);
	}

	@Override
	public DoubleProperty positionX() {
		return mPointView.positionX();
	}

	@Override
	public DoubleProperty positionY() {
        return mPointView.positionY();
	}
}
