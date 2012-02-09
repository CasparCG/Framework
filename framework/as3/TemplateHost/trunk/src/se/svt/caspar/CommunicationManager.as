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
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import se.svt.caspar.template.ICasparTemplate;
	
	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	
	 //TODO: Needs! to be rewritten, should use only a (modified) version of shared data. Check on backward-compability.
	public class CommunicationManager implements ICommunicationManager
	{
		//Holds the SharedData instance
		private var _sharedData:SharedData; 
		//Holds the EventManager instance 
		private var _eventManager:EventManager;
		
		public function CommunicationManager()
		{
			_sharedData = new SharedData();
			_eventManager = new EventManager();
		}
		
		public function unregisterTemplate(template:ICasparTemplate):void
		{
			if (template as IRegisteredDispatcher != null) 
			{
				_eventManager.removeDispactchersByObject(template as IRegisteredDispatcher);
			}
			
			if (template as IRegisteredDataSharer != null) 
			{
				_sharedData.removeSubscriber(template as IRegisteredDataSharer);
			}
			
		}
		
		/* INTERFACE ICommunicationManager */
		
		public function get sharedData():ISharedData { return _sharedData; }
		
		public function get eventManager():IEventManager { return _eventManager; }
		
	}
	
}