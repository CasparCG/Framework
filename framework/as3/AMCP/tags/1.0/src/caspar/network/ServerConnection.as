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

// TODO: What happens if caspar does not send a response? Create timeout. 
// TODO: Check problems with disconnecting. disconnectar man verkligen?
// TODO: What happens if connection to caspar is dropped? Testing needed. 
// TODO: Check readResponse and see if we need to look for \r\n in the middle of the response.

package caspar.network {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * ...
	 * @author Andreas Jeansson, SVT
	 */
	
    public class ServerConnection extends EventDispatcher
	{
		private const RECONNECT_DELAY:int = 1000;
		
		public static const TRANSITION_CUT:String = "CUT";
		public static const TRANSITION_MIX:String = "MIX";
		public static const TRANSITION_PUSH:String = "PUSH";
		public static const TRANSITION_SLIDE:String = "SLIDE";
		public static const TRANSITION_WIPE:String = "WIPE";
		
		public static const DIRECTION_FROMLEFT:String = "FROMLEFT";
		public static const DIRECTION_FROMRIGHT:String = "FROMRIGHT";
		
		private const SOCKET_COMMAND_END:String = "";
		
		private var _socket:CustomSocket;
		
		private var _autoReconnect:Boolean = false;
		private var _userForcedDisconnection:Boolean = false;
		
		private var _timer:Timer;

        public function ServerConnection()
		{
			_socket = new CustomSocket();
			_timer = new Timer(RECONNECT_DELAY, 0);
			configureListeners();
		}
		
		///////////////////
		//Socket commands
		///////////////////
		
		/**
		 * Connects to a caspar server
		 * @param	server The server name
		 * @param	port The port number (default 5250)
		 */
		public function connect(server:String, port:uint = 5250, autoReconnect:Boolean = true):void
		{
			_autoReconnect = autoReconnect;
			
			if ((_socket && _socket.connected) && (server == _socket.host) && (port == _socket.port))
			{
				//good
				trace("ServerConnection::you are connected");
			}
			else if ((_socket &&_socket.connected) && ((server != _socket.host) || (port != _socket.port)))
			{
				trace("ServerConnection::do new connection");
				disconnect();
				doNewConnection(server, port);
			}
			else
			{
				trace("ServerConnection::do connection", server, port);
				doNewConnection(server, port);
			}
		}
		
		public function get connected():Boolean
		{
			if (_socket != null)
			{
				return _socket.connected;
			}
			else
			{
				return false;
			}
		}
		
		/**
		 * Disconnect from caspar server
		 */
		public function disconnect():void 
		{
			if(_socket != null)
			{
				_userForcedDisconnection = true;
				if (_socket.connected)
				{
					_socket.close();
					
					
					/*var command:String = 'BYE' + SOCKET_COMMAND_END;
					_socket.addCommand( { command: command, type: ServerConnection.ON_OTHER_COMMAND } );
					*/
				}
			}
		}
		
		
		////////////
		//COMMANDS//
		////////////
		
		/**
		 * Sends a custom command via the AMCP protocol
		 * @param	command The commmand
		 * @return
		 */
		public function SendCommand(command:String):String 
		{
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_OTHER_COMMAND } );
			return command;
		}
		
		///////////////////
		//Play-out commands
		///////////////////
		
		/**
		 * Loads and prepares a clip for playout. Load stops any currently playing clip and displays the first frame of the new clip. Supply the LOOP parameter if you want the clip to loop.
		 * @param	channel The channel
		 * @param	file The file to load
		 * @param	loop Loop the clip (default: false)
		 */
		public function LoadMedia(channel:uint, file:String, loop:Boolean = false):String 
		{
			var command:String = 'LOAD  ' + channel + ' \"' + file + '\" ' + (loop ? "LOOP" : "") + SOCKET_COMMAND_END;
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_OTHER_COMMAND } );
			return command;
		}
		
		/**
		 * Loads and prepares a clip for playout in the background. It does not affect the currently playing clip in anyway. This is how you prepare a transition between to clips. Supply the LOOP parameter if you want the clip to loop.
		 * @param	channel The channel
		 * @param	file The file to load
		 * @param	loop Loop the clip (default: false)
		 * @param	transition The type of transition, use one of the transition contants in this class: ServerConnection.TRANSITION_CUT, ServerConnection.TRANSITION_MIX, ServerConnection.TRANSITION_PUSH, ServerConnection.TRANSITION_SLIDE, ServerConnection.TRANSITION_WIPE. (default: ServerConnection.TRANSITION_CUT)
		 * @param	duration The length of the transition in frames
		 * @param	direction Push, slide and wipe needs a direction, use one of the direction contants in this class: ServerConnection.DIRECTION_FROMLEFT and ServerConnection.DIRECTION_FROMRIGHT. (default: ServerConnection.DIRECTION_FROMLEFT)
		 * @param	border Push, slide and wipe can have a border. (filename / #aarrggbb).
		 * @param	borderWidth The width of the border if it’s not an image
		 */
		public function LoadMediaBG(channel:uint, file:String, loop:Boolean = false, transition:String = ServerConnection.TRANSITION_CUT, duration:int = 0, direction:String = ServerConnection.DIRECTION_FROMLEFT, border:String = "", borderWidth:int = 0):String 
		{
			var command:String = 'LOADBG  ' + channel + ' \"' + file + '\" ' + (loop ? "LOOP" : "") + ' ' + transition + ' ' + duration + ' ' + direction + ' \"' + border +'\" ' + borderWidth + SOCKET_COMMAND_END;
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_OTHER_COMMAND } );
			return command; 
		}
		
		/**
		 * Starts the playout on a channel. If a transition is prepared it will execute and then the new clip will keep playing.
		 * @param	channel The channel
		 */
		public function PlayMedia(channel:uint):String 
		{
			var command:String = 'PLAY ' + channel + SOCKET_COMMAND_END;
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_OTHER_COMMAND } );
			return command;
		}
		
		/**
		 * Stops the playout on a channel. Nothing is done to prevent flickering if the channel is operating in a fields-based videomode.
		 * @param	channel The channel
		 */
		public function StopMedia(channel:uint):String 
		{
			var command:String = 'STOP ' + channel + SOCKET_COMMAND_END;
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_OTHER_COMMAND } );
			return command;
		}
		
		/**
		 * Stops the playout if running and removes anything visible (by loading an transparent black frame). Please note that this DOES NOT AFFECT any template graphics that happens to be visible.
		 * @param	channel The channel
		 */
		public function ClearMedia(channel:uint):String 
		{
			var command:String = 'CLEAR ' + channel + SOCKET_COMMAND_END;
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_OTHER_COMMAND } );
			return command;
		}
		
		/**
		 * Stores the dataset data under the name name.
		 * @param	name The name to store the data as
		 * @param	data XML data as defined in http://casparcg.com/wiki/CasparCG_1.8.0_AMCP_Protocol#Template_data
		 */
		public function StoreDataset(name:String, data:XML):String 
		{
			var command:String = 'DATA STORE \"' + name +'\" \"' + String(data).replace(/\"/g, "\\\"") + '\"' + SOCKET_COMMAND_END;
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_OTHER_COMMAND } );
			return command;
		}
		
		/**
		 * Returns the data saved under the name name. Will dispatch a ServerConnection.ON_DATARETRIEVE event if successfull otherwise a ServerConnection.ON_ERROR.
		 * @param	name The name of the data to retrieve
		 */
		public function GetData(name:String):String 
		{
			//BUG ON SUCCESS, CASPAR DOES NOT RETURN ANY RESPONSE CODE
			var command:String = 'DATA RETRIEVE \"' + name +'\"' + SOCKET_COMMAND_END;
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_GET_DATA } );
			return command;
		}
		
		/**
		 * Returns a list of all saved datasets. Will dispatch a ServerConnection.ON_DATALIST event if successfull otherwise a ServerConnection.ON_ERROR.
		 */
		public function GetDatasets():String 
		{
			var command:String = 'DATA LIST' + SOCKET_COMMAND_END;
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_GET_DATASETS } );
			return command;
		}
		
		////////////////////////////////
		//Commands for template graphics
		////////////////////////////////
		
		/**
		 * Prepares a template for displaying. It won’t show until you call CG PLAY (unless you supply the play-on-load flag, which is simply a ‘1’. ‘0’ for “don’t play on load”). data is either inline xml or a reference to a saved dataset.
		 * @param	channel The channel
		 * @param	layer The layer to add the template at
		 * @param	template the name of the template
		 * @param	playOnLoad Play the template automatically after loaded (default: false)
		 * @param	data The data to pass to the template, see http://casparcg.com/wiki/CasparCG_1.8.0_AMCP_Protocol#Format
		 */
		public function LoadTemplate(channel:uint, layer:int, template:String, playOnLoad:Boolean = false, data:* = ""):String 
		{
			var templateData:String = data;
			templateData = templateData.replace(/\n|\r|\t/g, "");
			//templateData = StringUtil.remove(templateData, " ");
			var command:String = 'CG ' + channel.toString() + ' ADD ' + layer.toString() + ' \"' + template + '\" ' + (playOnLoad ? "1" : "0") + ' \"' + templateData.replace(/\"/g, "\\\"") + '\"' + SOCKET_COMMAND_END;
			trace("COMMAND:", command);
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_OTHER_COMMAND } );
			return command;
		}
		
		/**
		 * Removes the visible template from a specific layer.
		 * @param	channel The channel
		 * @param	layer The layer to remove a template from
		 */
		public function RemoveTemplate(channel:uint, layer:int):String 
		{
			var command:String = 'CG ' + channel + ' REMOVE ' + layer + SOCKET_COMMAND_END;
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_OTHER_COMMAND } );
			return command;
		}
		
		/**
		 * Clears all layers and any state that might be stored. What this actually does behind the scene is to create a new instance of the Adobe Flash player ActiveX controller in memory.
		 * @param	channel The channel
		 */
		public function ClearTemplates(channel:uint):String 
		{
			var command:String = 'CG ' + channel + ' CLEAR' + SOCKET_COMMAND_END;
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_OTHER_COMMAND } );
			return command;
		}
		
		/**
		 * Plays / displays the template in the specified layer
		 * @param	channel The channel
		 * @param	layer The layer to play
		 */
		public function PlayTemplate(channel:uint, layer:int):String 
		{
			var command:String = 'CG ' + channel + ' PLAY ' + layer + SOCKET_COMMAND_END;
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_OTHER_COMMAND } );
			return command;
		}
		
		/**
		 * Stops and removes the template from the specified layer. This is different than REMOVE in that the template gets a chance to animate out when it is stopped.
		 * @param	channel The channel
		 * @param	layer The layer to stop
		 */
		public function StopTemplate(channel:uint, layer:int):String 
		{
			var command:String = 'CG ' + channel + ' STOP ' + layer + SOCKET_COMMAND_END;
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_OTHER_COMMAND } );
			return command;
		}
		
		/**
		 * Triggers a ”continue” in the template on the specified layer. This is used to control animations that has multiple discreet steps.
		 * @param	channel The channel
		 * @param	layer The layer to perform the next command on
		 */
		public function Next(channel:uint, layer:int):String 
		{
			var command:String = 'CG ' + channel + ' NEXT ' + layer + SOCKET_COMMAND_END;
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_OTHER_COMMAND } );
			return command;
		}
		
		/**
		 * Jumps to the specified label in the template on the specified layer.
		 * @param	channel The channel
		 * @param	layer The layer to perform the goto command on
		 * @param	label The label to jump to
		 */
		public function GotoLabel(channel:uint, layer:int, label:String):String 
		{
			var command:String = 'CG ' + channel + ' GOTO ' + layer + ' \"' + label + '\"' + SOCKET_COMMAND_END;
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_OTHER_COMMAND } );
			return command;
		}
		
		/**
		 * Sends new data to the template on specified layer. data is either inline xml or a reference to a saved dataset. (SetData)
		 * @param	channel The channel
		 * @param	layer The layer to update
		 * @param	data XML data or a reference to a saved dataset
		 */
		public function SetData(channel:uint, layer:int, data:*):String 
		{
			var templateData:String = data;
			templateData = templateData.replace(/\n|\r|\t/g, "");
			var command:String = 'CG ' + channel + ' UPDATE ' + layer + ' \"' + templateData.replace(/\"/g, "\\\"") + '\"' + SOCKET_COMMAND_END;
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_OTHER_COMMAND } );
			return command;
		}
		
		/**
		 * Calls a custom method in the document class of the template on the specified layer. The method must return void and take no parameters.
		 * @param	channel The channel
		 * @param	layer The layer to perform the invoke command on
		 * @param	method The method to call
		 */
		public function Invoke(channel:uint, layer:int, method:String):String 
		{
			var command:String = 'CG ' + channel + ' INVOKE ' + layer + ' \"' + method + '\"' + SOCKET_COMMAND_END;
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_OTHER_COMMAND } );
			return command;
		}
		
		////////////////////////////////////
		//Commands for statistics and status
		////////////////////////////////////
		
		/**
		 * Returns information about a mediafile
		 * @param	filename The name of the file
		 */
		public function GetMediaFileInfo(filename:String):String 
		{
			var command:String = 'CINF \"'+ filename +'\"'+SOCKET_COMMAND_END;
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_MEDIAFILE_INFO } );
			return command;
		}
		
		/**
		 * Lists all mediafiles
		 */
		public function GetMediaFiles():String 
		{
			var command:String = 'CLS' + SOCKET_COMMAND_END;
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_GET_MEDIAFILES } );
			return command;
		}
		
		/**
		 * Lists all templates. Lists only templates in the specified folder, if provided.
		 * @param	folder The folder to list (default: "")
		 */
		public function GetTemplates(folder:String = ""):String 
		{
			var command:String;
			if (folder == "")
			{
				command = 'TLS'+SOCKET_COMMAND_END;
			}
			else
			{
				command = 'TLS \"' + folder + '\"' + SOCKET_COMMAND_END;
			}
			
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_GET_TEMPLATES } );
			return command;
		}
		
		/**
		 * Returns the version of the server.
		 */
		public function GetVersion():String 
		{
			var command:String = 'VERSION' + SOCKET_COMMAND_END;
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_VERSION } );
			return command;
		}
		
		/**
		 * Returns information about the channels on the server. Use this without parameters to check how many channels a server has.
		 * @param	channel The channel (default: -1)
		 */
		public function GetInfo(channel:int = -1):String 
		{
			var command:String;
			if (channel == -1)
			{
				command = 'INFO'+SOCKET_COMMAND_END;
			}
			else
			{
				command = 'INFO ' + channel + SOCKET_COMMAND_END;
			}
			
			_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_INFO } );
			return command;
		}
		///////////////
		//Misc commands
		///////////////
		
		/**
		 * Disconnects from the server.
		 */
		//public function Disconnect():void 
		//{
			//var command:String = 'BYE' + SOCKET_COMMAND_END;
			//_socket.addCommand( { command: command, type: ServerConnectionEvent.ON_OTHER_COMMAND } );
			//_userForcedDisconnection = true;
		//}
		
		private function configureListeners():void 
		{
			_socket.addEventListener(ServerConnectionEvent.ON_CONNECT, dispatchAMCPEvent);
			_socket.addEventListener(ServerConnectionEvent.ON_DISCONNECT, onSocketClosed);
			_socket.addEventListener(ServerConnectionEvent.ON_MEDIAFILE_INFO, dispatchAMCPEvent);
			_socket.addEventListener(ServerConnectionEvent.ON_GET_MEDIAFILES, dispatchAMCPEvent);
			_socket.addEventListener(ServerConnectionEvent.ON_GET_DATASETS, dispatchAMCPEvent);
			_socket.addEventListener(ServerConnectionEvent.ON_GET_DATA, dispatchAMCPEvent);
			_socket.addEventListener(ServerConnectionEvent.ON_INFO, dispatchAMCPEvent);
			_socket.addEventListener(ServerConnectionEvent.ON_OTHER_COMMAND, dispatchAMCPEvent);
			_socket.addEventListener(ServerConnectionEvent.ON_SUCCESS, dispatchAMCPEvent);
			_socket.addEventListener(ServerConnectionEvent.ON_GET_TEMPLATES, dispatchAMCPEvent);
			_socket.addEventListener(ServerConnectionEvent.ON_VERSION, dispatchAMCPEvent);
			_socket.addEventListener(ServerConnectionEvent.ON_IO_ERROR, ioErrorHandler);
			_socket.addEventListener(ServerConnectionEvent.ON_SECURITY_ERROR, securityErrorHandler);
			_socket.addEventListener(ServerConnectionEvent.ON_LOG, dispatchAMCPEvent);
			
			
			_timer.addEventListener(TimerEvent.TIMER, onTimerReconnect);
		}
		
		private function dispatchAMCPEvent(e:ServerConnectionEvent):void
		{
			dispatchEvent(e);
		}
		
		private function unregisterListeners():void 
		{
			_socket.removeEventListener(ServerConnectionEvent.ON_CONNECT, dispatchAMCPEvent);
			_socket.removeEventListener(ServerConnectionEvent.ON_DISCONNECT, onSocketClosed);
			_socket.removeEventListener(ServerConnectionEvent.ON_MEDIAFILE_INFO, dispatchAMCPEvent);
			_socket.removeEventListener(ServerConnectionEvent.ON_GET_MEDIAFILES, dispatchAMCPEvent);
			_socket.removeEventListener(ServerConnectionEvent.ON_GET_DATASETS, dispatchAMCPEvent);
			_socket.removeEventListener(ServerConnectionEvent.ON_GET_DATA, dispatchAMCPEvent);
			_socket.removeEventListener(ServerConnectionEvent.ON_INFO, dispatchAMCPEvent);
			_socket.removeEventListener(ServerConnectionEvent.ON_OTHER_COMMAND, dispatchAMCPEvent);
			_socket.removeEventListener(ServerConnectionEvent.ON_SUCCESS, dispatchAMCPEvent);
			_socket.removeEventListener(ServerConnectionEvent.ON_GET_TEMPLATES, dispatchAMCPEvent);
			_socket.removeEventListener(ServerConnectionEvent.ON_VERSION, dispatchAMCPEvent);
			_socket.removeEventListener(ServerConnectionEvent.ON_LOG, dispatchAMCPEvent);
			_socket.removeEventListener(ServerConnectionEvent.ON_IO_ERROR, ioErrorHandler);
			_socket.removeEventListener(ServerConnectionEvent.ON_SECURITY_ERROR, securityErrorHandler);
			_timer.removeEventListener(TimerEvent.TIMER, onTimerReconnect);
		}
		
		/**
		 * Is called when the socket is closed. If the closedown wasn't forced by the user, it tries to reconnect.
		 * @param	e ServerConnectionEvent
		 */
		private function onSocketClosed(e:ServerConnectionEvent):void
		{
			
			var host:String = _socket.host;
			var port:uint = _socket.port;
			
			trace("ServerConnection::not connected, try reconnect? " , !_userForcedDisconnection);
			if (_autoReconnect && !_userForcedDisconnection)
			{
				reconnect();
			}
			
			dispatchEvent(e);
		}
		
		/**
		 * Handle io errors from the socket and dispatch the event. 
		 * @param	e ServerConnection
		 */
		private function ioErrorHandler(e:ServerConnectionEvent):void
		{
			
			switch (e.command)
			{
				case "SocketCommandFailedNoConnection":
					
					break;
				default:
					if (!_socket.connected)
					{
						trace("ServerConnection::not connected, try reconnect? " , !_userForcedDisconnection);
						if (_autoReconnect && !_userForcedDisconnection)
						{
							
							reconnect();
						}
					}
					break;
			}
			
			
			
			
			dispatchEvent(e);
		}
		
		
		/**
		 * Handle security errors from the socket and dispatch the event
		 * @param	e ServerConnection
		 */
		private function securityErrorHandler(e:ServerConnectionEvent):void
		{
			trace("ServerConnection::Security error");
			dispatchEvent(e);
		}
		
		/**
		 * Will try reconnect till a connection is established
		 */
		private function reconnect():void 
		{
			_timer.reset();
			_timer.start();
		}
		
		/**
		 * Is Called on timerEvent.TIMER to check whether there is a socket connection or not. If not try to reconnect.
		 * @param	e TimerEvent
		 */
		private function onTimerReconnect(e:TimerEvent):void 
		{
			if (_socket.connected)
			{
				_timer.stop();
				_timer.reset();
			}
			else
			{
				if (_userForcedDisconnection)
				{
					_timer.stop();
					_timer.reset();
					dispatchAMCPEvent(new ServerConnectionEvent(ServerConnectionEvent.ON_DISCONNECT));
				}
				else
				{
					doNewConnection(_socket.host, _socket.port);
				}
			}
		}
		
		/**
		 * Connects to a caspar server
		 * @param	server The server name
		 * @param	port The port number (default 5250)
		 */
		private function doNewConnection(host:String, port:uint):void
		{
			_socket.connect(host, port);
			_userForcedDisconnection = false;
			
		}
		
		
    }
}

import flash.errors.*;
import flash.events.*;
import flash.net.Socket;
import flash.utils.Timer;
import caspar.network.data.*;
import caspar.network.ServerConnectionEvent;

class CustomSocket extends Socket
{
	
    private var _response:String;
	private var _commandQueue:Array;
	private var _host:String;
	private var _port:uint;
	private var totalSize:int = 0;

    public function CustomSocket() {
		
        super();
        configureListeners();
		
    }
	
	override public function connect(host:String, port:int):void 
	{
		_host = host;
		_port = port;
		_commandQueue = [];
		
		super.connect(host, port);
	}
	
	override public function close():void 
	{
		
		super.close();
		dispatchEvent(new ServerConnectionEvent(ServerConnectionEvent.ON_DISCONNECT, false, false, "SocketDisconnect", "Disconnected from " + _host + " at port " + _port));
		
	}
	
	public function addCommand(command:Object):void
	{
		if (this.connected)
		{
			_commandQueue.push(command);
			if (_commandQueue.length == 1)
			{
				nextCommand();
			}
		}
		else
		{
			trace("ServerConnection::No socket connection, use ServerConnection.connect to connect to a socket.");
			dispatchEvent(new ServerConnectionEvent(ServerConnectionEvent.ON_IO_ERROR, false, false, "SocketCommandFailedNoConnection", "Tries to execute command before connected to any host"));
			
		}
	}
	
	private function nextCommand():void 
	{
		if (_commandQueue.length > 0)
		{
			sendRequest(_commandQueue[0].command);
		}
		
	}
	
	private function commandFinished():void
	{
		_commandQueue.splice(0, 1);
		nextCommand();
	}
	
	private function configureListeners():void {
        addEventListener(Event.CLOSE, closeHandler);
        addEventListener(Event.CONNECT, connectHandler);
        addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
    }
	
	private function unregisterListeners():void {
        removeEventListener(Event.CLOSE, closeHandler);
        removeEventListener(Event.CONNECT, connectHandler);
        removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        removeEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
    }

    private function writeln(str:String):void {
        //str += "\n";
		try {
            writeUTFBytes(str);
        }
        catch(e:IOError) {
            trace("ServerConnection::"+e);
        }
    }

    private function sendRequest(request:String):void {
        _response = "";
        writeln(request);
        flush();
		writeln("\r\n");
		flush();
    }

    private function readResponse():void {
		//totalSize += this.bytesAvailable;
		//trace(this.readInt(), this.bytesAvailable, totalSize);
        var str:String = this.readUTFBytes(bytesAvailable);
		//super.
        _response += str;
		//Är det ifall vi skickar två kommando i rad?
		//BUG: We cannot use this check for determining the end of packets, need to find a new one
		if(_commandQueue[0].type == ServerConnectionEvent.ON_GET_TEMPLATES || _commandQueue[0].type == ServerConnectionEvent.ON_GET_MEDIAFILES)
		{
			if (_response.charAt(_response.length - 1) == "\n" && _response.charAt(_response.length - 2) == "\r" && _response.charAt(_response.length - 3) == "\n" && _response.charAt(_response.length - 4) == "\r")
			{
				dispatchEvents(_response, _commandQueue[0].command, _commandQueue[0].type);
				dispatchEvent(new ServerConnectionEvent(ServerConnectionEvent.ON_LOG, false, false, "", _response));
				commandFinished();
			}
		}
		else
		{
			if (_response.charAt(_response.length - 1) == "\n" && _response.charAt(_response.length - 2) == "\r")
			{
				dispatchEvents(_response, _commandQueue[0].command, _commandQueue[0].type);
				dispatchEvent(new ServerConnectionEvent(ServerConnectionEvent.ON_LOG, false, false, "", _response));
				commandFinished();
			}
		}
    }
	
	private function dispatchEvents(response:String, command:String, type:String):void 
	{
		var responseArray:Array = response.split("\n");
		var responseCode:String = (responseArray[0].split(" "))[0];
		var responseMessage:String = responseArray[0];
		var data:*;
		var casparItemList:CasparItemInfoCollection;
		
		//DATARETRIEVE BUG ON SUCCESS, CASPAR DOES NOT RETURN ANY RESPONSE CODE
		if (responseArray[0].charAt(0) == "<" && responseCode.charAt(0) == "<")
		{
			responseCode = "201";
			responseMessage = "201 DATA RETRIEVE OK";
		}
		
		if (responseCode.charAt(0) == "2")
		{
			dispatchEvent(new ServerConnectionEvent(ServerConnectionEvent.ON_SUCCESS, false, false, command, responseMessage));
			var i:int = 0;
			var size:String;
			var date:String;
			var rawData:Array;
			
			switch(type)
			{
				case ServerConnectionEvent.ON_MEDIAFILE_INFO:
					data = String(responseArray[1]);
					break;
				case ServerConnectionEvent.ON_GET_MEDIAFILES:
					var mediaList:Array = new Array();
					for (i = 1; i < responseArray.length - 2; i++)
					{
						rawData = responseArray[i].split("\"");
						var media:CasparItemInfo = new CasparItemInfo();
						var mediaLocation:String = rawData[1];
						
						var subtype:String = rawData[2].split(" ")[2];
						size = rawData[2].split(" ")[4];
						date = rawData[2].split(" ")[5];
						
						var mediaPath:String = responseArray[i];
						
						mediaPath = mediaLocation.replace(/\r/g, "");
						mediaPath = mediaPath.replace(/\"/g, "");
						mediaPath = mediaPath.replace(/\\/g, "/");
						
						media.path = mediaPath;

						if (mediaPath.search("/") == -1)
						{
							media.folder = "";
							media.name = mediaPath; 
						}
						else
						{
							media.folder = mediaPath.split("/")[0];
							media.name = mediaPath.slice(mediaPath.indexOf("/")+1);
						}
						media.date = date;
						media.size = size;
						media.subtype = subtype;
						media.type = CasparItemInfo.TYPE_MEDIA;						
						mediaList.push(media);
						
					}
					casparItemList = new CasparItemInfoCollection(mediaList);
					break;
				case ServerConnectionEvent.ON_GET_DATASETS:
					data = new Array();
					for (i = 1; i < responseArray.length - 2; i++)
					{
						data.push(responseArray[i]);
					}
					break;
				case ServerConnectionEvent.ON_GET_DATA:
					data = new XML(responseArray[0]);
					break;
				case ServerConnectionEvent.ON_INFO:
					data = new Array();
					for (i = 1; i < responseArray.length - 2; i++)
					{
						data.push(responseArray[i]);
					}
					break;
				case ServerConnectionEvent.ON_GET_TEMPLATES:
					var templateList:Array = new Array();
					for (i = 1; i < responseArray.length - 2; i++)
					{
						rawData = responseArray[i].split("\"");
						var template:CasparItemInfo = new CasparItemInfo();
						var templateLocation:String = rawData[1];
						size = rawData[2].split(" ")[1];
						date = rawData[2].split(" ")[2];
						
						var templatePath:String = responseArray[i];
						
						templatePath = templateLocation.replace(/\r/g, "");
						templatePath = templatePath.replace(/\"/g, "");
						templatePath = templatePath.replace(/\\/g, "/");
						
						template.path = templatePath;

						if (templatePath.search("/") == -1)
						{
							template.folder = "";
							template.name = templatePath; 
						}
						else
						{
							template.folder = templatePath.split("/")[0];
							template.name = templatePath.slice(templatePath.indexOf("/")+1);
						}
						template.date = date;
						template.size = size;
						template.type = CasparItemInfo.TYPE_TEMPLATE;						
						templateList.push(template);
						
					}
					casparItemList = new CasparItemInfoCollection(templateList);
					break;
				default:
					dispatchEvent(new ServerConnectionEvent(ServerConnectionEvent.ON_OTHER_COMMAND, false, false, command, responseMessage));
			}
		}
		else
		{
			dispatchEvent(new ServerConnectionEvent(ServerConnectionEvent.ON_ERROR, false, false, command, responseMessage));
		}

		var e:ServerConnectionEvent = new ServerConnectionEvent(type, false, false, command, responseMessage, data, casparItemList);
		dispatchEvent(e);
		
	}

    private function closeHandler(event:Event):void {
		
		trace("ServerConnection::EVT: SOCKET CLOSE");
		close();

    }

    private function connectHandler(event:Event):void {
		trace("ServerConnection::EVT: SOCKET CONNECT");
		dispatchEvent(new ServerConnectionEvent(ServerConnectionEvent.ON_CONNECT, false, false, "SocketConnect", "Connected to " + _host + " at port " + _port));
		
		//probably not needed, screws up the command flow.
		//if (_commandQueue.length > 0)
		//{
			//trace(ServerConnectionEvent::this.connected);
			//nextCommand();
		//}
		
    }

    private function ioErrorHandler(event:IOErrorEvent):void {
		trace("ServerConnection::EVT: SOCKET IO ERROR");
		dispatchEvent(new ServerConnectionEvent(ServerConnectionEvent.ON_IO_ERROR, false, false, "", event.text));
		commandFinished();
    }

    private function securityErrorHandler(event:SecurityErrorEvent):void {
		trace("ServerConnection::EVT: SOCKET SECURITY ERROR");
		dispatchEvent(new ServerConnectionEvent(ServerConnectionEvent.ON_SECURITY_ERROR, false, false, "", event.text));
		commandFinished();
    }

    private function socketDataHandler(event:ProgressEvent):void {
        trace("ServerConnection::EVT: SOCKET RECIVE DATA");
		this.readResponse();
    }
	
	public function get host():String { return _host; }
	
	public function get port():uint { return _port; }
}