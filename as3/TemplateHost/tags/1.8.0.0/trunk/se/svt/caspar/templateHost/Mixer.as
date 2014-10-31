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

//Mix the image in and out

package se.svt.caspar.templateHost {
	import flash.display.MovieClip;
	import flash.events.Event;

	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	public class Mixer {
		
		private var __tweener_controller__:MovieClip;
		private var _engineExists:Boolean = false;
		private var _tweenList:Array;

		public function mixIn(target:MovieClip, duration:uint):void
		{ 
			
			if (duration > 1)
			{
				if (!_engineExists) 
				{
					startEngine();
				}
				var tweenObj:Object = new Object();
				tweenObj.target = target;
				tweenObj.duration = duration;
				tweenObj.counter = 0;
				tweenObj.action = "mixIn";
				
				_tweenList.push(tweenObj);
			} 
			else 
			{
				target.alpha = 1;
			}
		}
		
		public function mixOut(target:MovieClip, duration:uint, callback:Function):void
		{
			if(duration > 1) 
			{
				
				if (!_engineExists) 
				{
					startEngine();
				}
				
				var targetIndex:int = isTweening(target);
				
				if (targetIndex != -1) 
				{
					_tweenList[targetIndex].duration = duration;
					_tweenList[targetIndex].counter = 0;
					_tweenList[targetIndex].step = _tweenList[targetIndex].target.alpha;
					_tweenList[targetIndex].action = "mixOut";
					_tweenList[targetIndex].callback = callback;
				} 
				else
				{
					var tweenObj:Object = new Object();
					tweenObj.target = target;
					tweenObj.duration = duration;
					tweenObj.step = tweenObj.target.alpha;
					tweenObj.counter = 0;
					tweenObj.action = "mixOut";
					tweenObj.callback = callback;
					_tweenList.push(tweenObj);
				}
			} 
			else
			{
				callback(target);
				target.alpha = 0;
			}
		}
		
		private function isTweening(target:MovieClip):int
		{
			if (_tweenList.length == 0)
			{
				return -1;
			} 
			else
			{
				for (var i:int = 0; i < _tweenList.length; i++) 
				{
					if (target == _tweenList[i].target)
					{
						return i;
						break;
					}
				}
				return -1;
			}
		}
		
		private function updateTweens():Boolean
		{
			if (_tweenList.length == 0) return false;
			for (var i:int = 0; i < _tweenList.length; i++)
			{
				if (_tweenList[i].action == "mixIn") 
				{
					if (_tweenList[i].counter == _tweenList[i].duration) 
					{
						_tweenList[i].target.alpha = 1;
						_tweenList.splice(i, 1);
					}
					else 
					{
						_tweenList[i].target.alpha = _tweenList[i].counter / _tweenList[i].duration;
						_tweenList[i].counter ++;
					}
				} 
				else if (_tweenList[i].action == "mixOut") 
				{
					if (_tweenList[i].counter == _tweenList[i].duration) 
					{
						_tweenList[i].target.alpha = 0;
						_tweenList[i].callback(_tweenList[i].target);
						_tweenList.splice(i, 1);
					} 
					else 
					{
						_tweenList[i].target.alpha = _tweenList[i].step-((_tweenList[i].counter / _tweenList[i].duration)*_tweenList[i].step);
						_tweenList[i].counter ++;
					}
				}
			}
			return true;
		}
		
		
		private function onEnterFrame(evt:Event):void 
		{
			var hasUpdated:Boolean = false;
			hasUpdated = updateTweens();
			if (!hasUpdated) stopEngine();
		}
		
		private function stopEngine():void 
		{
			_engineExists = false;
			_tweenList = null;
			__tweener_controller__.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			__tweener_controller__ = null;
		}
		
		private function startEngine():void 
		{
			_engineExists = true;
			_tweenList = new Array();
			
			__tweener_controller__ = new MovieClip();
			__tweener_controller__.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
	}
}