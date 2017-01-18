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
public class MixerTransformItem extends AbstractLayerItem<MixerTransformItem> {
    @XStreamAlias("positionx")
    private double mX;

    @XStreamAlias("positiony")
    private double mY;

    @XStreamAlias("scalex")
    private double mScaleX = 1.0;

    @XStreamAlias("scaley")
    private double mScaleY = 1.0;

    @XStreamAlias("usemipmap")
    private boolean mUseMipmap;

    public MixerTransformItem() {
        super(ItemType.FILL, "Transform");
    }

    public MixerTransformItem x(double x) {
        mX = x;

        return this;
    }

    public MixerTransformItem y(double y) {
        mY = y;

        return this;
    }

    public MixerTransformItem scaleX(double scaleX) {
        mScaleX = scaleX;

        return this;
    }

    public MixerTransformItem scaleY(double scaleY) {
        mScaleY = scaleY;

        return this;
    }

    public MixerTransformItem useMipmap(boolean useMipmap) {
        mUseMipmap = useMipmap;

        return this;
    }

    public CustomCommandItem toCustomCommand() {
        return new CustomCommandItem()
                .stopCommand("MIXER " + channel() + "-" + videoLayer() + " FILL 0 0 1 1")
                .playCommand("MIXER " + channel() + "-" + videoLayer() + " FILL "
                        + mX + " "
                        + mY + " "
                        + mScaleX + " "
                        + mScaleY)
                .deviceName(deviceName())
                .label("Custom MIXER FILL");
    }
}
