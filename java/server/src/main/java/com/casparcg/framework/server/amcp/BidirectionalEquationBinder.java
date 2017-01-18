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

import javafx.beans.binding.Binding;
import javafx.beans.property.Property;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;

/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public class BidirectionalEquationBinder {
	private BidirectionalEquationBinder() {
	}

	public static <T> void bidirectionalBind(
			final Property<T> lhs,
			final Property<T> rhs,
			final Binding<T> lhsToRhs,
			final Binding<T> rhsToLhs) {
		lhs.addListener(new ChangeListener<T>() {
			@Override
			public void changed(
					ObservableValue<? extends T> value,
					T oldVal,
					T newVal) {
				rhs.setValue(lhsToRhs.getValue());
			}
		});
		rhs.addListener(new ChangeListener<T>() {
			@Override
			public void changed(
					ObservableValue<? extends T> value,
					T oldVal,
					T newVal) {
				lhs.setValue(rhsToLhs.getValue());
			}
		});
		lhs.setValue(rhsToLhs.getValue());
	}
}
