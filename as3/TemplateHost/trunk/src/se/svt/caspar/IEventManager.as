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
	
	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	public interface IEventManager
	{
		/**
		 * DEPRECATED - use registerEventListener instead.
		 * Registers an event listener object with the EventManager object so that the listener receives notification of an event redispatched by the EventManager.
		 * @param	type The type of event.
		 * @param	listener The listener function that processes the event. This function must accept an Event object as its only parameter and must return nothing.
		 * @param	useCapture (default = false) — Determines whether the listener works in the capture phase or the target and bubbling phases. If is set to true, the listener processes the event only during the capture phase and not in the target or bubbling phase. If is true, the listener processes the event only during the target or bubbling phase. To listen for the event in all three phases, call twice, once with set to false, then again with set to true.
		 * @param	priority The priority level of the event listener. The priority is designated by a signed 32-bit integer. The higher the number, the higher the priority. All listeners with priority n are processed before listeners of priority n-1. If two or more listeners share the same priority, they are processed in the order in which they were added. The default priority is 0. 
		 * @param	useWeakReference (default = false) — Determines whether the reference to the listener is strong or weak. A strong reference (the default) prevents your listener from being garbage-collected. A weak reference does not. 
		 */
		function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void;
		/**
		 * DEPRECATED - use unregisterEventListener instead. 
		 * Removes a listener from the EventManager object. If there is no matching listener registered with the EventManager object, a call to this method has no effect.
		 * 
		 * @param	type The type of event.
		 * @param	listener The listener object to remove. 
		 * @param	useCapture (default = false) — Specifies whether the listener was registered for the capture phase or the target and bubbling phases. If the listener was registered for both the capture phase and the target and bubbling phases, two calls to are required to remove both, one call with set to false, and another call with set to true.
		 */
		function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void;
		
		/**
		 * Registers an event listener object with the EventManager object so that the listener receives notification of an event redispatched by the EventManager.
		 * @param	listenerReference reference to registerd object.
		 * @param	type The type of event.
		 * @param	listener The listener function that processes the event. This function must accept an Event object as its only parameter and must return nothing.
		 * @param	useCapture (default = false) — Determines whether the listener works in the capture phase or the target and bubbling phases. If is set to true, the listener processes the event only during the capture phase and not in the target or bubbling phase. If is true, the listener processes the event only during the target or bubbling phase. To listen for the event in all three phases, call twice, once with set to false, then again with set to true.
		 * @param	priority The priority level of the event listener. The priority is designated by a signed 32-bit integer. The higher the number, the higher the priority. All listeners with priority n are processed before listeners of priority n-1. If two or more listeners share the same priority, they are processed in the order in which they were added. The default priority is 0. 
		 * @param	useWeakReference (default = false) — Determines whether the reference to the listener is strong or weak. A strong reference (the default) prevents your listener from being garbage-collected. A weak reference does not. 
		 */
		function registerEventListener(listenerReference:Object, type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void;
		/**
		 * Removes a listener from the EventManager object. If there is no matching listener registered with the EventManager object, a call to this method has no effect.
		 * 
		 * @param	listenerReference reference to registerd object.
		 * @param	type The type of event.
		 * @param	listener The listener object to remove. 
		 * @param	useCapture (default = false) — Specifies whether the listener was registered for the capture phase or the target and bubbling phases. If the listener was registered for both the capture phase and the target and bubbling phases, two calls to are required to remove both, one call with set to false, and another call with set to true.
		 */
		function unregisterEventListener(listenerReference:Object, type:String, listener:Function, useCapture:Boolean = false):void;
		
		
		
		
		/**
		 * Registers a template as an dispatcher of events trough the EventManager object. You must implement the IRegisteredDispatcher and define witch events the EventManager should redispatch.
		 * 
		 * @param	dispatcher The template, usually [this].
		 */
		function registerDispatcher(dispatcher:IRegisteredDispatcher):void
		
		/**
		 * List all dispatchers and listeners currently registerer.
		 */
		function list():String
		
	}
	
}