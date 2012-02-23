//This is a modification of the original AddCommand in Caspar that enables .ct-files to load.

package se.svt.caspar.templateHost.externalCommands
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import se.svt.caspar.ITemplateContext;
	import se.svt.caspar.template.CasparTemplate;
	import se.svt.caspar.template.ICaspar2Template;
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
	
	//TODO: Read about ApplicationDomain
	 
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
		
		private var _ctFactory:CTFactory;
		private var _loader:Loader;
		private var _isCompressedTemplate:Boolean;
		
		
		public function AddCommand(layer:int, templateName:String, invoke:String, xmlData:XML, templateContext:ITemplateContext, templateHost:ITemplateHost):void 
		{
			_layer = layer;
			_templateName = templateName;
			_invoke = invoke;
			_xmlData = xmlData;
			_templateContext = templateContext;
			_templateHost = templateHost;
			_isCompressedTemplate = false;
		}
		
		/* INTERFACE se.svt.caspar.templateHost.externalCommands.IExternalCommand */
		
		public function execute():void
		{
			var error:String;
			try
			{
				if (_templateName.indexOf(".ft") != -1)
				{
					dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "AddCommand: try execute"));
					var target:URLRequest = new URLRequest(_templateName);
					var context:LoaderContext = new LoaderContext();
					context.allowCodeImport = true;
					_loader = new Loader();
					_loader.contentLoaderInfo.addEventListener(Event.INIT, onTemplateLoaded);
					_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
					//REMOVE THESE AND HANDLER
					//_loader.contentLoaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);
					//_loader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);

					try
					{
						_loader.load(target, context);
					}
					catch (e:Error)
					{
						trace(e);
					}
					
					dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "AddCommand: try execute finished"));				
				}
				//load binary
				else if (_templateName.indexOf(".ct") != -1)
				{
					dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "AddCommand: CT location: " + _templateName));	
					//TODO: Add more error handling, what if invalid zip? Or invalid content in zip?
					_isCompressedTemplate = true;
					_ctFactory = new CTFactory(_templateName);
					_ctFactory.addEventListener(CTFactoryEvent.DECOMPRESSED, onCTDecompressed);
				}
				//TODO: Add support for swf?
				else
				{
					_success = false;
					error = "@Add@" + _layer + "@" + "The file type was not specified or recognized";
					dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, _layer, error));
					dispatchEvent(new CommandEvent(CommandEvent.COMMAND_FINISHED, 0, "@Add@" + _layer, _success));
				}
			}
			catch (e:Error) 
			{
				dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "AddCommand: catch execute"));
				_success = false;
				error = "@Add@" + _layer + "@" + e;
				dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, _layer, error));
				dispatchEvent(new CommandEvent(CommandEvent.COMMAND_FINISHED, 0, "@Add@" + _layer, _success));
			}
		}
		
		public function dispose():void 
		{
			if (_loader != null)
			{
				_loader.contentLoaderInfo.addEventListener(Event.INIT, onTemplateLoaded);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				_loader = null;
			}
			
			_xmlData = null;
			_templateContext = null;
			_templateHost = null;
			if (_ctFactory != null)
			{
				_ctFactory.dispose();
				_ctFactory = null;
			}
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
				dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "AddCommand: try onTemplateLoaded"));
				var version:String;
				var template:ICasparTemplate;
					
				//trace("LOADER CONTENT:");
				//trace(event.currentTarget.content as ICasparTemplate);
				//trace(ICasparTemplate(event.currentTarget.content));
				//trace("");
				
				
				if (event.currentTarget.content as ICasparTemplate == null)
				{
					template = new DefaultTemplateAdapter(event.currentTarget.content);
				}
				else
				{
					template = event.currentTarget.content as ICasparTemplate;
				}

				version = template.version;
				
				_templateHost.registerTemplate(template);
				
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
				
				if (_isCompressedTemplate)
				{
					try
					{
						if ((template as ICaspar2Template) != null)
						{
							ICaspar2Template(template).SetDataObject(_ctFactory.getObjectAssets());
							template.SetData(_xmlData);
						}
						else
						{
							template.SetData(_ctFactory.getBase64Assets());
						}
					}
					catch (e:Error)
					{
						trace(e);
						template.SetData(_ctFactory.getBase64Assets());
					}
					finally
					{
						_ctFactory.dispose();
						_ctFactory = null;
					}
				}
				else
				{
					template.SetData(_xmlData);
				}
				
				
				
				try
				{
					if (template as ICaspar2Template != null)
					{
						ICaspar2Template(template).templateName = _templateName;
					}
				}
				catch (e:Error)
				{
					trace(e);
				}
			
				adjustTemplate(template);
									
				_templateHost.loadedTemplates.templateIsLoaded(template, _layer);

				template.movieClip.stop();
				
				//template.movieClip.loader = _loader;
								
				
				
			} 
			catch (e:Error) 
			{
				dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "AddCommand: catch onTemplateLoaded"));
				_success = false;
				var error:String = "@Add@" + _layer + "@" + e;
				dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, _layer, error));
			}
			finally 
			{
				dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "AddCommand: finally onTemplateLoaded"));
				dispatchEvent(new CommandEvent(CommandEvent.COMMAND_FINISHED, 0, "@Add@" + _layer, _success));
			}
		}

					
		private function onCTDecompressed(e:CTFactoryEvent):void 
		{
			var target:URLRequest = new URLRequest(_templateName);
			_xmlData = e.xmlData;
			
			var context:LoaderContext = new LoaderContext();
			context.allowCodeImport = true;

			_loader = new Loader();
			
			_loader.contentLoaderInfo.addEventListener(Event.INIT, onTemplateLoaded);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_loader.loadBytes(e.templateBytes, context);
		}
		
		private function uncaughtErrorHandler(event:UncaughtErrorEvent):void
        {
			event.preventDefault();
			dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "AddCommand: uncaughtErrorHandler"));
			var errorstr:String;
            if (event.error is Error)
            {
                var e:Error = event.error as Error;
				errorstr = e.message;
            }
            else if (event.error is ErrorEvent)
            {
                var errorEvent:ErrorEvent = event.error as ErrorEvent;
                errorstr = errorEvent.text;
            }
            else
            {
                errorstr = "A non-error or non-errorEvent was thrown";
            }
			
			_success = false;
			var error:String = "@Add@" + _layer + "@" + errorstr;
			dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, _layer, error));
			dispatchEvent(new CommandEvent(CommandEvent.COMMAND_FINISHED, 0, "@Add@" + _layer, _success));
        }
		
		private function errorHandler(e:IOErrorEvent):void 
		{
			dispatchEvent(new CommandEvent(CommandEvent.DEBUG_MESSAGE, 0, "AddCommand: errorHandler"));
			_success = false;
			var error:String = "@Add@" + _layer + "@" + e;
			dispatchEvent(new CommandEvent(CommandEvent.ON_ERROR, _layer, error));
			dispatchEvent(new CommandEvent(CommandEvent.COMMAND_FINISHED, 0, "@Add@" + _layer, _success));
		}		
	}
	
}