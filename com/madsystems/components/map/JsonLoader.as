package com.madsystems.components.map
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.Event ;
	import flash.events.IOErrorEvent ;
	import flash.net.URLLoader ;
	import flash.net.URLRequest ;
	import com.adobe.serialization.json.JSON;

	public class JsonLoader extends EventDispatcher {
	
	private var paths:Array ;

	public function queue( files:Array ):Array {
		this.paths = new Array( ) ;
		decode( files );
		return paths ;
	}
	
	public function load( file:String ):Array {
		this.paths = new Array( ) ;
		decode( [ file ] );
		return paths ;
	}
	
	private function decode( files:Array ):void {
		var url:String = ( files.shift() as String );

		//	Load the svg file
		var loader:URLLoader = new URLLoader();
		loader.addEventListener( Event.COMPLETE,
			function ( event:Event ):void
			{  
				//trace( event ) ;
				//	Build the paths
				var json:String = ( loader.data as String );
				//trace( json ) ;
				var object:Object = JSON.decode( json )  ;
				for each ( var e:Object in object ) {
					paths.push( e );					
				}
				loader.removeEventListener( event.type, arguments.callee );
				if ( files.length )
					decode( files ) ;
				else dispatchEvent( event );
			});
			
		//	Silently handle errant files
		loader.addEventListener( IOErrorEvent.IO_ERROR,
			function ( event:IOErrorEvent ):void {
				//trace( event ) ;
				( event.target as URLLoader ).removeEventListener
					( IOErrorEvent.IO_ERROR, arguments.callee );
			});
			
			
		try {
			loader.load(new URLRequest(url));
		} catch (error:Error) {}
	}
}
}