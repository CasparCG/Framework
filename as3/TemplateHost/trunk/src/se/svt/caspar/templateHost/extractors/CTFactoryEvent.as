package se.svt.caspar.templateHost.extractors
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Andreas Jeansson, SVT
	 */
	public class CTFactoryEvent extends Event 
	{
		public static const DECOMPRESSED:String = "decompressed";
		
		private var _templateBytes:ByteArray;
		private var _xmlData:XML;
		
		public function CTFactoryEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new CTFactoryEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("CTFactoryEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get templateBytes():ByteArray { return _templateBytes; }
		
		public function set templateBytes(value:ByteArray):void 
		{
			_templateBytes = value;
		}
		
		public function get xmlData():XML { return _xmlData; }
		
		public function set xmlData(value:XML):void 
		{
			_xmlData = value;
		}
		
	}
	
}