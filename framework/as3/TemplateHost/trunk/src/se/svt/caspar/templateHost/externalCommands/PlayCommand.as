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

package se.svt.caspar.templateHost.externalCommands 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import se.svt.caspar.template.ICasparTemplate;
	import se.svt.caspar.templateHost.ITemplateHost;
	
	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	public class PlayCommand extends EventDispatcher implements IExternalCommand
	{
		
		private var _layers:Array;
		//The layers where the command was successfully executed
		private var _successLayers:Array;
		private var _mixInDuration:uint;
		private var _templateContainer:Sprite;
		private var _templateHost:ITemplateHost;
		private var _numberOfCommands:uint;
		private var _template:ICasparTemplate;

		public function PlayCommand(layers:Array, templateContainer:Sprite, templateHost:ITemplateHost)
		{
			_numberOfCommands = layers.length;
			_layers = layers;
			_templateContainer = templateContainer;
			_templateHost = templateHost;
			_successLayers = [];
		}
		
			
		/* INTERFACE se.svt.caspar.templateHost.externalCommands.IExternalCommand */
		
		public function execute():void
		{
			for (var i:uint = 0; i < _layers.length; i++)
			{
				try
				{
					playTemplate(_layers[i]);
				}
				catch (e:Error) 
				{
					var error:String = "@Play@" + _layers[i] + "@" + e;
					dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, _layers[i], error));
					commandFinished();
				}
			}
		}
		
		public function dispose():void 
		{
			if (_template != null)
			{
				try
				{
					_template.movieClip.addEventListener(Event.ENTER_FRAME, onTemplateRendered);
				}
				finally
				{
					_template = null;
				}
			}
			_layers = null;
			_successLayers = null;
			_templateHost = null;
			_templateContainer = null;
		}
		
		/**
		 * Plays the template
		 * @param	template the template to be played
		 */
		private function playTemplate(layer:int):void 
		{

			_template = _templateHost.loadedTemplates.getQueuedTemplate(layer);
			_template.movieClip.addEventListener(Event.ENTER_FRAME, onTemplateRendered);

			if (_templateContainer.numChildren == 0) 
			{
				_templateContainer.addChild(_template.movieClip);
				_templateHost.loadedTemplates.playLayer(layer);
			}
			else
			{
				for (var i:int = 0; i <= _templateContainer.numChildren - 1; i++) 
				{
					var currentVirtualLayerPosition:int = (_templateContainer.getChildAt(i) as ICasparTemplate).layer;
					if (layer < currentVirtualLayerPosition) 
					{
						_templateContainer.addChildAt(_template.movieClip, i);
						_templateHost.loadedTemplates.playLayer(layer);
						break;
					} 
					else if (layer == currentVirtualLayerPosition) 
					{
						_templateHost.removeTemplate(_templateContainer.getChildAt(i) as ICasparTemplate);
						_templateContainer.addChildAt(_template.movieClip, i);
						_templateHost.loadedTemplates.playLayer(layer);
						break;
					}
					else if (i == _templateContainer.numChildren - 1) 
					{
						_templateContainer.addChild(_template.movieClip);
						_templateHost.loadedTemplates.playLayer(layer);
						break;
					}
				}
			}
			_template.Play();
		}
		
		/**
		 * Decreases the commandFinished. When 0 dispatch finish event.
		 */
		private function commandFinished():void
		{
			_numberOfCommands--;
			if (_numberOfCommands == 0) 
			{
				dispatchEvent(new CommandEvent(CommandEvent.COMMAND_FINISHED, 0, "@Play@" + _successLayers.toString(), _successLayers.length > 0 ));
			}
		}
		
		private function onTemplateRendered(evt:Event):void 
		{
			try 
			{
				var template:ICasparTemplate = evt.currentTarget as ICasparTemplate;
				var layer:int = template.layer;

				dispatchEvent(new CommandEvent(CommandEvent.TEMPLATE_PLAYING, layer));
				_successLayers.push(layer);
			} 
			catch (e:Error) 
			{
				var error:String = "@Play@?" + e;
				dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, undefined, error));
				
			} 
			finally 
			{
				evt.currentTarget.removeEventListener(Event.ENTER_FRAME, onTemplateRendered);
				commandFinished();
			}
		}
			
	}
	
}