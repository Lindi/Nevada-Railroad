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
			trace( "BitmapBuilder.build("+index+")");
			trace( url );
					
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
					trace( "BitmapBuilder.complete("+event+","+index+")");
					trace( loaderInfo.url );
					( components[ image.@id ] as Bitmap ).bitmapData = ( loaderInfo.content as Bitmap ).bitmapData ;
					
					//	Remove the listener
					( event.target as LoaderInfo ).removeEventListener
						( Event.COMPLETE, arguments.callee );
						

					//	Get rid of the loader
					loaders.splice( loaders.indexOf( loader ), 1 );
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
				try {
					//	Make the file request and request it
					loader.load( new URLRequest( url ));
					loaders.push( loader );
					
				} catch (error:Error) {
					trace("Unable to load requested document.");
				}	
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
		
	}
}