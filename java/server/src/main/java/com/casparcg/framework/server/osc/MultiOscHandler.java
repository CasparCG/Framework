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
package com.casparcg.framework.server.osc;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import com.illposed.osc.OSCMessage;


/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public class MultiOscHandler implements OscHandler {
    private final Map<String, OscHandler> mHandlers =
            new ConcurrentHashMap<>();

    public void subscribe(String path, OscHandler handler) {
        mHandlers.put(path, handler);
    }

    public void unsubscribe(OscHandler handler) {
        mHandlers.values().remove(handler);
    }

    /** {@inheritDoc} */
    @Override
    public void handle(OSCMessage message) {
        String handledPath = mHandlers
                .keySet()
                .stream()
                .sorted((o1, o2) -> Integer.compare(o2.length(), o1.length()))
                .filter(p -> message.getAddress().startsWith(p))
                .findFirst()
                .orElse(null);

        if (handledPath == null) {
            return;
        }

        OscHandler handler = mHandlers.get(handledPath);

        if (handler != null) {
            String restPath =
                    message.getAddress().substring(handledPath.length());
            message.setAddress(restPath);
            handler.handle(message);
        }
    }
}
