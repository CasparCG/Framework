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
package se.svt.caspar.amcp;

import java.util.List;

import javafx.beans.property.BooleanProperty;

import se.svt.caspar.Adjustments;
import se.svt.caspar.Call;
import se.svt.caspar.CallWithReturn;
import se.svt.caspar.Channel;
import se.svt.caspar.Corners;
import se.svt.caspar.CornersView;
import se.svt.caspar.EaseableDouble;
import se.svt.caspar.Geometry;
import se.svt.caspar.GeometryView;
import se.svt.caspar.Layer;
import se.svt.caspar.Levels;
import se.svt.caspar.Position;
import se.svt.caspar.PositionView;
import se.svt.caspar.Producer;
import se.svt.caspar.Transition;
import se.svt.caspar.VideoMode;

/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public class AmcpLayer implements Layer {
	private final AmcpChannel mChannel;
	private final int mLayerId;
	private final AmcpGeometry mFill;
	private final AmcpGeometry mClipping;
	private final AmcpAdjustments mAdjustments;
	private final AmcpPosition mAnchorPoint;
	private final AmcpLevels mLevels;
    private final EaseableDouble mRotation;
    private final AmcpCropRectangle mCrop;
    private final AmcpPerspectiveCorners mPerspective;
    private final BooleanProperty mMipmapping;

	/**
	 * Constructor.
	 */
	public AmcpLayer(AmcpChannel channel, int layerId) {
		mChannel = channel;
		mLayerId = layerId;
		mFill = new AmcpFillGeometry(this);
		mClipping = new AmcpClippingGeometry(this);
		mAdjustments = new AmcpAdjustments(this);
		mAnchorPoint = new AmcpAnchorPosition(this);
		mLevels = new AmcpLevels(this);
		mRotation = new AdjustmentDouble(this, 0, "ROTATION");
		mCrop = new AmcpCropRectangle(this);
        mPerspective = new AmcpPerspectiveCorners(this);
        mMipmapping = new AdjustmentBoolean(this, false, "MIPMAP");

	}

	/** {@inheritDoc} */
	@Override
	public BooleanProperty mipmapping() {
	    return mMipmapping;
	}

	@Override
	public Channel channel() {
		return mChannel;
	}

	/** {@inheritDoc} */
	@Override
	public Layer above() {
	    return mChannel.layer(mLayerId + 1);
	}

	/** {@inheritDoc} */
	@Override
	public int layerId() {
		return mLayerId;
	}

	/** {@inheritDoc} */
	@Override
	public Geometry fill() {
		return mFill;
	}

	@Override
	public Geometry pixelFill() {
		VideoMode videoMode = mChannel.videoMode();

		return new GeometryView(
				fill(), videoMode.getWidth(), videoMode.getHeight());
	}

	@Override
	public Geometry clipping() {
		return mClipping;
	}

	@Override
	public Geometry pixelClipping() {
		VideoMode videoMode = mChannel.videoMode();

		return new GeometryView(
				clipping(), videoMode.getWidth(), videoMode.getHeight());
	}

	/** {@inheritDoc} */
	@Override
	public Position anchorPoint() {
	    return mAnchorPoint;
	}

	/** {@inheritDoc} */
	@Override
	public Position pixelAnchorPoint() {
        VideoMode videoMode = mChannel.videoMode();

        return new PositionView(
                anchorPoint(), videoMode.getWidth(), videoMode.getHeight());
	}

	/** {@inheritDoc} */
	@Override
	public Geometry crop() {
	    return mCrop;
	}

	/** {@inheritDoc} */
	@Override
	public Geometry pixelCrop() {
        VideoMode videoMode = mChannel.videoMode();

        return new GeometryView(
                crop(), videoMode.getWidth(), videoMode.getHeight());
	}

	/** {@inheritDoc} */
	@Override
	public Corners perspective() {
	    return mPerspective;
	}

	/** {@inheritDoc} */
	@Override
	public Corners pixelPerspective() {
        VideoMode videoMode = mChannel.videoMode();

        return new CornersView(
                perspective(), videoMode.getWidth(), videoMode.getHeight());
	}

	/** {@inheritDoc} */
	@Override
	public EaseableDouble rotation() {
	    return mRotation;
	}

	/** {@inheritDoc} */
	@Override
	public Adjustments adjustments() {
		return mAdjustments;
	}

	/** {@inheritDoc} */
	@Override
	public Levels levels() {
		return mLevels;
	}

	/** {@inheritDoc} */
	@Override
	public void load(Producer producer) {
		sendCommand("LOAD", producer.getParameters());
	}

	@Override
	public void load(Producer producer, Transition transition) {
		sendCommand("LOAD",
				producer.getParameters() + " " + transition.getParameters());
	}

	/** {@inheritDoc} */
	@Override
	public void loadBg(Producer producer) {
		sendCommand("LOADBG", producer.getParameters());
	}

	@Override
	public void loadBg(Producer producer, boolean autoPlay) {
		sendCommand("LOADBG",
				producer.getParameters() + (autoPlay ? " AUTO" : ""));
	}

	@Override
	public void loadBg(Producer producer, Transition transition) {
		sendCommand("LOADBG",
				producer.getParameters() + " " + transition.getParameters());
	}

	@Override
	public void loadBg(
			Producer producer, Transition transition, boolean autoPlay) {
		sendCommand("LOADBG", producer.getParameters()
		        + " " + transition.getParameters()
		        + (autoPlay ? " AUTO" : ""));
	}

	/** {@inheritDoc} */
	@Override
	public void play(Producer producer) {
		sendCommand("PLAY", producer.getParameters());
	}

	@Override
	public void play(Producer producer, Transition transition) {
		sendCommand("PLAY",
				producer.getParameters() + " " + transition.getParameters());
	}

	/** {@inheritDoc} */
	@Override
	public void play() {
		sendCommand("PLAY");
	}

	/** {@inheritDoc} */
	@Override
	public void pause() {
		sendCommand("PAUSE");
	}

	/** {@inheritDoc} */
	@Override
	public void stop() {
		sendCommand("STOP");
	}

	/** {@inheritDoc} */
	@Override
	public void clear() {
		sendCommand("CLEAR");
	}

	/** {@inheritDoc} */
	@Override
	public void clearMixer() {
		sendCommand("MIXER", "CLEAR");
		mixerCleared();
	}

	/** {@inheritDoc} */
	@Override
	public void executeCustomCommand(String command, String parameters) {
	    sendCommand(command, parameters);
	}

	void mixerCleared() {
		mFill.initialValues();
		mClipping.initialValues();
	}

	/** {@inheritDoc} */
	@Override
	public void call(Call call) {
		sendCommand("CALL", call.getParameters());
	}

	/** {@inheritDoc} */
	@Override
	public <R> R call(CallWithReturn<R> call) {
		String result = sendCommandExpectSingle("CALL", call.getParameters());

		return call.parseResult(result);
	}

	/** {@inheritDoc} */
	@Override
	public void callBg(Call call) {
		sendCommand("CALL", "B " + call.getParameters());
	}

	/** {@inheritDoc} */
	@Override
	public <R> R callBg(CallWithReturn<R> call) {
		String result = sendCommandExpectSingle(
				"CALL", "B " + call.getParameters());

		return call.parseResult(result);
	}

	public List<String> sendCommand(String command, String parameters) {
		return mChannel.getDevice().sendCommand(
				command + " " + getLayerSpec() + " " + parameters);
	}

	public String sendCommandExpectSingle(String command, String parameters) {
		return mChannel.getDevice().sendCommandExpectSingle(
				command + " " + getLayerSpec() + " " + parameters);
	}

	public List<String> sendCommand(String command) {
		return mChannel.getDevice().sendCommand(command + " " + getLayerSpec());
	}

	public String sendCommandExpectSingle(String command) {
		return mChannel.getDevice().sendCommandExpectSingle(
				command + " " + getLayerSpec());
	}

	private String getLayerSpec() {
		return mChannel.getChannelId() + "-" + mLayerId;
	}
}
