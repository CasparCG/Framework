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

package se.svt.caspar 
{
	
	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	public interface ISharedData 
	{
		/**
		 * Writes data to the SharedData object. You must implement the IRegisteredDataSharer interface to use this method.
		 * 
		 * @param	subscriber The subscribing template, usually [this]
		 * @param	id The access identifier for the data
		 * @param	data Arbitrary data
		 * @param	broadcast (default = true) — Determines whether the data insertion will broadcast an event to all subscribers
		 * @param	overwrite (default = true) — Determines weather the insertion will overwrite data.
		 * @return Boolean - true if the data insertion was successful, otherwise false.
		 */
		function writeData(subscriber:IRegisteredDataSharer, id:String, data:*, broadcast:Boolean = true, overwrite:Boolean = true):Boolean;
		/**
		 * Reads data from the SharedData object.
		 * 
		 * @param	id The access identifier for the data
		 */
		function readData(id:String):*;
		/**
		 * Subscribes to a specific id to be able to recieve on
		 * 
		 * @param	subscriber The subscribing template, usually [this]
		 * @param	id The access identifier for the data
		 */
		function addSubscriber(subscriber:IRegisteredDataSharer, id:String):void;
	}
	
}