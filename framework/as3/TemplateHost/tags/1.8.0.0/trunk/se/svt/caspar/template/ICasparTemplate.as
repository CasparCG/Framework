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

package se.svt.caspar.template {
	import flash.display.MovieClip;
	import se.svt.caspar.ITemplateContext;
	
	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	public interface ICasparTemplate 
	 {
		//Commands from the template host
		function Play():void;
		function Stop():void;
		function Next():void;
		function GotoLabel(label:String):void;
		function SetData(xmlData:XML):void;
		function ExecuteMethod(methodName:String):void;
		function GetDescription():String; 
		//Template metadata
		function initialize(context:ITemplateContext):void;
		function dispose():void;
		function get movieClip():MovieClip;
		function get originalWidth():Number;
		function get originalHeight():Number;
		function get originalFrameRate():Number;
		function get version():String;
		function get layer():int;
	}
}
