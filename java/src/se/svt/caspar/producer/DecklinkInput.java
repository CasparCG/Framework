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
package se.svt.caspar.producer;

import se.svt.caspar.Producer;
import se.svt.caspar.VideoMode;

/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public class DecklinkInput implements Producer {

    private final int mDevice;
    private final VideoMode mVideoMode;

    /**
     * Constructor.
     *
     * @param parameters
     */
    public DecklinkInput(int device, VideoMode videoMode) {
        mDevice = device;
        mVideoMode = videoMode;
    }

    /** {@inheritDoc} */
    @Override
    public String getParameters() {
        return "DECKLINK DEVICE " + mDevice + " FORMAT " + mVideoMode.getName();
    }
}
