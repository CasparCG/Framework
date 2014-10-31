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

//This is the standard implementation of the document class for the templates. Extend this class to create your own implementation of a CasparTemplate

package se.svt.caspar.template {
	import flash.display.MovieClip;
	import flash.events.ErrorEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.utils.ByteArray;
	import se.svt.caspar.ComponentDataBuffer;
	import se.svt.caspar.ICommunicationManager;
	import se.svt.caspar.ITemplateContext;
	import se.svt.caspar.template.components.ComponentAssets;
	import se.svt.caspar.template.components.ICasparComponent;	
	
	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	public class CasparTemplate extends MovieClip implements ICaspar2Template
	{
		//Variables set by brew
		private var _description:XML;
		private var _originalWidth:Number;
		private var _originalHeight:Number;
		private var _originalFramerate:Number;
		private var _stopOnFirstFrame:Boolean;
		
		//Holds the reference to the CommunicationManager
		private var _communicationManager:ICommunicationManager;
		//The virtual layer that the template is rendered on by the template host
		private var _layer:int;
		
		//Holds the reference to the ComponentDataBuffer
		private var _componentDataBuffer:ComponentDataBuffer;
		//The filename, is set by the Template host
		private var _templateName:String;
		
		/**
		 * Constructor
		 */
		public function CasparTemplate()
		{
			_componentDataBuffer = new ComponentDataBuffer();
			//trace("lyssnar på ofångade");
			//this.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);
		}
		
		/**
		 * Called by template host before the template is removed. Override predispose to be able to clean up event listeners and alike.
		 */
		public final function dispose():void
		{
			preDispose(); 
			_componentDataBuffer.diposeAllComponents();
		}
		
		/**
		 * Called by template host after the template is loaded. Override postInitialize to be abe to access the communicationManager.
		 * @param	context contains a reference to the communication manager interface.
		 */
		public final function initialize(context:ITemplateContext):void
		{
			_communicationManager = context.communicationManager;
			_layer = context.layer;
			postInitialize();
		}
		
		/**
		 * Will dispatch a "remove template"-event which will be recieved by the template host and will mark the template for destruction. Is called by the standard implementarion of Stop() if there is no label called "outro". If there is an "outro"-label brew will insert a call to removeTemplate() on the first keyframe containing stop() after the "outro"-labelled keyframe, if none, on the last frame. If the standard implementation of Stop() overridden this method MUST be called manually.
		 */
		protected final function removeTemplate():void
		{
			dispatchEvent(new CasparTemplateEvent(CasparTemplateEvent.REMOVE_TEMPLATE, this));
		}
		
		/**
		 * Registers a component to the component data buffer. If there is buffered data the component will recieve it.
		 */
		public final function registerComponent(instance:ICasparComponent):void 
		{
			_componentDataBuffer.componentLoaded(instance.name, instance);
		}
		
		/* INTERFACE se.svt.caspar.template.ICasparTemplate */
		
		//////
		// Calls from the External interface passed by the template host.
		//////
		
		/**
		 * Will play the template if there is no stop() in the first frame.
		 */
		public function Play():void
		{
			try
			{
				if (!stopOnFirstFrame)
				{
					this.play();
				}
				
			}
			catch (e:Error)
			{
				this.play();
			}
		}
		
		/**
		 * WARNING! If you override the Stop function be sure to call super.Stop() or removeTemplate() to remove the template from the template host.
		 * Will stop and remove the template after the outro animation, if any.
		 */
		public function Stop():void
		{
			try 
			{
				this.gotoAndPlay("outro");
				this.addFrameScript(this.currentFrame-1, play);
			}
			catch (e:Error)
			{
				this.removeTemplate();
			}
		}
		
		/**
		 * Will make the template continue from the current frame. Will be ignored if the current frame label is "outro", then Stop() must be called.
		 */
		public function Next():void
		{
			if (this.currentLabel != "outro") 
			{
				this.play();
			}
		}
		
		/**
		 * Will jump to a defined label.
		 * @param	label The label to go to
		 */
		public final function GotoLabel(label:String):void
		{
			try 
			{
				this.gotoAndPlay(label);
			}
			catch (e:Error)
			{
				throw new ReferenceError("The label " + label + " was not found on layer " + layer);
			}
		}
		
		/**
		 * Send data to the componentDataBuffer which will be passed to the component(s) when instatiated.
		 * @param	xmlData the data sent from the template host
		 */
		public function SetData(xmlData:XML):void 
		{	
			for each (var element:XML in xmlData.elements()) 
			{
				_componentDataBuffer.SetData(element.@id, element);
			}
		}
		
		public function SetDataObject(dataObject:ComponentAssets):void
		{
			var xmlData:XML = new XML(dataObject.templateXML);
			
			for each (var element:XML in xmlData.elements())
			{
				_componentDataBuffer.SetData(element.@id, element);
			}
			
			//set assets
			for (var i:int = 0; i < dataObject.assets.length; i++)
			{
				_componentDataBuffer.SetDataObject(dataObject.assets[i]);
			}
		}
		
		//TODO: Move to template context
		public function set templateName(value:String):void 
		{
			_templateName = value;
		}
		
		public function get templateName():String 
		{
			return _templateName;
		}

		/**
		 * Will try to execute a method on the loaded template.
		 * @param	methodName The name of the method to be executed
		 */
		public final function ExecuteMethod(methodName:String):void
		{
			try
			{
				this[methodName].call();
			}
			catch (e:Error)
			{
				throw new ReferenceError("The method " + methodName + " was not found on layer " + layer);
			}
		}
		
		/**
		 * Will return the description of the loaded template.
		 * @return the description
		 */
		public final function GetDescription():String 
		{ 
			TraceToLog("GetDescription: " + description.toString());
			return description.toString();
		}
		
		/**
		 * Sends an external call to caspar
		 * @param	methodName The method name
		 * @param	...args The arguments
		 */
		public final function ExternalCall(methodName:String, ...args):void
		{
			var e:CasparTemplateEvent = new CasparTemplateEvent(CasparTemplateEvent.EXTERNAL_CALL, this);
			e.methodName = methodName;
			e.args = args;
			dispatchEvent(e);
		}
		
		/**
		 * Write to the caspar log file
		 * @param	message the message to trace
		 */
		public function TraceToLog(message:String):void 
		{
			try
			{
				var e:CasparTemplateEvent = new CasparTemplateEvent(CasparTemplateEvent.TRACE_TO_LOG, this);
				e.message = message;
				dispatchEvent(e);
			}
			catch (e:Error)
			{
				trace(e);
			}
		}

		/**
		 * Override to be able to access the sharedData and eventManager instances. Called by template host after the template is loaded.
		 */
		public function postInitialize():void {	}
		
		/**
		 * Override to be able to unregister all event listeners you have created (exept the ones registered via the CommunicationManager which are disposed automatically). This method is called by the TemplateHost just before the template is removed.
		 */
		public function preDispose():void
		{
			
		}
		
		//TODO: Check if this reference is overused
		/**
		 * Returns a reference to the movieclip of the template.
		 */
		public final function get movieClip():MovieClip
		{
			return this;
		}
		
		/**
		 * Will return the original stageWidth, set by brew.
		 */
		public final function get originalWidth():Number { return _originalWidth; }
		
		public final function set originalWidth(value:Number):void 
		{
			_originalWidth = value;
		}
		
		/**
		 * Will return the original stageHeight, set by brew.
		 */
		public final function get originalHeight():Number { return _originalHeight; }
		
		public final function set originalHeight(value:Number):void 
		{
			_originalHeight = value;
		}
		
		/**
		 * Will return the original frame rate, set by brew.
		 */
		public final function get originalFrameRate():Number { return _originalFramerate; }
		
		public final function set originalFrameRate(value:Number):void 
		{
			_originalFramerate = value;
		}
		
		/**
		 * Will be true if brew found a stop label on the first frame
		 */
		public final function get stopOnFirstFrame():Boolean { return _stopOnFirstFrame; }
		
		public final function set stopOnFirstFrame(value:Boolean):void 
		{
			_stopOnFirstFrame = value;
		}
		
		///////////////////////////////////////////////
		
		/**
		 * Will return a reference to the communication manager, only accessible after the the postInitialize method has been executed.
		 */		
		public final function get communicationManager():ICommunicationManager { return _communicationManager; }
		
		/**
		 * Will return the description of the loaded template.
		 */
		public final function get description():XML { return _description; }
		
		public final function set description(value:XML):void 
		{
			_description = value;
		}
		
		/**
		 * Returns the version of the template
		 */		
		public final function get version():String
		{
			return _description.@version;
		}
		
		/**
		 * Returns the layer that the template is rendered on in the template host
		 */
		public final function get layer():int { return _layer; }

	}
}