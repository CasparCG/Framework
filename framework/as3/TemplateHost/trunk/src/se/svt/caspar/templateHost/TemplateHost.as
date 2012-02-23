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

/*Future upgrades: 
	* Extend GetInfo so that it returns info about loaded templates and layers etc. 
	* Implement ExternalCall
*/

package se.svt.caspar.templateHost 
{
	 [SWF(width="1920", height="1080", frameRate="50", backgroundColor="#FFFFFF")]
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.xml.XMLNode;
	import se.svt.caspar.CommunicationManager;
	import se.svt.caspar.template.CasparTemplateEvent;
	import se.svt.caspar.template.ICaspar2Template;
	import se.svt.caspar.template.ICasparTemplate;
	import se.svt.caspar.TemplateContext;
	import se.svt.caspar.templateHost.externalCommands.AddCommand;
	import se.svt.caspar.templateHost.externalCommands.CommandEvent;
	import se.svt.caspar.templateHost.externalCommands.GetDescriptionCommand;
	import se.svt.caspar.templateHost.externalCommands.InvokeCommand;
	import se.svt.caspar.templateHost.externalCommands.NextCommand;
	import se.svt.caspar.templateHost.externalCommands.PlayCommand;
	import se.svt.caspar.templateHost.externalCommands.SetDataCommand;
	import se.svt.caspar.templateHost.externalCommands.StopCommand;
	import se.svt.caspar.Version;

	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	public class TemplateHost extends MovieClip implements ITemplateHost
	{

		//CONSTANTS
		public static const WIDE_SCREEN:Number = 16/9;
		public static const STANDARD:Number = 4 / 3;
		private var SCREEN_WIDTH:Number;
		private var SCREEN_HEIGHT:Number;
		private var ORIGINAL_FRAMERATE:int;

		// Container for all loaded templates
		private var _templateContainer:Sprite = new Sprite();	
		//keeps track of number of templates loaded with full / half framerame
		private var _nFullFramerateCounter:int = 0; 
		private var _nHalfFramerateCounter:int = 0;
		
		//Holds the CommunicationManager instance
		private var _communicationManager:CommunicationManager;
		
		//Holds the GenericCommandBuffer instance
		private var _externalCommandsBuffer:ExternalCommandsBuffer;
		
		//Holds the Mixer instance
		private var _mixer:Mixer;
		
		private var _loadedTemplates:LoadedTemplates;
		
		public function TemplateHost():void
		{
			if (!stage) 
			{
				this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			} else 
			{
				onAddedToStage();
			}
		}

		private function onAddedToStage(e:Event = null):void 
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			SCREEN_WIDTH = stage.stageWidth;
			SCREEN_HEIGHT = stage.stageHeight;
			ORIGINAL_FRAMERATE = stage.frameRate;
			
			
			//trace("-> CasparCG Template Host v."+VERSION+ " @"+SCREEN_WIDTH+"X"+ SCREEN_HEIGHT + " " + stage.frameRate+"fps");
			_communicationManager = new CommunicationManager();
			_externalCommandsBuffer = new ExternalCommandsBuffer();
			_mixer = new Mixer();
			_loadedTemplates = new LoadedTemplates();
			
			if (ExternalInterface.available)
			{
				ExternalInterface.marshallExceptions = true;
				ExternalInterface.addCallback("Add", Add);
				ExternalInterface.addCallback("Delete", Delete);
				ExternalInterface.addCallback("SetData", SetData);
				ExternalInterface.addCallback("Invoke", Invoke);
				ExternalInterface.addCallback("Play", Play);
				ExternalInterface.addCallback("Stop", Stop);
				ExternalInterface.addCallback("Next", Next);
				ExternalInterface.addCallback("GetInfo", GetInfo);
				ExternalInterface.addCallback("GetDescription", GetDescription);
			}

			_externalCommandsBuffer.addEventListener(CommandEvent.ON_ERROR, onTemplateHostError);
			_externalCommandsBuffer.addEventListener(CommandEvent.GET_DESCRIPTION, onGetDescription);
			_externalCommandsBuffer.addEventListener(CommandEvent.BUFFER_EMPTY, onBufferEmpty);
			_externalCommandsBuffer.addEventListener(CommandEvent.COMMAND_FINISHED, onCommandFinished);
			this.addEventListener(CommandEvent.COMMAND_FINISHED, onCommandFinished);
			this.addEventListener(CommandEvent.ON_ERROR, onTemplateHostError);
			_externalCommandsBuffer.addEventListener(CommandEvent.DEBUG_MESSAGE, onDebugLog);
			
			addChild(_templateContainer);
			
			//Listen for uncaught errors
			this.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
			
			trace(GetInfo());
		}
		
		
		//External input
		//TODO: Should we really pass a reference to TemplateHost when we create new commands, can we solve this in a better way?
		
		/**
		 * Loads a template to the template host
		 * @param	layer the virtual layer the template should be loaded on
		 * @param	templateName the name of the .ft file without extension
		 * @param	playOnLoad Determines if the template should play directly when loaded
		 * @param	invoke If there is a timeline label with this name, goto and play, else if there is a function with this name, execute it directly when loaded
		 * @param	xmlData Data to send to the template when loaded
		 */
		public function Add(layer:int, templateName:String, playOnLoad:Boolean, invoke:String, xmlData:String):void 
		{
			//_legacyHost.Add(layer, templateName, playOnLoad, invoke, xmlData);
			onCommandRecieved("@Add@" + layer);
			_externalCommandsBuffer.addCommand(new AddCommand(layer, templateName, invoke, new XML(xmlData), new TemplateContext(_communicationManager, layer), this));
			if (playOnLoad)
			{
				_externalCommandsBuffer.addCommand(new PlayCommand([layer], _templateContainer, this));
			}
		}
		
		/**
		 * Plays loaded templates
		 * @param	layers The layers to be played
		 */
		public function Play(layers:Array):void 
		{
			//_legacyHost.Add(layers);
			onCommandRecieved("@Play@" + layers.toString());
			_externalCommandsBuffer.addCommand(new PlayCommand(layers, _templateContainer, this));
		}
		
		/**
		 * Stops playing templates
		 * @param	layers The layers to be played
		 * @param	mixOutDuration The mix out duration in frames. If 0 the Stop function on the template is called, if 1 the template is directly removed (cut), if > 1 the template is mixed out then removed. 
		 */
		public function Stop(layers:Array, mixOutDuration:uint):void 
		{
			onCommandRecieved("@Stop@" + layers.toString());
			_externalCommandsBuffer.addCommand(new StopCommand(layers, mixOutDuration, _templateContainer, this));
		}
	
		/**
		 * Deletes a template
		 * @param	layers The layers to be deleted
		 */
		public function Delete(layers:Array):void 
		{
			onCommandRecieved("@Delete@" + layers.toString());
			_externalCommandsBuffer.addCommand(new StopCommand(layers, 1, _templateContainer, this));
		}
		
		/**
		 * Sets data to a template
		 * @param	layers The layers to set the data to
		 * @param	xmlData The data to set
		 */
		public function SetData(layers:Array, xmlData:String):void 
		{
			onCommandRecieved("@SetData@" + layers.toString());
			_externalCommandsBuffer.addCommand(new SetDataCommand(layers, new XML(xmlData), this));
		}
		
		/**
		 * Steps a template
		 * @param	layers The layers to execute the command on
		 */
		public function Next(layers:Array):void 
		{
			onCommandRecieved("@Next@" + layers.toString());
			_externalCommandsBuffer.addCommand(new NextCommand(layers, this));
		}
		
		//TODO: Check the possiblity to recieve args
		/**
		 * Invokes a label or a method on a template
		 * @param	layers The layers to execute the command on
		 * @param	label The label to invoke
		 */
		public function Invoke(layers:Array, label:String):void 
		{
			onCommandRecieved("@Invoke@" + layers.toString());
			_externalCommandsBuffer.addCommand(new InvokeCommand(layers, label, this));
		}
		
		/**
		 * Returns a description of the template(s)
		 * @param	layers The layers to execute the command on
		 */
		public function GetDescription(layers:Array):String 
		{
			onCommandRecieved("@GetDescription@" + layers.toString());
			_externalCommandsBuffer.addCommand(new GetDescriptionCommand(layers, this));
			return "This function is asynchronous. The result is returned by the external call function OnTemplateDescription";
		}	
		
		/**
		 * Returns info about the template host
		 * @return The info
		 */		
		public function GetInfo():String 
		{
			onCommandRecieved("@GetInfo@?");
			
			//Build layer info xml
			var infoXML:XML = new XML(<TemplateHostInfo version={Version.getVersion()} width={SCREEN_WIDTH} height={SCREEN_HEIGHT} fps={stage.frameRate} totalMemory={System.totalMemoryNumber} freeMemory={System.freeMemory} loadedTemplates={_loadedTemplates.numberOfLoadedTemplates}></TemplateHostInfo>);
			var layers:XML = new XML(<Layers></Layers>);
			if (_loadedTemplates != null) 
			{
				var loadedTemplates:Vector.<LoadedTemplateItem> = _loadedTemplates.getLoadedTemplates();
				
				for (var i:int = 0; i < loadedTemplates.length; i++)
				{
					var node:XML = new XML(<layer/>);
					if (loadedTemplates[i].playingTemplate != null) 
					{
						node.@id = loadedTemplates[i].playingTemplate.layer;
						if (loadedTemplates[i].playingTemplate as ICaspar2Template != null)
						{
							node.@visibleTemplate = ICaspar2Template(loadedTemplates[i].playingTemplate).templateName;
						}
						else
						{
							node.@visibleTemplate = "Template older than 2.0";
						}
					}
					
					if (loadedTemplates[i].queuedTemplate != null) 
					{
						node.@id = loadedTemplates[i].queuedTemplate.layer;
						if (loadedTemplates[i].queuedTemplate as ICaspar2Template != null)
						{
							node.@queuedTemplate = ICaspar2Template(loadedTemplates[i].queuedTemplate).templateName;
						}
						else
						{
							node.@queuedTemplate = "Template older than 2.0";
						}
					}
					
					layers.appendChild(node);
				}
			}
			infoXML.appendChild(layers);
			
			if (ExternalInterface.available)
			{
				ExternalInterface.call("OnGetInfo", infoXML);
			}
			else
			{
				trace("ExternalInterface.call GetInfo", infoXML);
			}
			
			return infoXML.toString();
		}
		
		//External output
		
		/**
		 * Called by the ExternalCommandBuffer when empty. Sends an external call to IsEmpty if there is no loaded templates.
		 */
		public function isTemplateHostEmpty():void 
		{
			if (ExternalInterface.available)
			{
				if (_loadedTemplates.numberOfLoadedTemplates == 0)
				{
					ExternalInterface.call("IsEmpty");
				}
			}
			else
			{
				if (_loadedTemplates.numberOfLoadedTemplates == 0)
				{
					trace("ExternalInterface.call IsEmpty");
				}
			}
		}
		
		/**
		 * Sends an external call then a template is displayed (played)
		 * @param	e The command event instance
		 */
		private function onTemplateIsPlaying(e:CommandEvent):void
		{
			if (ExternalInterface.available)
			{
				ExternalInterface.call("OnDisplayedTemplate", e.layer);
			}
			else
			{
				trace("ExternalInterface.call OnDisplayedTemplate, " + e.layer);
			}
		}
		
		/**
		 * Sends an external call when an error is thrown by the template host
		 * @param	e The command event instance
		 */
		public function onTemplateHostError(e:CommandEvent):void 
		{
			if (ExternalInterface.available)
			{
				trace("\n =>TEMPLATE HOST: onTemplateHostError: " + e.data);
				ExternalInterface.call("OnError", (e.data + "@"));
			}
			else
			{
				trace("ExternalInterface.call OnError: " + e.data);
			}
		}
		
		/**
		 * Sends an external call when GetDescription is called
		 * @param	e The command event instance
		 */
		private function onGetDescription(e:CommandEvent):void 
		{
			if (ExternalInterface.available)
			{
				trace("\n =>TEMPLATE HOST: OnGetDescription layer: " + e.layer + " data: " + e.data);
				ExternalInterface.call("OnTemplateDescription", e.layer, (e.data + "@"));
			}
			else
			{
				trace("ExternalInterface.call OnTemplateDescription: " +  e.layer + " " + e.data);
			}
		}
		
		/**
		 * Sends an external call when a command is recieved by the template host
		 * @param	command The command that is recieved
		 */
		private function onCommandRecieved(command:String):void
		{
			if (ExternalInterface.available)
			{
				trace("\n =>TEMPLATE HOST: OnCommandRecieved: " + command.toString());
				ExternalInterface.call("OnCommand", "Command recieved " + (command + "@"));
			}
			else
			{
				trace("ExternalInterface.call OnCommand: Command recieved: " + command);
			}
		}
		
		/**
		 * Sends an external call when a command is successfully executed
		 * @param e The command event instance
		 */
		private function onCommandFinished(e:CommandEvent):void 
		{
			if (ExternalInterface.available)
			{
				trace("\n =>TEMPLATE HOST: OnCommandFinished: " + e.success + ", " + e.layer + ", " + e.data);
				ExternalInterface.call("OnActivity", "Command finished " + (e.data + "@"));
			}
			else
			{
				trace("ExternalInterface.call OnActivity: Command finished: " + e.data);
			}
		}
		
		//TODO: Implement
		/**
		 * Sends an external call from a template
		 * @param command The command that is recieved
		 */
		// TO BE IMPLEMENTED
		private function onExternalCall(e:CasparTemplateEvent):void
		{
			//if (ExternalInterface.available)
			//{
				//trace("\n =>TEMPLATE HOST: onExternalCall: ",e.methodName, e.template.layer, e.args.length);
				//
				//for (var i:int=0; i< args.length; i++){
					//trace(args[i]);
				//}
				//
				//ExternalInterface.call("OnNotify", methodName, args);
			//}
		}
		
		private function onTraceToLog(e:CasparTemplateEvent):void
		{
			if (ExternalInterface.available)
			{
				ExternalInterface.call("Activity", "Flash trace: " + e.message);
			}
			else
			{
				trace("onTraceLog: ", e.message);
			}
		}
		
		private function onDebugLog(e:CommandEvent):void
		{
			//if (ExternalInterface.available)
			//{
				//ExternalInterface.call("Activity", "Flash debug message: " + e.data);
			//}
			//else
			//{
				//trace("DEBUG: ", e.data);
			//}
			//trace("DEBUG: ", e.data);
		}
		
		/////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////
		
	
		

		private function registerTemplateFramerate(template:ICasparTemplate):void 
		{
			var templateFramerate:Number;

			try 
			{
				templateFramerate = template.originalFrameRate;
			} 
			catch (e:Error) 
			{
				templateFramerate = ORIGINAL_FRAMERATE;
			}
			
			if (templateFramerate == ORIGINAL_FRAMERATE/2) 
			{
				if (_nFullFramerateCounter == 0)
				{
					stage.frameRate = ORIGINAL_FRAMERATE/2;
				}
				++_nHalfFramerateCounter;
			}
			else 
			{
				if (_nFullFramerateCounter == 0)
				{
					stage.frameRate = ORIGINAL_FRAMERATE;
				}
				++_nFullFramerateCounter;
			}
		}
		
		private function removeTemplateFramerate(template:ICasparTemplate):void 
		{
			var templateFramerate:Number;

			try 
			{
				templateFramerate = template.originalFrameRate;
			} 
			catch (e:Error) 
			{
				templateFramerate = ORIGINAL_FRAMERATE;
			}
			
			if (templateFramerate == ORIGINAL_FRAMERATE/2) 
			{
				--_nHalfFramerateCounter;
			}
			else 
			{
				--_nFullFramerateCounter;
				if (_nFullFramerateCounter <= 0 && _nHalfFramerateCounter > 0) 
				{
					stage.frameRate = ORIGINAL_FRAMERATE/2;
				}
			}
		}
		
		private function onRemoveTemplate(e:CasparTemplateEvent):void 
		{
			removeTemplate(e.template);
		}
		
		private function onBufferEmpty(e:CommandEvent):void 
		{
			onDebugLog(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "buffer is empty"));
			isTemplateHostEmpty();
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////

		/* INTERFACE se.svt.caspar.templateHost.ITemplateHost */
		
		public function get loadedTemplates():LoadedTemplates { return _loadedTemplates; }
		
		public function get mixer():Mixer {	return _mixer;	}
		
		public function get screenHeight():Number { return SCREEN_HEIGHT; }
		
		public function set screenHeight(value:Number):void 
		{
			SCREEN_HEIGHT = value;
		}
		
		public function get screenWidth():Number { return SCREEN_WIDTH; }
		
		public function set screenWidth(value:Number):void 
		{
			SCREEN_WIDTH = value;
		}
		
		public function registerTemplate(template:ICasparTemplate):void
		{
			template.movieClip.addEventListener(CasparTemplateEvent.REMOVE_TEMPLATE, onRemoveTemplate);
			template.movieClip.addEventListener(CasparTemplateEvent.TRACE_TO_LOG, onTraceToLog);
			template.movieClip.addEventListener(CasparTemplateEvent.EXTERNAL_CALL, onExternalCall);
			template.movieClip.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtErrorTemplate);
			registerTemplateFramerate(template);
		}
		
		
		//TODO: This won't catch all exceptions from templates. We need to look at a way to validate the swf(.ft) (loadBytes) before we load it.
		//Check these links
		//http://stackoverflow.com/questions/3263166/handle-verifyerror-error-1014-when-loading-swfs-using-as3
		//http://www.senocular.com/flash/actionscript/?file=ActionScript_3.0/com/senocular/utils/SWFReader.as
		//http://code.google.com/p/flash-decompiler/
		private function onUncaughtErrorTemplate(event:UncaughtErrorEvent):void 
		{
			var errorstr:String;
			
			if (event.error is Error)
            {
                var e:Error = event.error as Error;
				trace(e.getStackTrace());
                // do something with the error
				errorstr = e.message;
				trace("it is an error type");
            }
            else if (event.error is ErrorEvent)
            {
				
                var ee:ErrorEvent = event.error as ErrorEvent;
				errorstr = ee.text;
                // do something with the error
				trace("it is an error EVENT type");
            }
            else
            {
                // a non-Error, non-ErrorEvent type was thrown and uncaught
				errorstr = "unhandled non-error or non-errorEvent";
				trace("it is an non error type");
            }
			
			event.preventDefault();
			trace(ICasparTemplate(event.currentTarget.content).layer);
			var error:String = "@Runtime error on template \"" + event.currentTarget.url + "@" + ICasparTemplate(event.currentTarget.content).layer + "@" + errorstr;
			dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, ICasparTemplate(event.currentTarget.content).layer, error));
			removeTemplate(ICasparTemplate(event.currentTarget.content));
		}
		
		//TODO: Decide how to call caspar when unhandeled errors occur (flag for reinitialization)
		/**
		 * Handle unhandeled errors from template host
		 */
		private function onUncaughtError(event:UncaughtErrorEvent):void
        {
			event.preventDefault();
			var errorstr:String;
			trace(event.currentTarget);
            if (event.error is Error)
            {
                var error:Error = event.error as Error;
				trace(error.getStackTrace());
                // do something with the error
				errorstr = "@unhandled error@TemplateHost@?@" + error.message;
				dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, 0, errorstr));
				trace("it is an error type");
            }
            else if (event.error is ErrorEvent)
            {
				
                var errorEvent:ErrorEvent = event.error as ErrorEvent;
				errorstr = "@unhandled errorEvent@TemplateHost@?@" + errorEvent.text;
				dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, 0, errorstr));
                // do something with the error
				trace("it is an error EVENT type");
            }
            else
            {
                // a non-Error, non-ErrorEvent type was thrown and uncaught
				errorstr = "@unhandled non-error or non-errorEvent@TemplateHost@?@" + "Non specified";
				dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, 0, errorstr));
				trace("it is an non error type");
            }
        }
		//TODO: investigate unloadAndStop
		public function removeTemplate(template:ICasparTemplate):void 
		{	
			
			var layer:int = template.layer;
			var success:Boolean = true;
			var error:String = "";
			
			try
			{	
				try
				{
					//removeListeners(template.movieClip.);
					stopMovieClips(template.movieClip);
					template.dispose();
					deleteChildren(template.movieClip);
				}
				catch (e:Error)
				{
					success = false;
					error = "@removeTemplate@" + template.layer + "@#1:" + e;
					dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, template.layer, error));
				}
				try
				{
					_communicationManager.unregisterTemplate(template);
					removeTemplateFramerate(template);
					template.movieClip.removeEventListener(CasparTemplateEvent.REMOVE_TEMPLATE, onRemoveTemplate);
					template.movieClip.removeEventListener(CasparTemplateEvent.TRACE_TO_LOG, onTraceToLog);
					template.movieClip.removeEventListener(CasparTemplateEvent.EXTERNAL_CALL, onExternalCall);
				}
				catch (e:Error)
				{
					success = false;
					error = "@removeTemplate@" + template.layer + "@#2:" + e;
					dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, template.layer, error));
				}
					
				if (_templateContainer.numChildren > 0) 
				{
					for (var i:int = 0; i <= _templateContainer.numChildren - 1; i++) 
					{
						if (_templateContainer.getChildAt(i) == template) 
						{
							_templateContainer.removeChildAt(i);
						}
					}
				}

				_loadedTemplates.stopLayer(template.layer);
				template = null;
				
				if (_externalCommandsBuffer.isEmpty) 
				{
					isTemplateHostEmpty();
				}
			} 
			catch (e:Error) 
			{
				success = false;
				error = "@removeTemplate@" + template.layer + "@#3" + e;
				dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, template.layer, error));
			}
			
			if (success) dispatchEvent(new CommandEvent(CommandEvent.COMMAND_FINISHED, 0, "@RemoveTemplate@" + layer,  true));
		}		
		
		//private function removeListeners(movieClip:MovieClip):void 
		//{
			//for (var i:int = 0; i < movieClip.listeners.length)
		//}
		
		private function stopMovieClips(movieClip:MovieClip):void
		{
			movieClip.stop();
			for (var i:int = 0; i <= movieClip.numChildren - 1; i++) 
			{
				if (movieClip.getChildAt(i) as MovieClip != null) 
				{
					stopMovieClips(MovieClip(movieClip.getChildAt(i)));
				}
			}
		}
		
		private function deleteChildren(movieClip:MovieClip):void
		{
			for (var i:int = movieClip.numChildren-1; i >= 0; i--) 
			{
				if (movieClip.getChildAt(i) as MovieClip != null) 
				{
					deleteChildren(MovieClip(movieClip.getChildAt(i)));
				}
				try
				{
					movieClip.removeChild(movieClip.getChildAt(i));
				}
				catch (e:Error)	{ }
			}
		}
	}
}