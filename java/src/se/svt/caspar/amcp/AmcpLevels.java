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
import se.svt.caspar.Levels;

/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public class AmcpLevels extends AbstractEaseableRefreshable implements Levels {
	private final AmcpLayer mLayer;
	private final DoubleProperty mMinInput;
	private final DoubleProperty mMaxInput;
	private final DoubleProperty mGamma;
	private final DoubleProperty mMinOutput;
	private final DoubleProperty mMaxOutput;

	/**
	 * Constructor.
	 */
	public AmcpLevels(AmcpLayer layer) {
		mLayer = layer;
		mMinInput = new TouchingDouble();
		mMaxInput = new TouchingDouble();
		mGamma = new TouchingDouble();
		mMinOutput = new TouchingDouble();
		mMaxOutput = new TouchingDouble();
	}

	/** {@inheritDoc} */
	@Override
	public AmcpLayer layer() {
		return mLayer;
	}

	/** {@inheritDoc} */
	@Override
	public DoubleProperty minInput() {
		return mMinInput;
	}

	/** {@inheritDoc} */
	@Override
	public DoubleProperty maxInput() {
		return mMaxInput;
	}

	/** {@inheritDoc} */
	@Override
	public DoubleProperty gamma() {
		return mGamma;
	}

	/** {@inheritDoc} */
	@Override
	public DoubleProperty minOutput() {
		return mMinOutput;
	}

	/** {@inheritDoc} */
	@Override
	public DoubleProperty maxOutput() {
		return mMaxOutput;
	}

	/** {@inheritDoc} */
	@Override
	protected void initialValues() {
		mMinInput.set(0);
		mMaxInput.set(1);
		mGamma.set(1);
		mMinOutput.set(0);
		mMaxOutput.set(1);
	}

	/** {@inheritDoc} */
	@Override
	protected void doFetch() {
		String reply = layer().sendCommandExpectSingle(
				"MIXER", "LEVELS");
		String[] parameters = reply.split(" ");

		mMinInput.set(Double.parseDouble(parameters[0]));
		mMaxInput.set(Double.parseDouble(parameters[1]));
		mGamma.set(Double.parseDouble(parameters[2]));
		mMinOutput.set(Double.parseDouble(parameters[3]));
		mMaxOutput.set(Double.parseDouble(parameters[4]));
	}

	/** {@inheritDoc} */
	@Override
	protected void doSubmit() {
		mLayer.sendCommand("MIXER", "LEVELS "
				+ mMinInput.get() + " "
				+ mMaxInput.get() + " "
				+ mGamma.get() + " "
				+ mMinOutput.get() + " "
				+ mMaxOutput.get()
				+ AmcpUtils.getEasingSuffix(this)
				+ (defer() ? " DEFER" : ""));
	}
}
