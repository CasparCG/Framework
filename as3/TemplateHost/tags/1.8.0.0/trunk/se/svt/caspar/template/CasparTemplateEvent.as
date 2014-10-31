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

package se.svt.caspar.template 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	public class CasparTemplateEvent extends Event
	{
		
		public static const	REMOVE_TEMPLATE:String = "remove template";
		public static const	EXTERNAL_CALL:String = "external call";
		
		private var _template:ICasparTemplate;
		private var _methodName:String;
		private var _args:Array;
		
		public function CasparTemplateEvent(type:String, template:ICasparTemplate)
		{
			super(type);
			_template = template;
		}
		
		public override function clone():Event
		{
			return new CasparTemplateEvent(super.type, _template);
		}
		
		public function get template():ICasparTemplate { return _template; }
		
		public function get methodName():String { return _methodName; }
		
		public function set methodName(value:String):void 
		{
			_methodName = value;
		}
		
		public function get args():Array { return _args; }
		
		public function set args(value:Array):void 
		{
			_args = value;
		}
		
	}
	
}