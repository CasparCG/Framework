//f0:titel
//f1:undertitel

package  
{
	
	//import base64.Base64;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import se.svt.caspar.template.components.ICaspar2Component;
	
	/**
	 * ...
	 * @author Andreas Jeansson, SVT
	 */
	public class CasparImage extends MovieClip implements ICaspar2Component
	{
		
		private static const BASE64_CHARS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
		private var _bitmap_x:Number = 0;n
		private var _bitmap_y:Number = 0;
		private var _bitmap_scale:Number = 100;
		private var _bitmap_scaleX:Number = 100;
		private var _bitmap_scaleY:Number = 100;
		private var _bitmap_mirrorX:Boolean = false;
		private var _bitmap_mirrorY:Boolean = false;
		private var _bitmap_rotation:Number = 0;
		private var _bitmap_opacity:Number = 100;
		
		private var _imageMask:Sprite;
		private var _bitmap:Bitmap;
		private var _firstSetData:Boolean = true;
		
		private var _topLayer:Sprite;
		private var _imageHolder:Sprite;
		
		private var _originalWidth:Number;
		private var _originalHeight:Number;
		
		private var _outline:Sprite;
		private var _infoField:MovieClip;
		
		public function CasparImage() 
		{
			
			_imageHolder = new Sprite();
			addChild(_imageHolder);
			_topLayer = new Sprite();
			addChild(_topLayer);
		
			
			_originalWidth = this.width;
			_originalHeight = this.height;
			
			_outline = new Sprite();
			_outline.graphics.beginFill(0xebebeb, .4);
			_outline.graphics.lineStyle(0, 0xEBEBEB);
			_outline.graphics.drawRect(0, 0, _originalWidth, _originalHeight);
			_outline.graphics.endFill();
			_outline.visible = false;
			_topLayer.addChild(_outline);
			_infoField = new infoField();
			_infoField.visible = false;
			_infoField.tf.text = this.name;
			//_infoField.tf.text = _originalWidth + " " + _originalHeight;
			
			_topLayer.addChild(_infoField);
			
			
			if (Capabilities.playerType == "External" || Capabilities.playerType == "StandAlone")
			{
				//container.visible = false;
			}
			else
			{
				container.visible = false;
			}
			_imageMask = drawRect(_originalWidth, _originalHeight);
			//toggleOutline(true);
		}
		
		
		private function toggleOutline(visible:Boolean):void
		{
			if (visible)
			{
				_infoField.scaleX = 1 / this.scaleX;
				_infoField.scaleY = 1 / this.scaleY;
				_outline.visible = true;
				_infoField.visible = true;
			}
			else
			{
				_outline.visible = false;
				_infoField.visible = false;
			}
		}

		private function drawRect(w:Number, h:Number):Sprite
		{
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0x000000);
			sprite.graphics.drawRect(0,0,w,h);
			sprite.graphics.endFill();
			return sprite;
		}
		
		private function loadBitmap(url:String):void
		{
			if (_imageHolder.numChildren > 0)
			{
				_bitmap.bitmapData.dispose();
				_imageHolder.removeChildAt(0);
			}
			var _loader:Loader = new Loader();
			_loader.load(new URLRequest(url));
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBitmapLoaded);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);			
		}
		
		private function onIOError(e:IOErrorEvent):void 
		{
			trace("Caspar2Image: Could not find the image", e.text);
		}
		
		private function loadBitmapBytes(bitmapBytes:ByteArray):void
		{
			var _loader:Loader = new Loader();
			_loader.loadBytes(bitmapBytes);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBitmapLoaded);	

		}
		
		private function onBitmapLoaded(e:Event):void
		{
			_bitmap = e.currentTarget.content;
			_bitmap.smoothing = true;
			
			_imageHolder.x = _originalWidth / 2;
			_imageHolder.y = _originalHeight / 2;
			
			_imageHolder.addChild(_bitmap);
			
			_bitmap.x = -_bitmap.width / 2.0;
			_bitmap.y = -_bitmap.height / 2.0;
						
			addChild(_imageMask);
			
			_imageMask.alpha  = .4;
			
			_imageHolder.mask = _imageMask;
		
			setInitValues();
			
			this.dispatchEvent(new Event(Event.COMPLETE));
				
		}
		
		private function setInitValues():void
		{
			bitmap_x = _bitmap_x;
			bitmap_y = _bitmap_y;
			bitmap_scale = _bitmap_scale;
			bitmap_mirrorX = _bitmap_mirrorX;
			bitmap_mirrorY = _bitmap_mirrorY;
			bitmap_rotation = _bitmap_rotation;
			bitmap_opacity = _bitmap_opacity;
		}
		
		/* INTERFACE se.svt.caspar.template.components.ICasparComponent */
		
		//<component name='CasparImage'><property name='text' type='string' info='URL to the image to load (.png, .jpg, .gif)' /><property name='x' type='number' info='X position offset' /><property name='y' type='number' info='Y position offset' /><property name='scale' type='number' info='The scale of the image (in percent)' /><property name='mirrorX' type='boolean' info='If true the image is mirrored in the x axis' /><property name='mirrorY' type='boolean' info='If true the image is mirrored in the y axis' /><property name='opacity' type='number' info='The opacity of the image (in percent)' /><property name='rotation' type='number' info='The rotation of the image (in degrees)' /><property name='bitmap' type='string' info='URL to the image to load (.png, .jpg, .gif)' /><property name='bitmapBytes' type='base64' info='Base64 representation of the image to load (.png, .jpg, .gif)' /></component>
		
		[Inspectable(name='description', defaultValue='<component name="CasparImage"><property name="text" type="string" info="URL to the image to load (.png, .jpg, .gif)" /><property name="x" type="number" info="X position offset" /><property name="y" type="number" info="Y position offset" /><property name="scale" type="number" info="The scale of the image (in percent)" /><property name="mirrorX" type="boolean" info="If true the image is mirrored in the x axis" /><property name="mirrorY" type="boolean" info="If true the image is mirrored in the y axis" /><property name="opacity" type="number" info="The opacity of the image (in percent)" /><property name="rotation" type="number" info="The rotation of the image (in degrees)" /><property name="bitmap" type="string" info="URL to the image to load (.png, .jpg, .gif)" /></component>')]
		public var description;
		
		public function SetData(xmlData:XML):void 
		{ 
			if (_firstSetData)
			{
				this.scaleX = this.scaleY = 1;
				removeChild(container);
			
				_firstSetData = false;
			}
			
			for each (var element:XML in xmlData.children())
			{
				switch(element.@id.toXMLString())
				{
					case "text":
						loadBitmap(element.@value.toXMLString());
						break;
					case "x":
						bitmap_x = Number(element.@value.toXMLString());
						break;
					case "y":
						bitmap_y = Number(element.@value.toXMLString());
						break;
					case "scale":
						bitmap_scale = Number(element.@value.toXMLString());
						break;
					case "outline":
						toggleOutline(element.@value.toXMLString().toLowerCase() == "false" ? false : true);
						break;
					//case "scaleY":
						//bitmap_scaleY = Number(element.@value.toXMLString());
						//break;
					case "mirrorX":
						bitmap_mirrorX = element.@value.toXMLString().toLowerCase() == "false" ? false : true;
						break;
					case "mirrorY":
						bitmap_mirrorY = element.@value.toXMLString().toLowerCase() == "false" ? false : true;
						break;
					case "opacity":
						bitmap_opacity = Number(element.@value.toXMLString());
						break;
					case "rotation":
						bitmap_rotation = Number(element.@value.toXMLString());
						break;
					case "bitmap":
						loadBitmap(element.@value.toXMLString());
						break;
					case "bitmapBytes":
						//loadBitmapBytes(decode(element.@value.toXMLString()));
						loadBitmapBytes(Base64.decode(element.@value.toXMLString()));
						break;
				}
			}			
		}
		
		public function SetDataObject(componentIdentifier:String, data:*):void 
		{ 
			if (_firstSetData)
			{
				this.scaleX = this.scaleY = 1;
				removeChild(container);
			
				_firstSetData = false;
			}
				
			if ((data as ByteArray) != null)
			{
				try
				{
					loadBitmapBytes((data as ByteArray));
				}
				catch (e:Error)
				{
					trace("Caspar2Image:", e);
				}
			}
					
		}
		
		  //private function decode(str:String):ByteArray
		  //{
			  //trace("DECODAR");
			   //var data:ByteArray = new ByteArray();
			   //var len:int = str.length;
			   //for (var n:int = 0; n < len; ++n)
					//data.writeByte(str.charCodeAt(n));
			   //return data;
		  //}

		public function dispose():void
		{
			try
			{
				if (_bitmap != null)
				{
					_bitmap.bitmapData.dispose();
					_imageHolder.removeChild(_bitmap);
				}
				_bitmap = null;
			}
			catch (e:Error)
			{
				throw new Error("CasparImage error in dispose: " + e.message);
			}
		}
		
		public function get bitmap_x():Number { return _bitmap_x; }
		
		public function set bitmap_x(value:Number):void 
		{
			if (_bitmap != null)
			{
				_bitmap_x = value;
				_imageHolder.x = _bitmap_x + (_originalWidth / 2);
			}
			else
			{
				_bitmap_x = value;
			}
		}
		
		public function get bitmap_y():Number { return _bitmap_y; }
		
		public function set bitmap_y(value:Number):void 
		{
			_bitmap_y = value;
			if (_bitmap != null)
			{
				_imageHolder.y = _bitmap_y + (_originalHeight / 2);
			}
		}
		
		public function get bitmap_scale():Number { return _bitmap_scale; }
		
		public function set bitmap_scale(value:Number):void 
		{
			_bitmap_scale = value;
			if (_bitmap != null)
			{
				bitmap_scaleX = bitmap_scaleY = _bitmap_scale;
			}
		}
		
		//public function get bitmap_scaleX():Number { return _bitmap_scaleX; }
		//
	
		//
		//public function get bitmap_scaleY():Number { return _bitmap_scaleY; }
		//
		
		private function set bitmap_scaleX(value:Number):void 
		{
			if (_bitmap_mirrorX) value = -value;
			_bitmap_scaleX = value;
			if (_bitmap != null)
			{
				_imageHolder.scaleX = _bitmap_scaleX / 100;
			}
		}
		
		private function set bitmap_scaleY(value:Number):void 
		{
			if (_bitmap_mirrorY) value = -value;
			_bitmap_scaleY = value;
			if (_bitmap != null)
			{
				_imageHolder.scaleY = _bitmap_scaleY / 100;
			}
		}
		//
		public function get bitmap_rotation():Number { return _bitmap_rotation; }
		
		public function set bitmap_rotation(value:Number):void 
		{
			_bitmap_rotation = value;
			if (_bitmap != null)
			{
				_imageHolder.rotation = _bitmap_rotation;
			}
		}
		
		public function get bitmap_opacity():Number { return _bitmap_opacity; }
		
		public function set bitmap_opacity(value:Number):void 
		{
			_bitmap_opacity = value;
			if (_bitmap != null)
			{
				_imageHolder.alpha = _bitmap_opacity / 100;
			}
		}
		
		public function get bitmap_mirrorX():Boolean { return _bitmap_mirrorX; }
		
		public function set bitmap_mirrorX(value:Boolean):void 
		{
			_bitmap_mirrorX = value;
			if (_bitmap != null)
			{
				if (_bitmap_mirrorX)
				{
					_imageHolder.scaleX = -Math.abs(_imageHolder.scaleX);
				}
				else
				{
					_imageHolder.scaleX = Math.abs(_imageHolder.scaleX);
				}
			}
		}
		
		public function get bitmap_mirrorY():Boolean { return _bitmap_mirrorY; }
		
		public function set bitmap_mirrorY(value:Boolean):void 
		{
			_bitmap_mirrorY = value;
			if (_bitmap != null)
			{
				if (_bitmap_mirrorY)
				{
					_imageHolder.scaleY = -Math.abs(_imageHolder.scaleY);
				}
				else
				{
					_imageHolder.scaleY = Math.abs(_imageHolder.scaleY);
				}
			}
		}

	}
	
}