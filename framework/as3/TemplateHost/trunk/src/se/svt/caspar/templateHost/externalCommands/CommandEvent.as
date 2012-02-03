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
//TODO: Should we move this class to se.svt.caspar.templateHost or move ExternalCommandsBuffer to this package maybe?
package se.svt.caspar.templateHost.externalCommands 
{
	import flash.events.Event;
	import se.svt.caspar.template.ICasparTemplate;
	
	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	public class CommandEvent extends Event 
	{
		
		public static const COMMAND_FINISHED:String = "command finished";
		public static const TEMPLATE_PLAYING:String = "template playing";
		public static const GET_DESCRIPTION:String = "get description";
		public static const ON_ERROR:String = "on error";
		public static const BUFFER_EMPTY:String = "buffer empty";
		public static const DEBUG_MESSAGE:String = "debug message";
		
		private var _layer:int;
		private var _data:String;
		private var _success:Boolean;
		
		public function CommandEvent(type:String, layer:int = undefined, data:String = null, success:Boolean = false):void
		{ 
			_layer = layer;
			_data = data;
			_success = success;
			super(type);
		} 
		
		public override function clone():Event
		{ 
			return new CommandEvent(type, layer, data, success);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("CommandEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get layer():int { return _layer; }
		
		public function get data():String { return _data; }
		
		public function get success():Boolean { return _success; }
		
	}
	
}