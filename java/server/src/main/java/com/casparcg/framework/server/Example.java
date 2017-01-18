/*
* Copyright (c) 2013 Sveriges Television AB <info@casparcg.com>
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
* Author: Helge Norberg, helge.norberg@svt.se
*/
package com.casparcg.framework.server;

import com.casparcg.framework.server.amcp.AmcpCasparDeviceFactory;
import com.casparcg.framework.server.producer.Video;

/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public class Example {
	public static void main(String[] args) throws InterruptedException {
		CasparDeviceFactory factory = new AmcpCasparDeviceFactory();
		CasparDevice device = factory.create("localhost", 5250);
		Channel channel = device.channel(1);
		Layer layer = channel.layer(0);

		layer.play(new Video("lady_gaga"));
		layer.pixelFill().reset();
		layer.pixelFill().scale(638, 358);
		System.out.println(layer.call(new Video.Loop(true)));
		layer.call(new Video.Seek(50));
		layer.adjustments().opacity().set(2);
		layer.adjustments().opacity().set(1);
		layer.adjustments().opacity().set(0.1);
		System.out.println(layer.adjustments().opacity().get());
		layer.adjustments().opacity().setStale();
		System.out.println(layer.adjustments().opacity().get());
		/*Geometry pixelGeometry = layer.pixelFill();
		VideoMode videoMode = channel.videoMode();
		pixelGeometry.position(640, 360);

		for (int i = 0; i < videoMode.getWidth() / 2; ++i) {
			pixelGeometry.scaleX(i);
			Thread.sleep((long) videoMode.getMillisecondsPerFrame());
		}*/

		//System.out.println(device.dataRetrieve("VINTERSTUDION\\STARTANDE_TEST"));

		System.out.println(VideoMode.x1080p5994.getMillisecondsPerFrame());
		VideoMode.forName("720p5000");
	}

}
