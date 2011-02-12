package com.madsystems.components.swf
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

	internal class SwfBuilder extends Builder implements IEventDispatcher
	{
		private var dispatcher:EventDispatcher = new EventDispatcher( );
		private var index:int = 0 ;
		private var loaders:Array = new Array( );
		
		
		override public function build( component:XML ):Object {
			
			//	Return the Bitmap if we've already made it
			var id:String = component.@id.toString() as String ;
			var loader:Loader = ( components[ id ] as Loader ) ;
			if ( loader ) 
				return loader ;
		
			//	The swf url
			var url:String = component.@url.toString( ) ;
			trace( "SwfBuilder("+url+")");
			//	Increment the loader counter
			++index ;
					
			//	Create a loader reference to be returned synchrononously
			loader = components[ id ] = new Loader( );
			
			//	Position the loader if we've included positioning data
			if ( component.@x )
				loader.x = Number( component.@x.toString());
			if ( component.@y )
				loader.y = Number( component.@y.toString());
			if (( component.attribute("alpha") as XMLList ).length() )
				loader.alpha = Number( component.@alpha.toString());
				
			//	Create a loader to load the loader
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, 
				function ( event:Event ):void {
					//	Extract the bitmap data 
					var loaderInfo:LoaderInfo = ( event.target as LoaderInfo ) ; 
					trace( "SwfBuilder.complete("+event+","+index+")");
					trace( loaderInfo.url );
					//	Remove the listener
					( event.target as LoaderInfo ).removeEventListener
						( Event.COMPLETE, arguments.callee );
						
					//	Get rid of the loader
					loaders.splice( loaders.indexOf( loader ), 1 );
					if (!--index )
						dispatcher.dispatchEvent( event.clone());
						
				});
				
				

			//	Silently handle errant files
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR,
				function ( event:IOErrorEvent ):void {
					trace( "SwfBuilder.ioerror("+event+")");					
					( event.target as LoaderInfo ).removeEventListener
						( IOErrorEvent.IO_ERROR, arguments.callee );
				});
				
			//	If there's nothing in the loader's list
			//	otherwise, push the request on the list for loading later
				try {
					//	Make the file request and request it
					loader.load( new URLRequest( url ));
					loaders.push( loader );
					
				} catch (error:Error) {}	
			return loader ;
			
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