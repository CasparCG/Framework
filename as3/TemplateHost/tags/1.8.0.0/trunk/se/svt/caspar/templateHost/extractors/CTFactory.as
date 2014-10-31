package se.svt.caspar.templateHost.extractors
{

	import base64.Base64;
	import deng.fzip.FZip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	/**
	 * ...
	 * @author Andreas Jeansson, SVT
	 */
	public class CTFactory extends EventDispatcher
	{
		
		private var zip:FZip;
		private var templateXML:XML;
		private var templateBytes:ByteArray;
		
		public function CTFactory(fileURL:String)
		{
			unzip(fileURL);
		}
		
		public function dispose():void
		{
			zip.removeEventListener(Event.OPEN, onOpen);
			zip.removeEventListener(Event.COMPLETE, onComplete);
			zip = null;
			templateXML = null;
			templateBytes = null;
			
		}
		
		private function unzip(path:String):void
		{
			zip = new FZip();
			zip.addEventListener(Event.OPEN, onOpen);
			zip.addEventListener(Event.COMPLETE, onComplete);
			zip.load(new URLRequest(path));

		}
		
		private function onComplete(e:Event):void 
		{
			//trace("complete");
			for (var i:int = 0; i < zip.getFileCount(); i++ )
			{				
				if (zip.getFileAt(i).filename.indexOf(".xml") != -1)
				{
					//trace(zip.getFileAt(i).content);
					templateXML = new XML(new XML(zip.getFileAt(i).content).Data.templateData);
					//trace(templateXML);
				}
				else if (zip.getFileAt(i).filename.indexOf(".ft") != -1)
				{
					//trace("bygger ft fil");
					//trace(zip.getFileAt(i).content);
					templateBytes = zip.getFileAt(i).content;
					//trace(templateBytes);
				}
			}
			
			if (templateXML != null)
			{
				for (var j:int = 0; j < zip.getFileCount(); j++ )
				{
					if (zip.getFileAt(j).filename.indexOf(".png") != -1 || zip.getFileAt(j).filename.indexOf(".jpg") != -1 || zip.getFileAt(j).filename.indexOf(".gif") != -1)
					{
						for each(var item:XML in templateXML.elements())
						{
							//trace("\n\nitem", item.elements(), "\n\n");
							for each(var componentItem:XML in item.elements())
							{
								//trace("\n\nitem", componentItem.toXMLString(), "\n\n");
								if (componentItem.@value == zip.getFileAt(j).filename)
								{
									componentItem.@id = "bitmapBytes";
									trace("encodar");
									componentItem.@value = Base64.encode(ByteArray(zip.getFileAt(j).content));
									trace("har encodat");
									//componentItem.@value = encode(ByteArray(zip.getFileAt(j).content));
								}
							}
							//templateXML.componentData.data.(@value == zip.getFileAt(j).filename).@id = "bitmapBytes";
							//templateXML.componentData.data.(@value == zip.getFileAt(j).filename).@value = Base64.encode(ByteArray(zip.getFileAt(j).content));
						}
						//templateXML.componentData.data.(@value == zip.getFileAt(j).filename).@id = "bitmapBytes";
						//templateXML.componentData.data.(@value == zip.getFileAt(j).filename).@value = Base64.encode(ByteArray(zip.getFileAt(j).content));
					}
				}
			}
			var event:CTFactoryEvent = new CTFactoryEvent(CTFactoryEvent.DECOMPRESSED);
			event.templateBytes = templateBytes;
			event.xmlData = templateXML;
			dispatchEvent(event);
			//trace(zip.getFileByName("bobster_0.png").getContentAsString());
			//trace(templateXML);
		}
		
		//private function encode(data:ByteArray):String
		//{
			//trace("ENCODAR");
		   //data.position = 0;
		   //var str:String = "";
		   //var len:int = data.length;
		   //for (var n:int = 0; n < len; ++n)
				//str += String.fromCharCode(data.readByte());
		   //return str ;
		//}
		
		private function onOpen(e:Event):void 
		{
			//trace("onOpen");
		}
	}
	
}