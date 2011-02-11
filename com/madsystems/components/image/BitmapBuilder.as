package com.madsystems.components.image
{
	import com.madsystems.components.Builder;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.*;
	import flash.net.URLRequest;

	internal class BitmapBuilder extends Builder implements IEventDispatcher
	{
		private var dispatcher:EventDispatcher = new EventDispatcher( );
		private var index:int = 0 ;
		private var loaders:Array = new Array( );
		
		
		override public function build( image:XML ):Object {
			
			//	Return the Bitmap if we've already made it
			var id:String = image.@id.toString() as String ;
			var bitmap:Bitmap = ( components[ id ] as Bitmap ) ;
			if ( bitmap ) 
				return bitmap ;
		
			//	The image url
			var url:String = image.@url.toString( ) ;
			
			//	Increment the loader counter
			++index ;
			log( "BitmapBuilder.build("+index+")");
			log( url );
					
			//	Create a bitmap reference to be returned synchrononously
			bitmap = components[ id ] = new Bitmap( );
			
			//	Position the bitmap if we've included positioning data
			if ( image.@x )
				bitmap.x = Number( image.@x.toString());
			if ( image.@y )
				bitmap.y = Number( image.@y.toString());
			if (( image.attribute("alpha") as XMLList ).length() )
				bitmap.alpha = Number( image.@alpha.toString());
				
			//	Create a loader to load the bitmap
			var loader:Loader = new Loader( );
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, 
				function ( event:Event ):void {
					
					//	Extract the bitmap data 
					var loaderInfo:LoaderInfo = ( event.target as LoaderInfo ) ; 
					log( "BitmapBuilder.complete("+event+","+index+")");
					log( loaderInfo.url );
					( components[ image.@id ] as Bitmap ).bitmapData = ( loaderInfo.content as Bitmap ).bitmapData ;
					
					//	Remove the listener
					( event.target as LoaderInfo ).removeEventListener
						( Event.COMPLETE, arguments.callee );
						
					//	Dequeue the loaders array and load the next one
//					if ( loaders.length ) {
//						var obj:Object = loaders.shift();
//						( obj.loader as Loader ).load( obj.request as URLRequest );
//					} else {
//						dispatcher.dispatchEvent( event.clone());
//					}

					loaders.pop() ;
					log( loaders.length );
					if (!--index )
						dispatcher.dispatchEvent( event.clone());
						
				});
				
//			//	Progress Event Handler	
//			loader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS,
//				function ( event:ProgressEvent ):void {
//					var loaderInfo:LoaderInfo = ( event.target as LoaderInfo ) ; 
//					log("progressHandler: url=" + loaderInfo.url+ " bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
//					if ( event.bytesLoaded == event.bytesTotal ) {
//						//	Remove the listener
//						( event.target as LoaderInfo ).removeEventListener
//							( ProgressEvent.PROGRESS, arguments.callee );
//					}
//				});
				

			//	Silently handle errant files
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR,
				function ( event:IOErrorEvent ):void {
					trace( "BitmapBuilder.ioerror("+event+")");					
					( event.target as LoaderInfo ).removeEventListener
						( IOErrorEvent.IO_ERROR, arguments.callee );
				});
				
			//	If there's nothing in the loader's list
			//	otherwise, push the request on the list for loading later
			//if ( !loaders.length ) {
				try {
					//	Make the file request and request it
					loader.load( new URLRequest( url ));
					loaders.push( loader );
					
				} catch (error:Error) {
					log("Unable to load requested document.");
				}	
//			} else {
//				loaders.push({ loader: loader, request: new URLRequest( url )});
//			}
			return bitmap ;
			
		}
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			dispatcher.addEventListener( type, listener, useCapture, priority, useWeakReference ) ;
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			dispatcher.addEventListener( type, listener, useCapture ) ;
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return dispatcher.dispatchEvent( event );
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return dispatcher.hasEventListener( type );
		}
		
		public function willTrigger(type:String):Boolean
		{
			return dispatcher.willTrigger( type );
		}		
		
		private function log( message:* ):void 
		{
			return ;
			var myFile:File = File.desktopDirectory.resolvePath("nevada-log.txt");
		    var fileStream:FileStream = new FileStream();
		    fileStream.open(myFile, FileMode.READ);
		    var text:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
		    fileStream.close();

			text = text + "\n" + String( message );
		    fileStream.open(myFile, FileMode.WRITE);
		    
		    fileStream.writeUTFBytes( text );
		    fileStream.close();
		}
	}
}