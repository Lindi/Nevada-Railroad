package com.madsystems.components.map
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.geom.Rectangle;

	public class Tiles extends Sprite
	{
		private var url:String ;
		private var bitmap:Bitmap ;
		private const cols:int = Math.ceil( Map.MAP_WINDOW_WIDTH / TILE_WIDTH );
		private const rows:int = Math.ceil( Map.MAP_WINDOW_HEIGHT / TILE_HEIGHT );
		private const n:int = ( rows * cols );
		
		public static const TILE_WIDTH:Number = 256 ;
		public static const TILE_HEIGHT:Number = 256 ;
		
		private static var tiles:Object = new Object( );
		
		
		public function Tiles( url:String )
		{
			super();
			this.url = url ;
			this.bitmap = addChild(  new Bitmap( new BitmapData( Map.MAP_WINDOW_WIDTH, Map.MAP_WINDOW_HEIGHT, false ))) as Bitmap;
		}

		/**
		 * render
		 * Renders the tiles
		 * 
		 * @param - position: a point whose coordinate are between
		 * zero and one
		 */ 
		internal function render( offset:Point ):void
		{
			
			//	The offset coordinates are negated to make them positive
			//	We could have also used Math.abs( _offset.x/y)
			var r:int = Math.abs( int( offset.y / TILE_HEIGHT ));
			var c:int = Math.abs( int( offset.x / TILE_WIDTH ));

			//	Render the tiles
			var i:int = 0 ;
			var tile:Bitmap ;
			
			//	Wipe the slate clean
			bitmap.bitmapData.fillRect( new Rectangle( 0, 0, Map.MAP_WINDOW_WIDTH, Map.MAP_WINDOW_HEIGHT), 0 );
			do
			{
				var row:int = r + int( i / cols );
				var column:int = c + int( i++ % cols );
				tile = load( column, row );
				if ( !tile.bitmapData )
					continue ;
				var rect:Rectangle =  new Rectangle( 0, 0, tile.width, tile.height ) ;
				var dx:Number = offset.x + Number( column * TILE_WIDTH ); 
				var dy:Number = offset.y + Number( row * TILE_HEIGHT ) ;
				var point:Point = new Point(  dx, dy );
				bitmap.bitmapData.copyPixels( tile.bitmapData, rect, point );
				
			} while ( i  <= n );
		}
		
		private function load( column:int, row:int ):Bitmap
		{
			//	Look up the tile in the display list and return it
			var name:String = "3_" + column + "_" + row ;

			
			//	Grab it from the hash if it's not in the display list	
			var tile:Bitmap = ( tiles[ name ] as Bitmap );
			if ( tile ) return tile ;
			
			//	Otherwise, load it from the url
			var url:String = this.url + "/" + name + ".jpg";
			tiles[ name ] = tile = new Bitmap( );
			
			
			//	Create a loader to load the bitmap
			var loader:Loader = new Loader( );
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, 
				function ( event:Event ):void {
					
					//	Extract the bitmap data 
					var loaderInfo:LoaderInfo = ( event.target as LoaderInfo ) ; 
					tile.bitmapData = ( loaderInfo.content as Bitmap ).bitmapData ;
					
					//	Remove the listener
					( event.target as LoaderInfo ).removeEventListener
						( Event.COMPLETE, arguments.callee );
						
				});
				
			//	Silently handle errant files
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR,
				function ( event:IOErrorEvent ):void {
					( event.target as LoaderInfo ).removeEventListener
						( IOErrorEvent.IO_ERROR, arguments.callee );
				});
				
			try {
				//	Make the file request and request it	
				loader.load( new URLRequest( url ));
			} catch (error:Error) {
				trace("Unable to load requested document.");
			}					
			return tile ;
		}
	}
}