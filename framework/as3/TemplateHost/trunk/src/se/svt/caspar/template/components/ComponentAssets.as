package se.svt.caspar.template.components 
{
	/**
	 * ...
	 * @author Andreas Jeansson, SVT
	 */
	public class ComponentAssets
	{
		private var _templateXML:XML;
		private var _assets:Vector.<ComponentAsset>;
		
		public function ComponentAssets() 
		{
			_assets = new Vector.<ComponentAsset>;
		}
		
		public function dispose():void
		{
			//TODO: dispose data, when?
			for (var i:int = 0; i < _assets.length; i++)
			{
				_assets[i].dispose();
			}
			_assets = null;
			_templateXML = null;
		}
		
		public function addAsset(componentID:String, assetID:String, data:*):void
		{
			var asset:ComponentAsset = new ComponentAsset();
			asset.componentID = componentID;
			asset.assetID = assetID;
			asset.data = data;
			_assets.push(asset);
		}
		
		public function get assets():Vector.<ComponentAsset>
		{
			return _assets;
		}
		
		public function get templateXML():XML 
		{
			return _templateXML;
		}
		
		public function set templateXML(value:XML):void 
		{
			_templateXML = value;
		}
		
	}

}