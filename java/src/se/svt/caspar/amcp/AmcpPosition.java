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

import se.svt.caspar.AbstractEaseableRefreshable;
import se.svt.caspar.Position;

/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public abstract class AmcpPosition extends AbstractEaseableRefreshable implements Position {
    private final AmcpLayer mLayer;
    private final DoubleProperty mPositionX;
    private final DoubleProperty mPositionY;

    /**
     * Constructor.
     * @param layer
     *
     */
    public AmcpPosition(AmcpLayer layer) {
        mLayer = layer;
        mPositionX = new TouchingDouble();
        mPositionY = new TouchingDouble();
    }

    @Override
    public AmcpLayer layer() {
    	return mLayer;
    }

    @Override
    protected void initialValues() {
    	mPositionX.set(0);
    	mPositionY.set(0);
    }

    /** {@inheritDoc} */
    @Override
    public void position(double x, double y) {
    	fetchIfStale();
    	boolean autoSubmit = autoSubmit();

    	try {
    	    mPositionX.unbind();
    		mPositionX.set(x);
    		mPositionY.unbind();
    		mPositionY.set(y);
    	} finally {
    		autoSubmit(autoSubmit);
    	}

    	touched();
    }

    /** {@inheritDoc} */
    @Override
    public DoubleProperty positionX() {
    	return mPositionX;
    }

    /** {@inheritDoc} */
    @Override
    public DoubleProperty positionY() {
    	return mPositionY;
    }

    protected abstract String getGeometryName();

    /** {@inheritDoc} */
    @Override
    protected void doSubmit() {
    	layer().sendCommand("MIXER", getGeometryName()
    			+ " " + positionX().get() + " " + positionY().get()
    			+ AmcpUtils.getEasingSuffix(this)
    			+ (defer() ? " DEFER" : ""));
    }

    /** {@inheritDoc} */
    @Override
    protected void doFetch() {
    	String reply = layer().sendCommandExpectSingle(
    			"MIXER", getGeometryName());
    	String[] parameters = reply.split(" ");

    	if (!mPositionX.isBound())
    	    mPositionX.set(Double.parseDouble(parameters[0]));

    	if (!mPositionY.isBound())
    	    mPositionY.set(Double.parseDouble(parameters[1]));
    }
}
