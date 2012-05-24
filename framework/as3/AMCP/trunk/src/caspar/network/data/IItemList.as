package caspar.network.data 
{
	
	/**
	 * ...
	 * @author Andreas Jeansson, SVT
	 */
	public interface IItemList 
	{
		function getItems():Array;
		function getItemsInFolder(folder:String):Array;
		function getFolders():Array;
		
	}
	
}