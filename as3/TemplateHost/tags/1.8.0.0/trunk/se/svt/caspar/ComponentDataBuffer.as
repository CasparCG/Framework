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

//Buffers the data that is sent to the SVT components if needed.

package se.svt.caspar 
{
	import flash.utils.Dictionary;
	import se.svt.caspar.template.components.ICasparComponent;
	
	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	public class ComponentDataBuffer 
	{
		private var _loadedComponents:Dictionary;
		private var _bufferedData:Dictionary;
		private var _componentIdentifiers:Vector.<String>;
		
		public function ComponentDataBuffer():void 
		{
			_loadedComponents = new Dictionary();
			_bufferedData = new Dictionary();
			_componentIdentifiers = new Vector.<String>();
		}
		
		public function SetData(componentIdentifier:String, data:XML):void
		{ 
			if (_loadedComponents[componentIdentifier] != null) 
			{
				_loadedComponents[componentIdentifier].SetData(data);
			} 
			else
			{
				_bufferedData[componentIdentifier] = data;
			}
			_bufferedData[componentIdentifier] = data;	
		}
		
		/**
		 * Called by CasparTemplate when the registerComponent() function is called by the component
		 */
		public function componentLoaded(componentIdentifier:String, instance:ICasparComponent) :void
		{
			var firstAdd:Boolean = _loadedComponents[componentIdentifier] == null;
			_loadedComponents[componentIdentifier] = instance;
			if(firstAdd) _componentIdentifiers.push(componentIdentifier);
			
			if (_bufferedData[componentIdentifier] != null) 
			{
				instance.SetData(_bufferedData[componentIdentifier]);
			}
		}
		
		/**
		 * Called by CasparTemplate when template is about to be removed
		 */
		public function diposeAllComponents():void
		{
			for (var i:uint = 0; i < _componentIdentifiers.length; i++)
			{
				try
				{
					_loadedComponents[_componentIdentifiers[i]].dispose();
					delete _loadedComponents[_componentIdentifiers[i]];
				}
				catch (e:Error)	{ }
			}
			
			_componentIdentifiers = null;
			_bufferedData = null;
		}
	}
}