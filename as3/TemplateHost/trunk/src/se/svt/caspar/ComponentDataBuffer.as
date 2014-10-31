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
	import flash.display.MovieClip;
	import flash.utils.ByteArray;
	import se.svt.caspar.template.components.ComponentAsset;
	import se.svt.caspar.template.components.ICaspar2Component;
	import se.svt.caspar.template.components.ICasparComponent;
	
	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	public class ComponentDataBuffer 
	{
		private var _loadedComponents:Array;
		private var _bufferedData:Array;
		private var _bufferedObjectData:Array;
		private var _componentIdentifiers:Vector.<String>;
		
		public function ComponentDataBuffer():void 
		{
			_loadedComponents = [];
			_bufferedData = [];
			_bufferedObjectData = [];
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
		
		public function SetDataObject(asset:ComponentAsset):void
		{ 
			var componentIdentifier:String = asset.componentID;
			if (_loadedComponents[componentIdentifier] != null) 
			{
				if ((_loadedComponents[componentIdentifier] as ICaspar2Component) != null)
				{
					ICaspar2Component(_loadedComponents[componentIdentifier]).SetDataObject(asset.assetID, asset.data);
				}
			} 
			else
			{
				_bufferedObjectData[componentIdentifier] = asset;
			}
			_bufferedObjectData[componentIdentifier] = asset;	
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
			if(_bufferedObjectData[componentIdentifier] != null) 
			{
				if ((instance as ICaspar2Component) != null)
				{
					var asset:ComponentAsset = _bufferedObjectData[componentIdentifier] as ComponentAsset;
					ICaspar2Component(instance).SetDataObject(asset.assetID, asset.data);
				}			
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
				catch (e:Error)	{ trace(e); }
			}
			
			for each(var asset:ComponentAsset in _bufferedObjectData)
			{
			   try
				{
					asset.dispose();
					asset = null;
				}
				catch (e:Error)	{ trace(e); }
			}
			
 			_componentIdentifiers = null;
			_bufferedData = null;
			_bufferedObjectData = null;
		}
	}
}