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

package se.svt.caspar.templateHost 
{
	import flash.display.Sprite;
	import se.svt.caspar.template.ICasparTemplate;
	
	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	public interface ITemplateHost 
	{
		function get screenWidth():Number;
		function get screenHeight():Number;
		//function get STANDARD():Number;
		//function get WIDE_SCREEN():Number;
		//function get VERSION():String;
		function get loadedTemplates():LoadedTemplates;
		//function get templateContainer():Sprite;
		function get mixer():Mixer;
		function registerTemplate(template:ICasparTemplate):void;
		function removeTemplate(template:ICasparTemplate):void;
		
	}
}
