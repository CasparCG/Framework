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
package com.casparcg.framework.client.rundown;

import com.thoughtworks.xstream.annotations.XStreamAlias;

/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
@XStreamAlias("item")
public class MixerAnchorItem extends AbstractLayerItem<MixerAnchorItem> {
    @XStreamAlias("positionx")
    private double mX;

    @XStreamAlias("positiony")
    private double mY;

    @XStreamAlias("usemipmap")
    private boolean mUseMipmap;

    public MixerAnchorItem() {
        super(ItemType.ANCHOR, "Anchor Point");
    }

    public MixerAnchorItem x(double x) {
        mX = x;

        return this;
    }

    public MixerAnchorItem y(double y) {
        mY = y;

        return this;
    }

    public MixerAnchorItem useMipmap(boolean useMipmap) {
        mUseMipmap = useMipmap;

        return this;
    }

    public CustomCommandItem toCustomCommand() {
        return new CustomCommandItem()
                .stopCommand("MIXER " + channel() + "-" + videoLayer() + " ANCHOR 0 0")
                .playCommand("MIXER " + channel() + "-" + videoLayer() + " ANCHOR " + mX + " " + mY)
                .deviceName(deviceName())
                .label("Custom MIXER ANCHOR");
    }
}
