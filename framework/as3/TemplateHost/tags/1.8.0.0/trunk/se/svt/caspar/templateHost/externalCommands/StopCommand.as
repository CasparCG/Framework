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
	import flash.events.EventDispatcher;
	import se.svt.caspar.template.ICasparTemplate;
	import se.svt.caspar.templateHost.ITemplateHost;
	
	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	public class StopCommand extends EventDispatcher implements IExternalCommand
	{
		
		private var _layers:Array;
		//The layers where the command was successfully executed
		private var _successLayers:Array;
		private var _mixOutDuration:uint;
		private var _templateContainer:Sprite;
		private var _templateHost:ITemplateHost;
		
		public function StopCommand(layers:Array, mixOutDuration:uint, templateContainer:Sprite, templateHost:ITemplateHost) 
		{
			_layers = layers;
			_mixOutDuration = mixOutDuration;
			_templateContainer = templateContainer;
			_templateHost = templateHost;
			_successLayers = [];
		}
				
		public function removeTemplate(template:ICasparTemplate):void 
		{
			_templateHost.removeTemplate(template);
		}
		
		/* INTERFACE se.svt.caspar.templateHost.externalCommands.IExternalCommand */
		
		public function execute():void
		{
			for (var i:int = 0; i < _layers.length; i++) 
			{
				try
				{
					var template:ICasparTemplate = _templateHost.loadedTemplates.getPlayingTemplate(_layers[i]);
					
					if (template != null)
					{
						if (_mixOutDuration == 0) 
						{
							template.Stop();
						}
						else 
						{
							_templateHost.mixer.mixOut(template.movieClip, _mixOutDuration, removeTemplate);
						}
						_successLayers.push(_layers[i]);
					}
					else 
					{
						throw new Error("No template loaded on layer " + _layers[i]);
					}
				}
				catch(e:Error)
				{
					var error:String = "@Stop@" + _layers[i] + "@" + e;
					dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, _layers[i], error));
				}
			}
			
			dispatchEvent(new CommandEvent(CommandEvent.COMMAND_FINISHED, 0, "@Stop@" + _successLayers.toString(),  _successLayers.length > 0));
		}
	}
}