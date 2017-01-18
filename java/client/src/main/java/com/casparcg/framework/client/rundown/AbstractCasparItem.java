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
public class AbstractCasparItem<Item extends AbstractCasparItem<?>> extends AbstractItem<Item> {
    @XStreamAlias("devicename")
    private String mDeviceName;

    public AbstractCasparItem(ItemType type, String defaultLabel) {
        super(type, defaultLabel);
    }

    @SuppressWarnings("unchecked")
    public Item deviceName(String deviceName) {
        mDeviceName = deviceName;

        return (Item) this;
    }

    public String deviceName() {
        return mDeviceName;
    }
}
