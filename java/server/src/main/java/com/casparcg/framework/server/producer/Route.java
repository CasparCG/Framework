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
package com.casparcg.framework.server.producer;

import com.casparcg.framework.server.Channel;
import com.casparcg.framework.server.Layer;
import com.casparcg.framework.server.Producer;

/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public class Route implements Producer {
    private final String mSource;

    public Route(Channel channel) {
        mSource = String.valueOf(channel.channelId());
    }

    public Route(Layer layer) {
        mSource = layer.channel().channelId() + "-" + layer.layerId();
    }

    /** {@inheritDoc} */
    @Override
    public String getParameters() {
        return "route://" + mSource;
    }
}
