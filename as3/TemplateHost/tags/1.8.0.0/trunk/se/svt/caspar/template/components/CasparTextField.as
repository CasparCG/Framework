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

package se.svt.caspar.template.components 
{ 
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	public class CasparTextField extends MovieClip implements ICasparComponent 
	{ 
		private var _textField:TextField;
		private var _spacing:Number;
		//public static var description:String = "&lt;component name=&quot;SVTText&quot;&gt;&lt;property name=&quot;text&quot; type=&quot;string&quot; info=&quot;Texten som ska visas&quot; /&gt;&lt;/component&gt";
			
		public function CasparTextField(textField:TextField, spacing:Number) 
		{			
			_textField = textField;
			_textField.text = "";
			_spacing = spacing;
			//ComponentDataBuffer.componentLoaded(_textField.name, this);
		}
		
		// Functions for the interface
		public function SetData(xmlData:XML):void 
		{ 
			var format:TextFormat = _textField.getTextFormat();
			format.letterSpacing = _spacing;
			_textField.text = xmlData.data.@value;
			_textField.setTextFormat(format);
		}
		
		/* INTERFACE se.svt.caspar.template.components.ICasparComponent */
		
		public function dispose():void
		{
		}
		
		public override function get name():String 
		{
			return _textField.name;
		}
		
	}
}