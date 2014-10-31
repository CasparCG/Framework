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
package se.svt.caspar;

import javafx.beans.property.BooleanProperty;

/**
 * Models a video layer in the CasparCG server.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public interface Layer {
	/**
	 * @return the reference to the owning channel.
	 */
	Channel channel();

	int layerId();

	Layer above();

	/**
	 * @return the geometry of the mixer fill. The coordinate system is between
	 *         0.0 and 1.0 for both the width and the height.
	 */
	Geometry fill();

	/**
	 * @return the pixel mapped geometry of the mixer fill. The coordinate
	 *         system is mapped to match the video mode of the channel, so one
	 *         step in the coordinate system is exactly one pixel on the video
	 *         channel.
	 */
	Geometry pixelFill();

	/**
	 * @return the geometry of the mixer clipping. The coordinate system is
	 *         between 0.0 and 1.0 for both the width and the height.
	 */
	Geometry clipping();

	/**
	 * @return the pixel mapped geometry of the mixer clipping. The coordinate
	 *         system is mapped to match the video mode of the channel, so one
	 *         step in the coordinate system is exactly one pixel on the video
	 *         channel.
	 */
	Geometry pixelClipping();

	Position anchorPoint();
    Position pixelAnchorPoint();

    Geometry crop();
    Geometry pixelCrop();
    Corners perspective();
    Corners pixelPerspective();

    EaseableDouble rotation();

    BooleanProperty mipmapping();

	Adjustments adjustments();

	Levels levels();

	/**
	 * Load a producer directly in the layer foreground, without starting to
	 * play.
	 *
	 * @param producer The producer to load.
	 */
	void load(Producer producer);
	void load(Producer producer, Transition transition);
	void loadBg(Producer producer);
	void loadBg(Producer producer, boolean autoPlay);
	void loadBg(Producer producer, Transition transition);
	void loadBg(Producer producer, Transition transition, boolean autoPlay);
	void play(Producer producer);
	void play(Producer producer, Transition transition);
	void play();
	void pause();
	void stop();
	void clear();
	void clearMixer();
	void call(Call call);
	void callBg(Call call);
	void executeCustomCommand(String command, String parameters);
	<R> R call(CallWithReturn<R> call);
	<R> R callBg(CallWithReturn<R> call);
}
