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

/**
 * This is a temporary extension that will be merged in the 2.1 release.
 */

 //TODO: Add get info aswell?

package se.svt.caspar.template {
	import flash.display.MovieClip;
	import se.svt.caspar.ITemplateContext;
	import se.svt.caspar.template.components.ComponentAssets;
	
	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	public interface ICaspar2Template extends ICasparTemplate 
	 {
		//Commands from the template host
		function SetDataObject(dataObject:ComponentAssets):void
		function set templateName(value:String):void;
		function get templateName():String;
	}
}
