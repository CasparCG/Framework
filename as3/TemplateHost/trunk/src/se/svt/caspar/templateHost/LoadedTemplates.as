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

//Contains the loaded templates

package se.svt.caspar.templateHost 
{
	import flash.utils.Dictionary;
	import se.svt.caspar.template.ICasparTemplate;

	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	public class LoadedTemplates 
	{
		//Contains all the loaded templates
		//private var _loadedTemplates:Dictionary;
		private var _loadedTemplates:Array;
		private var _numberOfLoadedTemplates:uint;

		public function LoadedTemplates():void 
		{
			//_loadedTemplates = new Dictionary();
			_loadedTemplates = [];
			_numberOfLoadedTemplates = 0;
		}
		
		/**
		 * returns a vector with all the loaded templates
		 * @return
		 */
		public function getLoadedTemplates():Vector.<LoadedTemplateItem>
		{
			var templates:Vector.<LoadedTemplateItem> = new Vector.<LoadedTemplateItem>;
			for each(var template:LoadedTemplateItem in _loadedTemplates)
			{
				templates.push(template);
			}
			return templates;
		}

		public function templateIsLoaded(template:ICasparTemplate, layer:int):void
		{
			if (_loadedTemplates[layer] != null)
			{
				_loadedTemplates[layer].queuedTemplate = template;
				_numberOfLoadedTemplates++;
			}
			else 
			{
				var loadedTemplateItem:LoadedTemplateItem = new LoadedTemplateItem();
				loadedTemplateItem.queuedTemplate = template;
				_loadedTemplates[layer] = loadedTemplateItem;
				_numberOfLoadedTemplates++;
			}
		}
		
		public function playLayer(layer:int):void
		{
			try
			{
				if (_loadedTemplates[layer].queuedTemplate != null)
				{
					_loadedTemplates[layer].playingTemplate = _loadedTemplates[layer].queuedTemplate;
					_loadedTemplates[layer].queuedTemplate = null;	
				}
				else 
				{
					throw new ReferenceError("No template queued on layer " + layer);
				}
			}
			catch (e:Error)
			{
				throw new ReferenceError("No template queued on layer " + layer);
			}
			
		}
		
		public function stopLayer(layer:int):void
		{
			try
			{
				if (_loadedTemplates[layer].playingTemplate != null)
				{
					_loadedTemplates[layer].playingTemplate = null;
					_numberOfLoadedTemplates--;
				}
				else 
				{
					throw new ReferenceError("No template playing on layer " + layer);
				}
			}
			catch (e:Error)
			{
				throw new ReferenceError("No template playing on layer " + layer);
			}
		}
		
		public function getPlayingTemplate(layer:uint):ICasparTemplate 
		{
			try
			{
				if (_loadedTemplates[layer].playingTemplate != null)
				{
					return _loadedTemplates[layer].playingTemplate;
				}
				else
				{
					throw new ReferenceError("No template playing on layer " + layer);
				}
			}
			catch (e:Error)
			{
				throw new ReferenceError("No template playing on layer " + layer);
			}
			return null;
		}
		
		public function getQueuedTemplate(layer:uint):ICasparTemplate 
		{
			try
			{
				if (_loadedTemplates[layer].queuedTemplate != null)
				{
					return _loadedTemplates[layer].queuedTemplate;
				}
				else
				{
					throw new ReferenceError("No template queued on layer " + layer);
				}
			}
			catch (e:Error)
			{
				throw new ReferenceError("No template queued on layer " + layer);
			}
			return null;
		}
		
		public function get numberOfLoadedTemplates():uint { return _numberOfLoadedTemplates; }
	}
}