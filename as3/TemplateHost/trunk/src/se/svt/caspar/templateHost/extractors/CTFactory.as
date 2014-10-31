package se.svt.caspar.templateHost.extractors
{
	import base64.Base64;
	import deng.fzip.FZip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import se.svt.caspar.template.components.ComponentAssets;

	/**
	 * ...
	 * @author Andreas Jeansson, SVT
	 */
	public class CTFactory extends EventDispatcher
	{
		private var _zip:FZip;
		private var _templateXML:XML;
		private var _templateBytes:ByteArray;
		
		public function CTFactory(fileURL:String)
		{
			unzip(fileURL);
		}
		
		public function dispose():void
		{
			_zip.removeEventListener(Event.COMPLETE, onComplete);
			_zip = null;
			_templateXML = null;
			_templateBytes = null;
			
		}
		
		private function unzip(path:String):void
		{
			_zip = new FZip();
			_zip.addEventListener(Event.COMPLETE, onComplete);
			_zip.load(new URLRequest(path));

		}
		
		private function onComplete(e:Event):void 
		{
			for (var i:int = 0; i < _zip.getFileCount(); i++ )
			{				
				if (_zip.getFileAt(i).filename.indexOf(".xml") != -1)
				{
					_templateXML = new XML(new XML(_zip.getFileAt(i).content).Data.templateData);
					_templateXML = formatTemplateXML(_templateXML);
				}
				else if (_zip.getFileAt(i).filename.indexOf(".ft") != -1)
				{
					_templateBytes = _zip.getFileAt(i).content;
				}
			}
			
			
			var event:CTFactoryEvent = new CTFactoryEvent(CTFactoryEvent.DECOMPRESSED);
			event.templateBytes = _templateBytes;
			event.xmlData = _templateXML;
			dispatchEvent(event);
		}
		
		/**
		 * Ensure that all elements of the same instance are grouped
		 * @param	templateXML The unformatted xml
		 * @return The formatted xml
		 */
		private function formatTemplateXML(templateXML:XML):XML 
		{
			var returnXML:XML = new XML(<templateData></templateData>);
			

			for each(var item:XML in templateXML.elements())
			{
				var foundElement:Boolean = false;
				
				for (var i:int = 0; i < returnXML.elements().length(); i++ )
				{
					if (returnXML.elements()[i].@id == item.@id)
					{
						returnXML.elements()[i].appendChild(item.data)
						foundElement = true;
						break;
					}
				}
				
				if(!foundElement) returnXML.appendChild(item);

			}
			return returnXML;
		}
		
		/**
		 * Returns images in an Object (fast) 
		 * @param	templateXML
		 * @return
		 */
		public function getObjectAssets():ComponentAssets
		{
			var dataObject:ComponentAssets = new ComponentAssets();
			if (_templateXML != null)
			{
				dataObject.templateXML = _templateXML;
				for (var j:int = 0; j < _zip.getFileCount(); j++ )
				{
					if (_zip.getFileAt(j).filename.indexOf(".xml") == -1 && _zip.getFileAt(j).filename.indexOf(".ft") == -1)
					{
						for each(var item:XML in _templateXML.elements())
						{
							for each(var componentItem:XML in item.elements())
							{
								if (componentItem.@value == _zip.getFileAt(j).filename)
								{
									dataObject.addAsset(item.@id, _zip.getFileAt(j).filename, ByteArray(_zip.getFileAt(j).content));
								}
							}
						}
					}
				}
			}
			return dataObject;
		}
		
		/**
		 * Returns an Base64 encoded representation of the images baked in the xml (slow)
		 * @param	templateXML
		 * @return
		 */
		public function getBase64Assets():XML
		{
			if (_templateXML != null)
			{
				for (var j:int = 0; j < _zip.getFileCount(); j++ )
				{
					if (_zip.getFileAt(j).filename.indexOf(".png") != -1 || _zip.getFileAt(j).filename.indexOf(".jpg") != -1 || _zip.getFileAt(j).filename.indexOf(".gif") != -1)
					{
						for each(var item:XML in _templateXML.elements())
						{
							for each(var componentItem:XML in item.elements())
							{
								if (componentItem.@value == _zip.getFileAt(j).filename)
								{
									componentItem.@id = "bitmapBytes";
									componentItem.@value = Base64.encode(ByteArray(_zip.getFileAt(j).content));
								}
							}
						}
					}
				}
			}
			return _templateXML;
		}
	}
}