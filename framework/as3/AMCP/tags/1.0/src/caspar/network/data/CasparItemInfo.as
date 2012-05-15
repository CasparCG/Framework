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

package caspar.network.data
{
	public class CasparItemInfo implements ICasparItemInfo
	{
		public static const TYPE_TEMPLATE:String = "type_template";
		public static const TYPE_MEDIA:String = "type_media";
		
		private var _folder:String;
		private var _templatename:String;
		private var _templatepath:String;
		private var _size:String;
		private var _date:String;
		private var _type:String;
		private var _subtype:String;
		
		public function CasparItemInfo()
		{
			
		}
		
		/* INTERFACE se.svt.caspar.network.data.ICasparItemInfo */

		public function get folder():String { return _folder; }
		
		public function set folder(value:String):void 
		{
			_folder = value;
		}
		
		public function get name():String { return _templatename; }
		
		public function set name(value:String):void 
		{
			_templatename = value;
		}
		
		public function get path():String { return _templatepath; }
		
		public function set path(value:String):void 
		{
			_templatepath = value;
		}
		
		public function get size():String { return _size; }
		
		public function set size(value:String):void 
		{
			_size = value;
		}
		
		public function get date():String { return _date; }
		
		public function set date(value:String):void 
		{
			_date = value;
		}
		
		public function get type():String 
		{
			return _type;
		}
		
		public function set type(value:String):void 
		{
			_type = value;
		}
		
		public function get subtype():String 
		{
			return _subtype;
		}
		
		public function set subtype(value:String):void 
		{
			_subtype = value;
		}
		
	
		
		
	}

}