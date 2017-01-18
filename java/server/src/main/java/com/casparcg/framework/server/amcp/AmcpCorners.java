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
package com.casparcg.framework.server.amcp;

import com.casparcg.framework.server.AbstractEaseableRefreshable;
import com.casparcg.framework.server.Corners;
import com.casparcg.framework.server.Point;

/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public abstract class AmcpCorners extends AbstractEaseableRefreshable implements Corners {
    private final AmcpLayer mLayer;
    private final PointImpl mUpperLeft;
    private final PointImpl mUpperRight;
    private final PointImpl mLowerRight;
    private final PointImpl mLowerLeft;

    /**
     * Constructor.
     * @param layer
     *
     */
    public AmcpCorners(AmcpLayer layer) {
        mLayer = layer;
        mUpperLeft = new PointImpl(new TouchingDouble(), new TouchingDouble());
        mUpperRight = new PointImpl(new TouchingDouble(), new TouchingDouble());
        mLowerRight = new PointImpl(new TouchingDouble(), new TouchingDouble());
        mLowerLeft = new PointImpl(new TouchingDouble(), new TouchingDouble());
    }

    @Override
    public AmcpLayer layer() {
    	return mLayer;
    }

    @Override
    protected void initialValues() {
        mUpperLeft.position(0, 0);
        mUpperRight.position(1, 0);
        mLowerRight.position(1, 1);
        mLowerLeft.position(0, 1);
    }

    /** {@inheritDoc} */
    @Override
    public void modify(
            double upperLeftX, double upperLeftY,
            double upperRightX, double upperRightY,
            double lowerRightX, double lowerRightY,
            double lowerLeftX, double lowerLeftY) {
        fetchIfStale();
        boolean autoSubmit = autoSubmit();

        try {
            mUpperLeft.unbind();
            mUpperLeft.position(upperLeftX, upperLeftY);
            mUpperRight.unbind();
            mUpperRight.position(upperRightX, upperRightY);
            mLowerRight.unbind();
            mLowerRight.position(lowerRightX, lowerRightY);
            mLowerLeft.unbind();
            mLowerLeft.position(lowerLeftX, lowerLeftY);
        } finally {
            autoSubmit(autoSubmit);
        }

        touched();
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

    protected abstract String getCornersName();

    /** {@inheritDoc} */
    @Override
    protected void doSubmit() {
    	layer().sendCommand("MIXER", getCornersName()
    			+ " " + upperLeft()
                + " " + upperRight()
                + " " + lowerRight()
                + " " + lowerLeft()
    			+ AmcpUtils.getEasingSuffix(this)
    			+ (defer() ? " DEFER" : ""));
    }

    /** {@inheritDoc} */
    @Override
    protected void doFetch() {
    	String reply = layer().sendCommandExpectSingle(
    			"MIXER", getCornersName());
    	String[] parameters = reply.split(" ");

    	mUpperLeft.position(Double.parseDouble(parameters[0]), Double.parseDouble(parameters[1]));
        mUpperRight.position(Double.parseDouble(parameters[2]), Double.parseDouble(parameters[3]));
        mLowerRight.position(Double.parseDouble(parameters[4]), Double.parseDouble(parameters[5]));
        mLowerLeft.position(Double.parseDouble(parameters[6]), Double.parseDouble(parameters[7]));
    }
}
