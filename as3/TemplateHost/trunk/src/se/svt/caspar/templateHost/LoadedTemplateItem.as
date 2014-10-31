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

package se.svt.caspar.templateHost 
{
	import se.svt.caspar.template.ICasparTemplate;
	
	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	public class LoadedTemplateItem 
	{
		
		private var _playingTemplate:ICasparTemplate;
		private var _queuedTemplate:ICasparTemplate;
		
		public function LoadedTemplateItem():void {	}
		
		public function get playingTemplate():ICasparTemplate { return _playingTemplate; }
		
		public function set playingTemplate(value:ICasparTemplate):void 
		{
			_playingTemplate = value;
		}
		
		public function get queuedTemplate():ICasparTemplate { return _queuedTemplate; }
		
		public function set queuedTemplate(value:ICasparTemplate):void 
		{
			_queuedTemplate = value;
		}
		
	}
	
}