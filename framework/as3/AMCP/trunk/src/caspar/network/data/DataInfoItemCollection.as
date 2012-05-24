package caspar.network.data 
{
	/**
	 * ...
	 * @author Andreas Jeansson, SVT
	 */
	public class DataInfoItemCollection implements IItemList
	{
		private var _itemList:Array;
		
		public function DataInfoItemCollection(itemList:Array)
		{
			_itemList = itemList;
			_itemList.sortOn(["folder", "name"], [ Array.CASEINSENSITIVE, Array.CASEINSENSITIVE] );
		}
		
		public function getItems():Array
		{
			return _itemList;
		}
		
		public function getItemsInFolder(folder:String):Array
		{
			var items:Array;
			for each(var item:DataInfoItem in _itemList)
			{
				if (item.folder == folder)
				{
					if (items == null)
					{
						items = new Array();
					}
					items.push(item);
				}
			}
			items.sortOn("name", Array.CASEINSENSITIVE);
			return items;
		}
		
		public function getFolders():Array
		{
			var folders:Array;
			var currentFolder:String;
			for each(var item:DataInfoItem in _itemList)
			{
				if (folders == null)
				{
					folders = new Array();
				}
				if (currentFolder != item.folder)
				{
					folders.push(item.folder);
					currentFolder = item.folder;
				}
				
			}
			return folders;
		}
		
		
	}

}