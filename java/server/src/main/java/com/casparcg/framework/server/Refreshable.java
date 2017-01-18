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

/**
 * Common interface for transactional abstractions where many small changes may
 * be sent all at once to the server, or each time a single change has been made
 * (more commands sent to the server).
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public interface Refreshable {
	/**
	 * Auto refresh causes every change to be transmitted to the server.
	 *
	 * @param on Whether to turn it on or off.
	 */
	void autoSubmit(boolean on);

	/**
	 * @return whether auto refresh is on or not.
	 */
	boolean autoSubmit();

	/**
	 * Perform a submit of the current values to the server.
	 */
	void submit();

	void setStale();
	boolean stale();

	void autoFetch(boolean on);
	boolean autoFetch();
	void fetch();

	void wasReset();
	void reset();
}
