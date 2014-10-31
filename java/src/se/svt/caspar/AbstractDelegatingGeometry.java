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
package se.svt.caspar;

import javafx.beans.property.DoubleProperty;

/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public class AbstractDelegatingGeometry extends AbstractDelegatingPosition implements Geometry {
	private final Geometry mDelegate;

	/**
	 * Constructor.
	 */
	public AbstractDelegatingGeometry(Geometry delegate) {
	    super(delegate);
		mDelegate = delegate;
	}

	@Override
    protected Geometry delegate() {
		return mDelegate;
	}

	/** {@inheritDoc} */
	@Override
	public void modify(double x, double y, double scaleX, double scaleY) {
		mDelegate.modify(x, y, scaleX, scaleY);
	}

	/** {@inheritDoc} */
	@Override
	public void scale(double scaleX, double scaleY) {
		mDelegate.scale(scaleX, scaleY);
	}

	/** {@inheritDoc} */
	@Override
	public DoubleProperty scaleX() {
		return mDelegate.scaleX();
	}

	/** {@inheritDoc} */
	@Override
	public DoubleProperty scaleY() {
		return mDelegate.scaleY();
	}
}
