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
	public interface IRegisteredDataSharer
	{
		/**
		 * Listener for the SharedData changed event. Will listen for changes on data that you are a subscriber of.
		 * @param	id The key to the data that was changed.
		 */
		function onSharedDataChanged(id:String):void
	}
	
}