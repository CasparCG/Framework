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
package se.svt.caspar.amcp;

import javafx.beans.property.DoubleProperty;

import se.svt.caspar.Geometry;

/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public abstract class AmcpGeometry extends AmcpPosition implements Geometry {
	private final DoubleProperty mScaleX;
	private final DoubleProperty mScaleY;

	/**
	 * Constructor.
	 */
	public AmcpGeometry(AmcpLayer layer) {
		super(layer);
		mScaleX = new TouchingDouble();
		mScaleY = new TouchingDouble();
	}

	@Override
    protected void initialValues() {
	    super.initialValues();

	    mScaleX.set(1);
        mScaleY.set(1);
    }

	/** {@inheritDoc} */
	@Override
	public void modify(double x, double y, double scaleX, double scaleY) {
		boolean autoSubmit = autoSubmit();

		try {
			position(x, y);
			mScaleX.set(scaleX);
			mScaleY.set(scaleY);
		} finally {
			autoSubmit(autoSubmit);
		}

		touched();
	}

	/** {@inheritDoc} */
	@Override
	public void scale(double scaleX, double scaleY) {
		fetchIfStale();

		boolean autoSubmit = autoSubmit();

		try {
			mScaleX.set(scaleX);
			mScaleY.set(scaleY);
		} finally {
			autoSubmit(autoSubmit);
		}

		touched();
	}

	/** {@inheritDoc} */
	@Override
	public DoubleProperty scaleX() {
		return mScaleX;
	}

	/** {@inheritDoc} */
	@Override
	public DoubleProperty scaleY() {
		return mScaleY;
	}

    /** {@inheritDoc} */
    @Override
    protected void doSubmit() {
        layer().sendCommand("MIXER", getGeometryName()
                + " " + positionX().get() + " " + positionY().get()
                + " " + scaleX().get() + " " + scaleY().get()
                + AmcpUtils.getEasingSuffix(this)
                + (defer() ? " DEFER" : ""));
    }

    /** {@inheritDoc} */
    @Override
    protected void doFetch() {
        String reply = layer().sendCommandExpectSingle(
                "MIXER", getGeometryName());
        String[] parameters = reply.split(" ");

        positionX().set(Double.parseDouble(parameters[0]));
        positionY().set(Double.parseDouble(parameters[1]));
        mScaleX.set(Double.parseDouble(parameters[2]));
        mScaleY.set(Double.parseDouble(parameters[3]));
    }
}
