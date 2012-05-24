package caspar.network.data 
{
	/**
	 * ...
	 * @author Andreas Jeansson, SVT
	 */
	
	 /**
	  * Contains info on retrieved data item
	  */
	public class DataInfoItem 
	{
		
		private var _folder:String;
		private var _name:String;
		
		public function DataInfoItem(folder:String, name:String) 
		{
			_folder = folder;
			_name = name;
		}
		
		
		public function get folder():String 
		{
			return _folder;
		}
		
		public function get name():String 
		{
			return _name;
		}
		
	}

}