/*
* copyright (c) 2010 Sveriges Television AB <info@casparcg.com>
*
*  This file is part of CasparCG.
*
*    CasparCG is free software: you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation, either version 3 of the License, or
*    (at your option) any later version.
*
*    CasparCG is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.

*    You should have received a copy of the GNU General Public License
*    along with CasparCG.  If not, see <http://www.gnu.org/licenses/>.
*
*/
//TODO: This is part of the EventManageer, should be removed!
package se.svt.caspar
{
	import flash.events.IEventDispatcher;
	
	/**
	 * ...
	 * @author Peter Karlsson, Sveriges Television AB
	 */
	/**
	* Required methods for a class to dispatch events via the CommunicationManager
	*/
	
	public interface IRegisteredDispatcher extends IEventDispatcher
	{
		function getEvents():Array;
	}
	
}