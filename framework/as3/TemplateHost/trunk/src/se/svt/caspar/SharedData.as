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

//TODO: Add broadcast to self true/false?

package se.svt.caspar 
{
	import flash.utils.Dictionary;

	
	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	
	 /**
	 * Holds data of any type indexed by a string and can also broadcast to all subscribers when data is changed
	 */
	public class SharedData implements ISharedData
	{
		
		private var _sharedDataItems:Dictionary;
		private var _subscribers:Dictionary;
		private var _subscriberCounter:uint;
		private var _idCounter:uint;
		
		public function SharedData():void
		{
			_subscribers = new Dictionary();
			_sharedDataItems = new Dictionary();
			_subscriberCounter = 0;
			_idCounter = 0;
		}
		
		public function writeData(subscriber:IRegisteredDataSharer, id:String, data:*, broadcast:Boolean = true, overwrite:Boolean = true):Boolean
		{
			if (_sharedDataItems[id] == undefined) 
			{
				_sharedDataItems[id] = new SharedDataItem(id, data);
				addSubscriber(subscriber, id);
				_idCounter++;
				if (broadcast) 
				{
					broadcastDataChange(id);
				}
				return true;
			} 
			else 
			{
				if (!overwrite) 
				{
					return false;
				} else {
					//TODO: try catch if data = null
					_sharedDataItems[id].data = data;
					addSubscriber(subscriber, id);
					broadcastDataChange(id);
					return true;
				}
			}
		}
		
		public function readData(id:String):* 
		{
			try 
			{
				return _sharedDataItems[id].data;
			}
			catch(e:Error)
			{
				return null;
			}
			
		}
		
		private function broadcastDataChange(id:String):void
		{
			_sharedDataItems[id].broadcast();
		}
		
		public function deleteData(id:String):Boolean 
		{
			return false;
		}
		
		//TODO: Possibility to add subscriber on non existing keys
		public function addSubscriber(subscriber:IRegisteredDataSharer, id:String):void 
		{
			try
			{
				if (_sharedDataItems[id].addSubscriber(subscriber))
				{
					if (_subscribers[subscriber] != undefined)
					{
						_subscribers[subscriber].push(id);
					}
					else 
					{
						_subscribers[subscriber] = [id];
						_subscriberCounter++;
					}
				}
			}
			catch (e:Error)
			{
				trace("SharedData Error: Cannot subscribe to non existing key, use write data first.");
			}
		}
		
		public function removeSubscriber(subscriber:IRegisteredDataSharer):void 
		{
			if(_subscribers[subscriber] != undefined)
			{
				for (var i:uint = 0; i < _subscribers[subscriber].length; i++)
				{
					var id:String = _subscribers[subscriber][i];
					
					if (_sharedDataItems[id].removeSubscriber(subscriber) == 0)
					{
						_idCounter--;
						_sharedDataItems[id].dispose();
						delete _sharedDataItems[id];
					}
				}
					
				delete _subscribers[subscriber];
				_subscriberCounter--;
			}
		}
	}	
}