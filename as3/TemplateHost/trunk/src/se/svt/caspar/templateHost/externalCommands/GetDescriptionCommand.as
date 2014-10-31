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
	import flash.events.EventDispatcher;
	import se.svt.caspar.template.ICasparTemplate;
	import se.svt.caspar.templateHost.ITemplateHost;
	
	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	public class GetDescriptionCommand extends EventDispatcher implements IExternalCommand
	{
		
		private var _layers:Array;
		//The layers where the command was successfully executed
		private var _successLayers:Array;
		private var _templateHost:ITemplateHost;
		//True if the command was successfully executed
		private var _success:Boolean = true;
		
		public function GetDescriptionCommand(layers:Array, templateHost:ITemplateHost) 
		{
			_layers = layers;
			_templateHost = templateHost;
			_successLayers = [];
		}
		
		/* INTERFACE se.svt.caspar.templateHost.externalCommands.IExternalCommand */
		
		public function execute():void
		{
		
			for (var i:int = 0; i < _layers.length; i++) 
			{
				var template:ICasparTemplate;
				try
				{
					template = _templateHost.loadedTemplates.getPlayingTemplate(_layers[i]);
					dispatchEvent(new CommandEvent(CommandEvent.GET_DESCRIPTION, _layers[i], template.GetDescription()));
					_successLayers.push(_layers[i]);
				}
				catch(e:Error)
				{
					try
					{
						template = _templateHost.loadedTemplates.getQueuedTemplate(_layers[i]);
						dispatchEvent(new CommandEvent(CommandEvent.GET_DESCRIPTION, _layers[i], template.GetDescription()));
						_successLayers.push(_layers[i]);
					}
					catch (e:Error)
					{
						var error:String = "@GetDescription@" + _layers[i] + "@" + e;
						dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, _layers[i], error));
					}
				}
			}
			
			dispatchEvent(new CommandEvent(CommandEvent.COMMAND_FINISHED, 0, "@GetDescription@" + _successLayers.toString(), _successLayers.length > 0 ));
			
		}
		
		/* INTERFACE se.svt.caspar.templateHost.externalCommands.IExternalCommand */
		
		public function dispose():void 
		{
			_layers = null;
			_successLayers = null;
			_templateHost = null;
		}
	}
}