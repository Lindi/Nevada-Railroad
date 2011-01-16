package com.madsystems.components.map
{
	import com.madsystems.state.event.StateEvent;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.display.Loader ;
	import flash.display.LoaderInfo ;
	import flash.display.StageDisplayState ;
	import flash.events.IOErrorEvent ;
	import flash.events.Event ;
	import flash.net.URLRequest 
	import flash.display.Bitmap;;

	public class Main extends MovieClip
	{
		private var map:Map ;
		public function Main()
		{
			super();
			
			//	This is a fullscreen interactive
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;

			//	Get the application directory
			var dir:File = File.applicationDirectory ;
			
			//	Get the directory for the routes
			var file:File = dir.resolvePath("map/routes/nevada") ;
			
			//	If we have a valid directory
			if ( file.isDirectory ) {
				
				var files:Array =
				[
					[
					 	{
							url: (file.url  + "/CARSON-COLORADO.json"),
							reverse: false,
							color: 0xffffff,
							thickness: 4
						}
					],
					[
					 	{
							url: (file.url  + "/CENTRAL-PACIFIC.json"),
							reverse: false,
							color: 0xffffff,
							thickness: 4 
						}
					],
					[
					 	{
							url: (file.url  + "/EUREKA-PALISADE.json"),
							reverse: false,
							color: 0xffffff,
							thickness: 4 
						}
					],
					[
					 	{
							url: (file.url  + "/NEVADA-CALIFORNIA-OREGON.json"),
							reverse: false,
							color: 0xffffff,
							thickness: 4 
						}
					],
					[
					 	{
							url: (file.url  + "/NEVADA-CENTRAL.json"),
							reverse: false,
							color: 0xffffff,
							thickness: 4 
						}
					],
					[
					 	{
							url: (file.url  + "/NEVADA-NORTHERN.json"),
							reverse: false,
							color: 0xffffff,
							thickness: 4 
						}
					],
					[
					 	{
							url: (file.url  + "/TONOPAH-GOLDFIELD.json"),
							reverse: false,
							color: 0xffffff,
							thickness: 4 
						}
					],
					[
					 	{
							url: (file.url  + "/VIRGINIA-TRUCKEE.json"),
							reverse: false,
							color: 0xffffff,
							thickness: 4 
						}
					],
					[
					 	{
							url: (file.url  + "/OTHERS.json"),
							reverse: false,
							color: 0xff0000,
							thickness: 1  
						}
					]
				];

				file =  dir.resolvePath("images/map") ;
				if ( file.isDirectory ) 
					var url:String = file.url  + "/NEVADA-MAP.jpg" ;
				
				//	Create a loader to load the bitmap
				var loader:Loader = new Loader( );
				var main:Main = this ;
				loader.contentLoaderInfo.addEventListener( Event.COMPLETE, 
					function ( event:Event ):void {
						//	trace( "build("+event+")");
						
						//	Extract the bitmap data 
						var loaderInfo:LoaderInfo = ( event.target as LoaderInfo ) ; 
						var bitmap:Bitmap = ( loaderInfo.content as Bitmap ) ;
						map = new Map( main, files, bitmap ) ;//, url, 2335.71, 2808 );
						main.addChild( map ) ;
						
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
					loader.load( new URLRequest( url ));
					
				} catch (error:Error) {}	
				
				//	This is where the tiles live
//				var url:String = "C:/Projects/Nevada/map/tiles/1866";
				
//				//	Now resolve the map tiles directory
//				map = new Map( this, [ file.url  + "/Full-Historic-Route.json" ], 2335.71, 2808 );
				
				//	Add the map when we're added to the stage
//				loaderInfo.addEventListener( Event.INIT,
//					function ( event:Event ):void {
//						addChild( map );
//						//	map.dispatchEvent( new StateEvent( StateEvent.RUN ));
//						loaderInfo.removeEventListener( Event.INIT, arguments.callee );
//					});
			}
		}
	}
}