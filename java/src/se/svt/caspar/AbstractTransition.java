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


/**
 * Represents a CasparCG transition.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public abstract class AbstractTransition<T extends AbstractTransition<?>> implements Transition {
    private int mFrames = 0;
    private Easing mEasing = Easing.linear;

    /** {@inheritDoc} */
    @Override
    public abstract String getParameters();

    protected String getDurationAndEasingParameters() {
        return mFrames + " " + mEasing;
    }

    /** {@inheritDoc} */
    public T frames(int frames) {
        mFrames = frames;

        return self();
    }

    /** {@inheritDoc} */
    public T easing(Easing easing) {
        mEasing = easing;

        return self();
    }

    private T self() {
        @SuppressWarnings("unchecked")
        T casted = (T) this;
        return casted;
    }
}
