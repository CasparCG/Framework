package se.svt.caspar.template.components 
{
	/**
	 * ...
	 * @author Andreas Jeansson, SVT
	 */
	public class ComponentAsset 
	{
		private var _componentID:String
		private var _assetID:String
		private var _data:*;
		
		public function ComponentAsset() 
		{
			
		}
		
		public function dispose():void
		{
			_componentID = null;
			_assetID = null;
			_data = null;
		}
		
		public function get componentID():String 
		{
			return _componentID;
		}
		
		public function set componentID(value:String):void 
		{
			_componentID = value;
		}
		
		public function get assetID():String 
		{
			return _assetID;
		}
		
		public function set assetID(value:String):void 
		{
			_assetID = value;
		}
		
		public function get data():* 
		{
			return _data;
		}
		
		public function set data(value:*):void 
		{
			_data = value;
		}
		
	}

}