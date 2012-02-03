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

//This module is unstable, please use SharedData instead!
package se.svt.caspar
{
	/**
	 * ...
	 * @author Peter Karlsson, Sveriges Television AB
	 */
	
	public class EventListener
	{
		private var _id:uint;
		private var _listener:Function;
		private var _listenerReference:Object;
		private var _type:String;
		private var _useCapture:Boolean;
		
		public function EventListener(id:uint)
		{
			this._id = id;
		}
		
		public function valueOf():uint
		{
			return this._id;
		}
		
		
		
		public function get id():uint { return this._id; }
		public function get listener():Function { return this._listener; }
		public function get listenerReference():Object { return this._listenerReference; }
		public function get type():String { return this._type; }		
		public function get useCapture():Boolean { return this._useCapture; }
		
		public function set listener(value:Function):void {	this._listener = value; }
		public function set listenerReference(value:Object):void { this._listenerReference = value; }
		public function set type(value:String):void { this._type = value; }
		public function set useCapture(value:Boolean):void { this._useCapture = value; }		
	}
}