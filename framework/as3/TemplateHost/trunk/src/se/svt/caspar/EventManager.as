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
//TODO: This is part of the EventManageer, should be removed!
//NOTICE!!!
//This module is unstable, please use SharedData instead!

package se.svt.caspar
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Peter Karlsson, Sveriges Television AB
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	
	/**
	 * In order to work, EventManager provides a public registerDispactcher method that allows any class or object to announce 
	 * itself as one that will be dispatching events. The event manager will then take a reference to that class, and a list 
	 * of events and set itself up as a listener. This becomes useful because any class can access and listen to the 
	 * EventManager without having any sort of reference to the actual class that dispatched the event.  
	 *
	 * Additionally, this class provides added functionality absent from Adobe's EventDispatcher. To offer more control over all the events,
	 * this class provides addition methods to remove listeners and dispatchers by type, function object or to remove all.
	 */
	public class EventManager extends EventDispatcher implements IEventManager
	{	
		private var listenerId:int = 0;
		private var dispatcherId:int = 0;
		
		private var listeners:Array = new Array();
		private var dispatchers:Array = new Array();
		
		private static const MAX_LISTENERS:uint = 1000;
		private static const MAX_DISPATCHERS:uint = 1000;
		
		/**
		 * Constructor.
		 */
		public function EventManager()		
		{
		}
		
		
		///////////////////////////////
		/**
		 * Almost override of Adobe's standard addEventListener function. The main difference is that this method allows
		 * us to store a copy of the listener so that we can remove it later, in groups, or even remove all at once. 
		 */
		public function registerEventListener(listenerReference:Object, type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			trace("EventManager: This module is unstable, please use SharedData instead!");
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			
			var eventListener:EventListener = new EventListener(this.listenerId);
			eventListener.type = type;
			eventListener.listener = listener;
			eventListener.useCapture = useCapture;
			eventListener.listenerReference = listenerReference;
			this.listeners.push(eventListener);
			
			trace("Registered listeners: " + this.listeners);
			
			this.listenerId++;
			if (this.listenerId >= MAX_LISTENERS)
			{
				throw new RangeError(this.toString() + " WARNING: there are over " + MAX_LISTENERS + " listeners registered.");
			}
		}
		
		/**
		 * Almost override of Adobe's standard removeEventListener function. Because Adobe's EventDispatcher class maintains seperate
		 * lists for listeners set to use the capture phase and the bubbling phase, we must included it as a parameter.
		 */
		public function unregisterEventListener(listenerReference:Object, type:String, listener:Function, useCapture:Boolean = false):void
		{
			trace("EventManager: This module is unstable, please use SharedData instead!");
			var length:int = this.listeners.length; // Performance reasons.

			for (var i:int = length - 1; i >= 0; i--)
			{
				var eventListener:EventListener = this.listeners[i] as EventListener;
				
				if (eventListener.type === type &&
					eventListener.listener === listener && 
					eventListener.useCapture === useCapture &&
					eventListener.listenerReference === listenerReference
					)
				{
					super.removeEventListener(eventListener.type, eventListener.listener, eventListener.useCapture);
					this.listeners.splice(i, 1);
					this.listenerId--;
				}
			}
		}
		///////////////////////////////
		
		/**
		 * Override of Adobe's standard addEventListener function. The main difference is that this method allows
		 * us to store a copy of the listener so that we can remove it later, in groups, or even remove all at once. 
		 */
		public override function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			trace("DEPRECATED - use registerEventListener instead.");
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			
			var eventListener:EventListener = new EventListener(this.listenerId);
			eventListener.type = type;
			eventListener.listener = listener;
			eventListener.useCapture = useCapture;
			this.listeners.push(eventListener);
			
			trace("Registered listeners: " + this.listeners);
			
			this.listenerId++;
			if (this.listenerId >= MAX_LISTENERS)
			{
				throw new RangeError(this.toString() + " WARNING: there are over " + MAX_LISTENERS + " listeners registered.");
			}
		}
		
		/**
		 * Override of Adobe's standard removeEventListener function. Because Adobe's EventDispatcher class maintains seperate
		 * lists for listeners set to use the capture phase and the bubbling phase, we must included it as a parameter.
		 */
		public override function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			trace("DEPRECATED - use unregisterEventListener instead.");
			var length:int = this.listeners.length; // Performance reasons.
			trace("---TemplateHost: removeEventListener", type, listener);
			trace("---TemplateHost: removeEventListener: length", length);
			for (var i:uint = 0; i < length; i++)
			{
				try
				{
					var eventListener:EventListener = this.listeners[i] as EventListener;
					trace("---TemplateHost: removeEventListener: eventListener", eventListener);
					if (eventListener.type === type &&
						eventListener.listener === listener && eventListener.useCapture === useCapture)
					{
						trace("---TemplateHost: will do super.removeEventListener on", eventListener);
						super.removeEventListener(eventListener.type, eventListener.listener, eventListener.useCapture);
						this.listeners.splice(i, 1);
						this.listenerId--;
					}
				}
				catch(e:Error)
				{
					trace("Could not remove ",eventListener.type,"in EventManager:removeEventListener. Try using registerEventListener and unregisterEventListener instead");
				}
			}
		}
		
		/**
		 * Removes all the listeners that have been registered with this manager. 
		 */
		public function removeAllListeners():void
		{
			trace("EventManager: This module is unstable, please use SharedData instead!");
			var length:uint = this.listeners.length; // Performance reasons.
			for (var i:int = length - 1; i >= 0; i--)
			{
				var eventListener:EventListener = this.listeners[i] as EventListener;
				try
				{
					removeEventListener(eventListener.type, eventListener.listener, eventListener.useCapture);
				}
				catch (e:Error)
				{
					trace(e);
				}
			}
			
			this.listeners = new Array();
		}
		
		/**
		 * registerDispatcher is a function used to tell the manager to listen for events. The EventManager will
		 * register itself as a listener to any events, even custom events of classes that register via this function.
		 */
		public function registerDispatcher(dispatcher:IRegisteredDispatcher):void
		{				
			trace("EventManager: This module is unstable, please use SharedData instead!");
			var events:Array = dispatcher.getEvents();
			var length:uint = events.length; // Performance reasons.
			for (var i:uint = 0; i < length; i++)
			{
				var eventName:String = events[i] as String;	
				dispatcher.addEventListener(eventName, redispatchEvent);			
			}
			
			this.dispatchers.push(dispatcher);
			
			trace("Registered dispatchers: " + this.dispatchers);
			
			this.dispatcherId++;			
			if (this.dispatcherId >= MAX_DISPATCHERS)
			{
				throw new RangeError(this.toString() + "WARNING: there are over " + MAX_DISPATCHERS + " dispatchers registered.");
			}
		}
		
		/**
		 * Redispatches any events recieved.
		 */		
		private function redispatchEvent(e:Event):void
		{
			trace("EventManager: This module is unstable, please use SharedData instead!");
			trace("Redispath event: " + e.type);
			dispatchEvent(e);
		}
		
		/**
		 * Removes all objects that have registered as dispatchers with the EventManager. This method will cycle through
		 * the dispatcher list and remove itself as a lister to all events for each object in the dispatcher list. 
		 */
		
		public function removeAllDispatchers():void
		{	
			trace("EventManager: This module is unstable, please use SharedData instead!");
			var length:uint = this.dispatchers.length; // Performance reasons.
			for (var i:uint = 0; i < length; i++)
			{
				var dispatcher:IRegisteredDispatcher = this.dispatchers[i];
				var events:Array = dispatcher.getEvents();			
				var eventCount:uint = events.length; // Performance reasons.
				for (var j:uint = 0; j < eventCount; j++)
				{
					var eventName:String = events[j];
					dispatcher.removeEventListener(eventName, redispatchEvent);
				}
			}
			
			this.dispatchers = new Array();
			this.dispatcherId = 0;
		}
	
		/**
		 * Removes all the dispatchers that have registed with a specified event type. Uses a normal
		 * equality check a == b on the string name of the event. If found it removes that object completely
		 * as a dispatcher including any other event that object registered to dispatch.
		 */
		public function removeDispactchersByType(type:String):Boolean
		{
			trace("EventManager: This module is unstable, please use SharedData instead!");
			var isFound:Boolean = false;
			var length:uint = this.dispatchers.length; // Performance reasons.
			for (var i:int = length - 1; i >= 0; i--)
			{
				var dispatcher:IRegisteredDispatcher = this.dispatchers[i];
				var events:Array = dispatcher.getEvents();
				var eventCount:uint = events.length; // Performance reasons.
				for (var j:uint = 0; j < eventCount; j++)
				{
					var eventName:String = events[j] as String;					
					if (eventName == type)
					{
						removeDispactchersByObject(dispatcher);
						isFound = true;
					}
				}
			}
			
			return isFound;
		}
		
		/**
		 * Removes all dispatchers that match the object passed as a param. Uses a strict equality check a === b 
		 * when comparing the param obj to the dispatcher list. If found it removes that object completely as a dispatcher
		 * including any event that object registered to dispatch.
		 */
		public function removeDispactchersByObject(registeredDispatcher:IRegisteredDispatcher):Boolean
		{
			trace("EventManager: This module is unstable, please use SharedData instead!");
			var isFound:Boolean = false;		
			var length:uint = this.dispatchers.length; // Performance reasons.
			for (var i:int = length - 1; i >= 0; i--)
			{
				var dispatcher:IRegisteredDispatcher = this.dispatchers[i];
				if (dispatcher === registeredDispatcher)
				{
					var events:Array = dispatcher.getEvents();			
					var eventCount:int = events.length; // Performance reasons.
					for (var j:uint = 0; j < eventCount ; j++)
					{
						var eventName:String = events[j] as String;
						dispatcher.removeEventListener(eventName, redispatchEvent);
					}
					
					this.dispatchers.splice(i , 1);
					this.dispatcherId--;
					isFound = true;
				}
			}
			
			return isFound;
		}
		
		/**
		 * Removes all listeners of a specified type. Uses a normal equality check a == b on the string name of the event.
		 */
		public function removeListenersByType(type:String):Boolean
		{
			trace("EventManager: This module is unstable, please use SharedData instead!");
			var isFound:Boolean = false;
			var length:uint = this.listeners.length; // Performance reasons.
			for (var i:uint = 0; i < length; i++)
			{
				var eventListener:EventListener = this.listeners[i] as EventListener;
				if (eventListener.type == type)
				{
					this.removeEventListener(eventListener.type, eventListener.listener, eventListener.useCapture);
					isFound = true;
				}
			}
			
			return isFound;
		}
		
		/**
		 * Removes all listeners that are set to trigger the specified function. Uses a normal equality
		 * check a == b on the function reference passed to this method against the list of listeners.
		 */
		public function removeListenersByFunction(listener:Function):Boolean
		{
			trace("EventManager: This module is unstable, please use SharedData instead!");
			var isFound:Boolean = false;		
			var length:uint = this.listeners.length; // Performance reasons.
			for (var i:int = length - 1; i >= 0; i--)
			{
				var eventListener:EventListener = this.listeners[i] as EventListener;
				if (eventListener.listener === listener)
				{
					this.removeEventListener(eventListener.type, eventListener.listener, eventListener.useCapture);
					isFound = true;
				}
			}
			
			return isFound;
		}
		
		/**
		 * List all dispatchers and listeners currently registerer.
		 */
		public function list():String
		{
			trace("EventManager: This module is unstable, please use SharedData instead!");
			return "List all registered dispathers and listeners\n" + listDispatchers() + listListeners();
		}
		
		/**
		 * List dispatchers currently registerer.
		 */
		public function listDispatchers():String 
		{
			trace("EventManager: This module is unstable, please use SharedData instead!");
			var returnValue:String = "Dispatchers:";
			var length:uint = this.dispatchers.length; // Performance reasons.
			for (var i:uint = 0; i < length; i++)
			{
				var dispatcher:IRegisteredDispatcher = this.dispatchers[i];
				returnValue += "\n\t" + dispatcher;
				
				var events:Array = dispatcher.getEvents();			
				var eventCount:uint = events.length; // Performance reasons.
				for (var j : uint = 0; j < eventCount ; j++)
				{
					var eventName:String = events[j] as String;
					returnValue += "\n\t\t" + eventName;
				}
				
				returnValue += "\n";
			}
			
			return returnValue;
		}
		
		/**
		 * List listeners currently registerer.
		 */
		public function listListeners():String 	{
			trace("EventManager: This module is unstable, please use SharedData instead!");
			var returnValue:String = "Listeners:";
			var length:uint = this.listeners.length; // Performance reasons.
			for (var i:uint = 0; i < length; i++)
			{
				var eventListener:EventListener	= this.listeners[i] as EventListener;
				returnValue += "\n\t" + eventListener.type;
			}
			
			return returnValue;
		}
	}
}








