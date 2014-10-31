//This is a modification of the original AddCommand in Caspar that enables .ct-files to load.

package se.svt.caspar.templateHost.externalCommands
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import se.svt.caspar.ITemplateContext;
	import se.svt.caspar.template.ICasparTemplate;
	import se.svt.caspar.templateHost.adapters.DefaultTemplateAdapter;
	import se.svt.caspar.templateHost.externalCommands.CommandEvent;
	import se.svt.caspar.templateHost.externalCommands.IExternalCommand;
	import se.svt.caspar.templateHost.extractors.CTFactory;
	import se.svt.caspar.templateHost.extractors.CTFactoryEvent;
	import se.svt.caspar.templateHost.ITemplateHost;
	
	/**
	 * ...
	 * @author Andreas Jeansson, Sveriges Television AB
	 */
	public class AddCommand extends EventDispatcher implements IExternalCommand
	{
		private var _layer:int;
		private var _templateName:String;
		private var _invoke:String;
		private var _xmlData:XML;
		private var _templateContext:ITemplateContext;
		private var _templateHost:ITemplateHost;
		//True if the command was successfully executed
		private var _success:Boolean = true;
		
		private var _cosmoFactory:CTFactory;
		
		public function AddCommand(layer:int, templateName:String, invoke:String, xmlData:XML, templateContext:ITemplateContext, templateHost:ITemplateHost):void 
		{
			//trace("new addcommand");
			_layer = layer;
			_templateName = templateName;
			_invoke = invoke;
			_xmlData = xmlData;
			_templateContext = templateContext;
			_templateHost = templateHost;
		}
		
		/**
		 * Tries to retrieve the original with and height variables from a template, if fail then set to default size.
		 * @param	template The template to be adjusted
		 */
		private function adjustTemplate(template:ICasparTemplate):void 
		{
			var templateOriginalWidth:Number;
			var templateOriginalHeight:Number;
			var ratioW:Number;
			var ratioH:Number;

			try 
			{
				templateOriginalWidth = template.originalWidth;
				templateOriginalHeight = template.originalHeight;
			} 
			catch (e:Error) 
			{
				templateOriginalWidth = 768;
				templateOriginalHeight = 576;
				_success = false;
				var error:String = "@Add@" + _layer + "@The template seems to be old so PAL is used as format. " + e;
				dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, _layer, error));
			}
			ratioW = _templateHost.screenWidth / templateOriginalWidth;
			ratioH = _templateHost.screenHeight / templateOriginalHeight;

			template.movieClip.scaleX = ratioW;
			template.movieClip.scaleY = ratioH;
		}
		
		private function onTemplateLoaded(event:Event):void 
		{
			try 
			{
				//dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "AddCommand: try onTemplateLoaded"));
				var version:String;
				var template:ICasparTemplate;
								
				if (event.currentTarget.content as ICasparTemplate == null)
				{
					template = new DefaultTemplateAdapter(event.currentTarget.content);
				}
				else
				{
					template = event.currentTarget.content as ICasparTemplate;
				}

				version = template.version;
				
				template.initialize(_templateContext);
				
				if (_invoke != "")
				{
					try
					{
						template.GotoLabel(_invoke);
					}
					catch(e:Error)
					{
						try 
						{
							template.ExecuteMethod(_invoke);
						}
						catch (e:Error)
						{
							_success = false;
							var invokeError:String = "@Add@" + _layer + "@" + e;
							dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, _layer, invokeError));
						}
						
					}
				}
				
				template.SetData(_xmlData);
			
				adjustTemplate(template);
									
				_templateHost.loadedTemplates.templateIsLoaded(template, _layer);

				template.movieClip.stop();
								
				_templateHost.registerTemplate(template);
				
			} 
			catch (e:Error) 
			{
				//dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "AddCommand: catch onTemplateLoaded"));
				_success = false;
				var error:String = "@Add@" + _layer + "@" + e;
				dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, _layer, error));
			}
			finally 
			{
				//dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "AddCommand: finally onTemplateLoaded"));
				dispatchEvent(new CommandEvent(CommandEvent.COMMAND_FINISHED, 0, "@Add@" + _layer, _success));
			}
		}
		
	
		
		/* INTERFACE se.svt.caspar.templateHost.externalCommands.IExternalCommand */
		
		//public function execute():void
		//{
			//try
			//{
				//dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "AddCommand: try execute"));
				//var _loader:Loader;
				//var target:URLRequest = new URLRequest(_templateName+".ft");
	//
				//_loader = new Loader();
				//_loader.contentLoaderInfo.addEventListener(Event.INIT, onTemplateLoaded);
				//_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				//_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				//_loader.contentLoaderInfo.addEventListener(Event.OPEN, onOpen);
				//_loader.load(target);
				//dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "AddCommand: try execute finished"));				
			//}
			//catch (e:Error) 
			//{
				//dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "AddCommand: catch execute"));
				//_success = false;
				//var error:String = "@Add@" + _layer + "@" + e;
				//dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, _layer, error));
				//dispatchEvent(new CommandEvent(CommandEvent.COMMAND_FINISHED, 0, "@Add@" + _layer, _success));
			//}
		//}
		
		//cosmo test
		public function execute():void
		{
			try
			{
				if (_templateName.indexOf(".ft") != -1)
				{
					//dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "AddCommand: try execute"));
					var _loader:Loader;
					var target:URLRequest = new URLRequest(_templateName);
		
					_loader = new Loader();
					_loader.contentLoaderInfo.addEventListener(Event.INIT, onTemplateLoaded);
					_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
					//_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
					//_loader.contentLoaderInfo.addEventListener(Event.OPEN, onOpen);
					_loader.load(target);
					//dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "AddCommand: try execute finished"));				
				}
				//load binary
				else if (_templateName.indexOf(".ct") != -1)
				{
					//trace("skapar ny cosmo facoty");
					_cosmoFactory = new CTFactory(_templateName);
					_cosmoFactory.addEventListener(CTFactoryEvent.DECOMPRESSED, onCTDecompressed);
				}
			}
			catch (e:Error) 
			{
				//dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "AddCommand: catch execute"));
				_success = false;
				var error:String = "@Add@" + _layer + "@" + e;
				dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, _layer, error));
				dispatchEvent(new CommandEvent(CommandEvent.COMMAND_FINISHED, 0, "@Add@" + _layer, _success));
			}
		}
		
		private function onCTDecompressed(e:CTFactoryEvent):void 
		{
			var _loader:Loader;
			var target:URLRequest = new URLRequest(_templateName);
			_xmlData = e.xmlData;

			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.INIT, onTemplateLoaded);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			//_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			//_loader.contentLoaderInfo.addEventListener(Event.OPEN, onOpen);
			_loader.loadBytes(e.templateBytes);
			
			_cosmoFactory.dispose();
			_cosmoFactory = null;
		}
		
		//private function onComplete(e:Event):void 
		//{
			//dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "AddCommand: onComplete"));
		//}
		
		//private function onOpen(e:Event):void 
		//{
			//dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "AddCommand: onOpen"));
		//}
		
		private function errorHandler(e:IOErrorEvent):void 
		{
			//dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "AddCommand: errorHandler"));
			_success = false;
			var error:String = "@Add@" + _layer + "@" + e;
			dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, _layer, error));
			dispatchEvent(new CommandEvent(CommandEvent.COMMAND_FINISHED, 0, "@Add@" + _layer, _success));
		}
		
	}
	
}