package caspar.network.data 
{
	/**
	 * ...
	 * @author Andreas Jeansson, SVT
	 */
	public class DataItem 
	{
		private var _dataInfoItem:DataInfoItem;
		private var _content:XML;
		
		public function DataItem(dataInfoItem:DataInfoItem, content:XML = null) 
		{
			_dataInfoItem = dataInfoItem;
			_content = content;
		}
		
		/**
		 * Creates a new template data xml, will overwrite content
		 */
		public function createNewTemplateDataContent():void
		{
			_content = new XML(<templateData></templateData>);
		}
		
		public function addTemplateData(componentID:String, componentDataValue:String, componentDataID:String="text"):void 
		{
			// Add data node)
			var cd:XML = new XML(<componentData id={componentID}></componentData>);
			var dataNode:XML = new XML(<data id={componentDataID} value={componentDataValue} />);
			cd.appendChild(dataNode);
			_content.appendChild(cd);
		}
		
		public function get content():XML 
		{
			return _content;
		}
		
		public function set content(value:XML):void 
		{
			_content = value;
		}
		
		public function get dataInfoItem():DataInfoItem 
		{
			return _dataInfoItem;
		}
		
		public function set dataInfoItem(value:DataInfoItem):void 
		{
			_dataInfoItem = value;
		}
	
	}

}