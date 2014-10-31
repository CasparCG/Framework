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

//Buffers calls from external interface

package se.svt.caspar.templateHost 
{
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import se.svt.caspar.templateHost.externalCommands.CommandEvent;
	import se.svt.caspar.templateHost.externalCommands.IExternalCommand;

	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	
	 //BUG: Lägger ej på mallar efter smäll...
	public class ExternalCommandsBuffer extends EventDispatcher
	{		
		//Time out for a command to execute, in milliseconds, 0 to bypass
		private const COMMAND_TIME_OUT:Number = 0;
		private var _bufferedCommands:Vector.<IExternalCommand>;
		private var _timer:Timer;
		
		public function ExternalCommandsBuffer():void
		{
			_bufferedCommands = new Vector.<IExternalCommand>();
			if (COMMAND_TIME_OUT > 0)
			{
				_timer = new Timer(COMMAND_TIME_OUT, 1);
				_timer.addEventListener(TimerEvent.TIMER, onCommandTimeout);
			}
		}
		
		/**
		 * Add command to the buffer
		 * @param	command The command
		 */	
		public function addCommand(command:IExternalCommand):void
		{
			_bufferedCommands.push(command);
			command.addEventListener(CommandEvent.ON_ERROR, onCommandError);
			command.addEventListener(CommandEvent.COMMAND_FINISHED, onFinished);
			command.addEventListener(CommandEvent.GET_DESCRIPTION, onGetDescription);
			command.addEventListener(CommandEvent.DEBUG_MESSAGE, onDebugMessage);
			
			if (_bufferedCommands.length == 1)
			{
				executeCommand(command);
			}
		}

		private function executeCommand(command:IExternalCommand):void
		{
			try
			{
				if (_timer != null)
				{
					_timer.reset();
					_timer.start();
				}
				command.execute();
			}
			catch (e:Error)
			{
				try
				{
					//dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "misslyckades med executeCommand"));
					onFinished(new CommandEvent(CommandEvent.COMMAND_FINISHED, 0, "Error: Unhandeled exception while executing command"));
					dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, undefined, "@ExternalCommandsBuffer@?@Error: Unhandeled exception while executing command. Maybe the template generated an unhandeled exception. Error: " + e ));
				}
				catch (e:Error)
				{
					//dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "misslyckades med executeCommand och onFinished (row46)"));
					_bufferedCommands = new Vector.<IExternalCommand>();
				}
			}
		}
		
		private function onCommandTimeout(e:TimerEvent):void 
		{
			dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, undefined, "@ExternalCommandsBuffer@?@Error: A command took more than " + Number(COMMAND_TIME_OUT/1000).toString() + " seconds to complete. The command queue will now execute the next queued command (if any)"));
			_bufferedCommands[0].removeEventListener(CommandEvent.ON_ERROR, onCommandError);
			_bufferedCommands[0].removeEventListener(CommandEvent.COMMAND_FINISHED, onFinished);
			_bufferedCommands[0].removeEventListener(CommandEvent.GET_DESCRIPTION, onGetDescription);
			_bufferedCommands[0].dispose();
			
			if (_bufferedCommands.length == 1) 
			{
				_bufferedCommands = new Vector.<IExternalCommand>();
				dispatchEvent(new CommandEvent(CommandEvent.BUFFER_EMPTY));
			} 
			else 
			{
				_bufferedCommands.shift();
				executeCommand(_bufferedCommands[0]);
			}
		}
	
		
		private function onDebugMessage(e:CommandEvent):void 
		{
			dispatchEvent(e);
		}
		
		private function onGetDescription(e:CommandEvent):void 
		{
			dispatchEvent(e);
		}
		
		private function onCommandError(e:CommandEvent):void 
		{
			dispatchEvent(e);
		}
		
		private function onFinished(e:CommandEvent):void 
		{
			trace("->command finished: ", _bufferedCommands[0]);
			if (_timer != null)
			{
				_timer.stop();
			}
			if (e.success) dispatchEvent(e);
			_bufferedCommands[0].removeEventListener(CommandEvent.ON_ERROR, onCommandError);
			_bufferedCommands[0].removeEventListener(CommandEvent.COMMAND_FINISHED, onFinished);
			_bufferedCommands[0].removeEventListener(CommandEvent.GET_DESCRIPTION, onGetDescription);
			_bufferedCommands[0].dispose();
			
			if (_bufferedCommands.length == 1) 
			{
				_bufferedCommands = new Vector.<IExternalCommand>();
				dispatchEvent(new CommandEvent(CommandEvent.BUFFER_EMPTY));
			} else 
			{
				_bufferedCommands.shift();
				executeCommand(_bufferedCommands[0]);
			}
		}
		
		public function get isEmpty():Boolean 
		{
			if (_bufferedCommands.length == 0) 
			{
				return true;
			}
			
			return false;
		}
	}
}