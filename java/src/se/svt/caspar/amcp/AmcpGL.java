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
package se.svt.caspar.amcp;

import javafx.beans.property.IntegerProperty;
import javafx.beans.property.LongProperty;
import javafx.beans.property.ReadOnlyIntegerProperty;
import javafx.beans.property.ReadOnlyLongProperty;
import javafx.beans.property.SimpleIntegerProperty;
import javafx.beans.property.SimpleLongProperty;

import se.svt.caspar.GL;

/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public class AmcpGL implements GL {
    private final AmcpCasparDevice mDevice;
    private final SummaryImpl mSummary = new SummaryImpl();

    /**
     * Constructor.
     *
     * @param device
     */
    public AmcpGL(AmcpCasparDevice device) {
        mDevice = device;
        //refreshInfo();
    }

    /** {@inheritDoc} */
    @Override
    public void gc() {
        mDevice.sendCommand("GL GC");
    }

    /** {@inheritDoc} */
    @Override
    public void refreshInfo() {
        String xml = mDevice.sendCommandExpectSingle("GL INFO");
        XPath xpath = new XPath(xml);
        mSummary.refresh(xpath.getSubContext("/gl/summary"));
    }

    /** {@inheritDoc} */
    @Override
    public Summary summary() {
        return mSummary;
    }

    private static class SummaryImpl implements Summary {
        private final DeviceBuffersSummaryImpl mPooledDeviceBuffers =
                new DeviceBuffersSummaryImpl();
        private final DeviceBuffersSummaryImpl mAllDeviceBuffers =
                new DeviceBuffersSummaryImpl();
        private final HostBuffersSummaryImpl mPooledHostBuffers =
                new HostBuffersSummaryImpl();
        private final HostBuffersSummaryImpl mAllHostBuffers =
                new HostBuffersSummaryImpl();

        public void refresh(XPathContext xpath) {
            mPooledDeviceBuffers.refresh(
                    xpath.getSubContext("/pooled_device_buffers"));
            mAllDeviceBuffers.refresh(
                    xpath.getSubContext("/all_device_buffers"));
            mPooledHostBuffers.refresh(
                    xpath.getSubContext("/pooled_host_buffers"));
            mAllHostBuffers.refresh(xpath.getSubContext("/all_host_buffers"));
        }

        /** {@inheritDoc} */
        @Override
        public DeviceBuffersSummary pooledDeviceBuffers() {
            return mPooledDeviceBuffers;
        }

        /** {@inheritDoc} */
        @Override
        public DeviceBuffersSummary allDeviceBuffers() {
            return mAllDeviceBuffers;
        }

        /** {@inheritDoc} */
        @Override
        public HostBuffersSummary pooledHostBuffers() {
            return mPooledHostBuffers;
        }

        /** {@inheritDoc} */
        @Override
        public HostBuffersSummary allHostBuffers() {
            return mAllHostBuffers;
        }

    }

    private static class DeviceBuffersSummaryImpl
            implements DeviceBuffersSummary {
        private final IntegerProperty mTotalCount = new SimpleIntegerProperty();
        private final LongProperty mTotalSize= new SimpleLongProperty();

        /** {@inheritDoc} */
        @Override
        public ReadOnlyIntegerProperty totalCount() {
            return mTotalCount;
        }

        /** {@inheritDoc} */
        @Override
        public ReadOnlyLongProperty totalSize() {
            return mTotalSize;
        }

        public void refresh(XPathContext xpath) {
            mTotalCount.set(xpath.getInt("/total_count"));
            mTotalSize.set(xpath.getLong("/total_size"));
        }
    }

    private static class HostBuffersSummaryImpl implements HostBuffersSummary {
        private final IntegerProperty mTotalReadOnlyCount =
                new SimpleIntegerProperty();
        private final IntegerProperty mTotalWriteOnlyCount =
                new SimpleIntegerProperty();
        private final LongProperty mTotalReadOnlySize =
                new SimpleLongProperty();
        private final LongProperty mTotalWriteOnlySize =
                new SimpleLongProperty();

        /** {@inheritDoc} */
        @Override
        public ReadOnlyIntegerProperty totalReadOnlyCount() {
            return mTotalReadOnlyCount;
        }

        /** {@inheritDoc} */
        @Override
        public ReadOnlyIntegerProperty totalWriteOnlyCount() {
            return mTotalWriteOnlyCount;
        }

        /** {@inheritDoc} */
        @Override
        public ReadOnlyLongProperty totalReadOnlySize() {
            return mTotalReadOnlySize;
        }

        /** {@inheritDoc} */
        @Override
        public ReadOnlyLongProperty totalWriteOnlySize() {
            return mTotalWriteOnlySize;
        }

        public void refresh(XPathContext xpath) {
            mTotalReadOnlyCount.set(xpath.getInt("/total_read_count"));
            mTotalWriteOnlyCount.set(xpath.getInt("/total_write_count"));
            mTotalReadOnlySize.set(xpath.getLong("/total_read_size"));
            mTotalWriteOnlySize.set(xpath.getLong("/total_write_size"));
        }
    }
}
