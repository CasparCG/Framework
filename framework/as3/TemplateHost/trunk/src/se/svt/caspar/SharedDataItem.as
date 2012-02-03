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
	public class SharedDataItem 
	{
		private var _id:String;
		private var _data:*;
		private var _subscribers:Vector.<IRegisteredDataSharer>;
		
		public function SharedDataItem(id:String, data:*) 
		{
			_subscribers = new Vector.<IRegisteredDataSharer>();
			_id = id;
			_data = data;
		}
		
		public function dispose():void 
		{
			_subscribers = null;
			_id = null;
			_data = null;
		}
		
		public function addSubscriber(subscriber:IRegisteredDataSharer):Boolean
		{
			if (_subscribers.indexOf(subscriber) == -1) 
			{
				_subscribers.push(subscriber);
				return true;
			} 
			else
			{
				return false;
			}
		}
		
		public function removeSubscriber(subscriber:IRegisteredDataSharer):uint 
		{
			var subscriberIndex:uint = _subscribers.indexOf(subscriber);
			
			if (subscriberIndex != -1)
			{
				_subscribers.splice(subscriberIndex, 1);
			}
			
			return _subscribers.length;
		}
		
		public function broadcast():void {
			for (var i:int = 0; i < _subscribers.length; i++) 
			{
				_subscribers[i].onSharedDataChanged(id);
			}
		}
		
		public function get id():String { return _id; }
		
		public function set id(value:String):void 
		{
			_id = value;
		}
		
		public function get data():* { return _data; }
		
		public function set data(value:*):void 
		{
			_data = value;
		}
	}
}