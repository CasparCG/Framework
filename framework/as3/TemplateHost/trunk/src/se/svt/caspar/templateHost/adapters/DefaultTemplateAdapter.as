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

// Wraps templates older than version 1.7 to make it compatible with the ICasparTemplate interface

//TODO: Split into two adapters, one for < 1.7 and one for 1.7-1.8 templates

package se.svt.caspar.templateHost.adapters 
{
	import flash.display.MovieClip;
	import se.svt.caspar.ComponentDataBuffer;
	import se.svt.caspar.ITemplateContext;
	import se.svt.caspar.template.CasparTemplateEvent;
	import se.svt.caspar.template.ICasparTemplate;
	
	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	public class DefaultTemplateAdapter extends MovieClip implements ICasparTemplate
	{
		
		private var _template:*;
		
		private var _originalWidth:Number;
		private var _originalHeight:Number;
		private var _originalFramerate:Number;
		private var _stopOnFirstFrame:Boolean;
		
		//The layer that the template is rendered on by the template host
		private var _layer:int;
		
		public function DefaultTemplateAdapter(template:*) 
		{
			_template = template;
			this.addChild(_template);
			_template.stop();
			try { 
				_template.parent = this;
				_originalWidth = _template.nOriginalWidth;
				_originalHeight = _template.nOriginalHeight;
			} 
			catch (e:Error) {
				_originalWidth = 768;
				_originalHeight = 576;
			}
			try 
			{
				_originalFramerate = template.nOriginalFrameRate;
			}
			catch (e:Error) 
			{
				_originalFramerate = 50;
			}
			
			
			try
			{
				trace( "sätter _stopOnFirstFrame",_template.stopOnFirstFrame );
				_stopOnFirstFrame = _template.stopOnFirstFrame;
			}
			catch (e:Error) 
			{
				trace( "sätter _stopOnFirstFrame tvingad till false" );
				_stopOnFirstFrame = false;
			}
			
			trace("skapar en adapter för ", template, "origWidth = ", originalWidth);
		}
		
		/* INTERFACE se.svt.caspar.template.ICasparTemplate */
		
		/**
		 * Will dispatch a "remove template"-event which will be recieved by the template host and will mark the template for destruction. Is called by the standard implementarion of Stop() if there is no label called "outro". If there is an "outro"-label brew will insert a call to removeTemplate() on the first keyframe containing stop() after the "outro"-labelled keyframe, if none, on the last frame. If the standard implementation of Stop() overridden this method MUST be called manually.
		 */
		public final function removeTemplate(template:*):void
		{
			dispatchEvent(new CasparTemplateEvent(CasparTemplateEvent.REMOVE_TEMPLATE, this));
		}
		
		public function Play():void
		{
			try
			{
				if (!stopOnFirstFrame)
				{
					//trace("det blev rätt", stopOnFirstFrame);
					_template.play();
				}
				
			}
			catch (e:Error)
			{
				//trace("det blev fel", e);
				_template.play();
			}
			
		}
		
		override public function stop():void 
		{
			trace("vill stoppa ", _template);
			_template.stop();
		}
		
		public function Stop():void
		{
			try 
			{
				_template.gotoAndPlay("outro");
				_template.addFrameScript(_template.currentFrame-1, play);
				trace("Finns ett outro, spela och sen skicka remove");
			}
			catch (e:Error)
			{
				trace("Finns inget outro, skicka remove");
				removeTemplate(_template);
			}
		}
		
		public function Next():void
		{
			if (_template.currentLabel != "outro") 
			{
				_template.play();
			}
		}
		
		public function GotoLabel(label:String):void
		{
			try 
			{
				_template.gotoAndPlay(label);
			}
			catch (e:Error)
			{
				throw new ReferenceError("The label " + label + " was not found on layer " + layer);
			}
		}
		
		public function SetData(xmlData:XML):void
		{
			try
			{
				_template.setData(xmlData);
			}
			catch (e:Error)
			{
				throw new Error("Could not set data on layer " + layer+ ". The method setData was not found");
			}
		}
		
		public function ExecuteMethod(methodName:String):void
		{
			try
			{
				_template[methodName].call();
			}
			catch (e:Error)
			{
				throw new ReferenceError("The method " + methodName + " was not found on layer " + layer);
			}
		}
		
		public function GetDescription():String
		{
			try
			{
				return _template.getDescription();
			}
			catch (e:Error)
			{
				return "";
			}
			finally
			{
				return "";
			}
		}
		
		public function initialize(context:ITemplateContext):void
		{
			_layer = context.layer;
		}
		
		public function dispose():void
		{
			_template.stop();
			removeChild(_template);
			_template = null;
		}
		
		/* INTERFACE se.svt.caspar.template.ICasparTemplate */
		
		public function get version():String
		{
			return "1.6";
		}
		
		public function get layer():int
		{
			return _layer;
		}
		
		override public function get loaderInfo():flash.display.LoaderInfo 
		{
			return _template.loaderInfo;
		}
		
		public function get movieClip():MovieClip
		{
			return this;
		}
		
		public function get originalWidth():Number
		{
			return _originalWidth;
		}
		
		public function get originalHeight():Number
		{
			return _originalHeight;
		}
		
		public function get originalFrameRate():Number
		{
			return _originalFramerate;
		}
		
		public function get stopOnFirstFrame():Boolean 
		{
			return _stopOnFirstFrame; 
		}
		
	}
	
}