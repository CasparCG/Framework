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

import javafx.beans.property.DoubleProperty;

import se.svt.caspar.Point;

/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public class PointImpl implements Point {
    private final DoubleProperty mX;
    private final DoubleProperty mY;

    /**
     * Constructor.
     *
     * @param x
     * @param y
     */
    public PointImpl(DoubleProperty x, DoubleProperty y) {
        mX = x;
        mY = y;
    }

    public void unbind() {
        mX.unbind();
        mY.unbind();
    }

    /** {@inheritDoc} */
    @Override
    public void position(double x, double y) {
        if (!mX.isBound())
            mX.set(x);

        if (!mY.isBound())
            mY.set(y);
    }

    /** {@inheritDoc} */
    @Override
    public DoubleProperty positionX() {
        return mX;
    }

    /** {@inheritDoc} */
    @Override
    public DoubleProperty positionY() {
        return mY;
    }

    /** {@inheritDoc} */
    @Override
    public String toString() {
        return mX.get() + " " + mY.get();
    }
}
