package
{
	import com.adobe.images.JPGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	public class LoremPixel extends Sprite
	{
		private var loader:Loader;
		private var bmpData:BitmapData;
		private var counter:int = -1;
		private var dataDict:Array;
		private var percentDifference:Number;
		
		public function LoremPixel() {
			dataDict = new Array();
			load();
		}
		
		private function load():void
		{
			counter++;
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, saveBitmap);
			loader.load(new URLRequest("http://lorempixel.com/100/100"));
		}
		
		private function getBitmapDifference(bitmapData1:BitmapData, bitmapData2:BitmapData):Number 
		{
			var bmpDataDif:BitmapData = bitmapData1.compare(bitmapData2) as BitmapData;
			if(!bmpDataDif)
				return 0;
			var differentPixelCount:int = 0;
			
			var pixelVector:Vector.<uint> =  bmpDataDif.getVector(bmpDataDif.rect);
			var pixelCount:int = pixelVector.length;
			
			for (var i:int = 0; i < pixelCount; i++)
			{
				if (pixelVector[i] != 0)
					differentPixelCount ++;
			}
			
			return (differentPixelCount / pixelCount)*100;
		}
		
		private function checkAvailability(bd:BitmapData):Boolean
		{
			for each(var item:BitmapData in dataDict)
			{
				if(getBitmapDifference(item, bd) == 0)
				{
					return true;
				}
			}
			return false;
		}
		
		private function saveBitmap(e:Event):void
		{
			var image:Bitmap = e.currentTarget.content;
			image.x = 0;
			image.y = 0;
			addChild(image);
			
			var jpg:JPGEncoder = new JPGEncoder(70);
			
			var bd:BitmapData = new BitmapData(image.width, image.height);
			bd.draw(image);
			
			var ba:ByteArray = jpg.encode(bd);
			
			
			if(checkAvailability(bd))
			{
				counter--;
				load();
			}
			else
			{
				dataDict.push(bd);
				var file:File = File.desktopDirectory.resolvePath("images");
				file = file.resolvePath("image"+counter+".jpg");
				var fs:FileStream = new FileStream();
				fs.open(file, FileMode.WRITE);
				fs.writeBytes(ba, 0, ba.length);
				fs.close();
				
				setTimeout(load,500);
			}
		}
	}
}