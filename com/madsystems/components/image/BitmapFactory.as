package com.madsystems.components.image
{
	import com.madsystems.components.Builder;
	import com.madsystems.components.ComponentFactory;


	public class BitmapFactory extends ComponentFactory
	{
		private var builder:Builder ;
	
		override protected function create( component:XML ):Object {
			if ( !builder )
				builder = new BitmapBuilder( );
			return builder.build( component ) ;
		}

		ComponentFactory.add("image", new BitmapFactory( ));
		
	}
}

import com.madsystems.components.Builder;
import flash.display.Bitmap ;
import flash.display.BitmapData ;
import flash.display.Loader ;
import flash.display.LoaderInfo ;
import flash.events.IOErrorEvent ;
import flash.events.Event ;
import flash.net.URLRequest ;

//	We probably have to move this inside the public class
//	in order for AIR to find the definition?
//import flash.filesystem.File ;


class BitmapBuilder extends Builder
{
	
	override public function build( image:XML ):Object {
		
		//	Return the Bitmap if we've already made it
		var id:String = image.@id.toString() as String ;
		var bitmap:Bitmap = ( components[ id ] as Bitmap ) ;
		if ( bitmap ) 
			return bitmap ;
			
		//	Create a bitmap reference to be returned synchrononously
		bitmap = components[ image.@id ] = new Bitmap( );
		
		//	Create a loader to load the bitmap
		var loader:Loader = new Loader( );
		loader.contentLoaderInfo.addEventListener( Event.COMPLETE, 
			function ( event:Event ):void {
				trace( "build("+event+")");
				
				//	Extract the bitmap data 
				var loaderInfo:LoaderInfo = ( event.target as LoaderInfo ) ; 
				bitmap.bitmapData = ( loaderInfo.content as Bitmap ).bitmapData ;
				
				//	Remove the listener
				( event.target as LoaderInfo ).removeEventListener
					( Event.COMPLETE, arguments.callee );
					
			});
			
		//	Silently handle errant files
		loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR,
			function ( event:IOErrorEvent ):void {
				trace( event ) ;
				( event.target as LoaderInfo ).removeEventListener
					( IOErrorEvent.IO_ERROR, arguments.callee );
			});
		try {
			//	Get the application directory
			//var dir:File = File.applicationDirectory ;
			
			//	Get the directory for the routes
			//var file:File = dir.resolvePath(image.@url) ;
			
			//	Make the file request and request it
			var url:String = image.@url.toString();	
			loader.load( new URLRequest( image.@url.toString( ) ));
			
		} catch (error:Error) {
			trace("Unable to load requested document.");
		}	
		return bitmap ;
		
	}
}