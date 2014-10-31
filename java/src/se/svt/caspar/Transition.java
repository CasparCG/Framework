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

import se.svt.caspar.transition.CutTransition;
import se.svt.caspar.transition.MixTransition;
import se.svt.caspar.transition.PushTransition;
import se.svt.caspar.transition.SlideTransition;
import se.svt.caspar.transition.WipeTransition;

/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public interface Transition {
    /**
     * @return The parameters of the transition.
     */
    String getParameters();

    public static CutTransition cut() {
        return new CutTransition();
    }

    public static MixTransition mix() {
        return new MixTransition();
    }

    public static SlideTransition slide() {
        return new SlideTransition();
    }

    public static PushTransition push() {
        return new PushTransition();
    }

    public static WipeTransition wipe() {
        return new WipeTransition();
    }
}