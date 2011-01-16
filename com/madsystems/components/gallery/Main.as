package com.madsystems.components.gallery
{
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageAlign ;
	import flash.display.StageScaleMode ;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;

	public class Main extends MovieClip
	{		
		private var images:Array = new Array( );
		private var picture:Bitmap = new Bitmap( );
		private var tween:Tween ;
		private const THUMBNAIL_WIDTH:uint = 150 ;
		private const THUMBNAIL_HEIGHT:uint = 200 ;
		
		public function Main( )
		{
			super( );
			
			//	This is a fullscreen interactive
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE ;
			stage.align = StageAlign.LEFT ;
			stage.scaleMode = StageScaleMode.NO_SCALE ;
			loaderInfo.addEventListener(Event.INIT,init);
			stage.addEventListener( MouseEvent.MOUSE_UP, mouseUp );
			
		}
		
		/**
		 * Load the bitmaps from the images directory that's
		 * in the main directory of this component
		 */
		private function init( event:Event ):void 
		{			
			//	Resolve the directory path
			var url:String = File.documentsDirectory.url + "/nevada/images/photo-gallery"  ;
			try {
				var dir:File = ( new File()).resolvePath( url );
				if ( dir.exists )
				{
					//	Get the directory listing
					var listing:Array = dir.getDirectoryListing(  ) ;
					var files:Array = new Array( );
					for ( var i:int = 0; i < listing.length; i++ ) {
						var file:File = ( listing[ i] as File );
						if ( file.nativePath.indexOf( ".jpg" ) != -1 ||
							 file.nativePath.indexOf( ".png" ) != -1 )
							files.push( file );
					}
					load( files ) ;
				}			
			} catch ( error:Error ) {
				trace( error ) ;
			}
		}
		private function load( files:Array ):void {
			//	Load each image
			var file:File = files.shift() as File;
			var loader:Loader = new Loader( );
			
			//	Extract the bitmap and throw it in the images array
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE,
				function( event:Event ):void
				{
					trace( event );
					trace( files.length );
					var bitmap:Bitmap = 
						(( event.target as LoaderInfo ).content as Bitmap ) ;
					images.push( bitmap );
					if ( !files.length )
						draw( images );
					else load( files ) ;
					( event.target as LoaderInfo ).removeEventListener
						( Event.COMPLETE, arguments.callee );
				});
				
			//	Silently handle errant files
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR,
				function ( event:IOErrorEvent ):void {
					( event.target as LoaderInfo ).removeEventListener
						( IOErrorEvent.IO_ERROR, arguments.callee );
				});
				
			//	Make the file request and request it	
			var request:URLRequest = new URLRequest( file.nativePath );
			try {
				trace( file.nativePath ) ;
				loader.load(request);
			} catch (error:Error) {
				trace("Unable to load requested document.");
			}					
		}
		/**
		 * Handle a click on a bitmap
		 */
		private function mouseUp( event:MouseEvent ):void {
			if ( contains( picture )) {
				if ( tween ) {
					tween.stop( );
					tween = null ;
				}
				removeChild( picture );
			} else {
				var padding:int = 5 ;
				var c:Number = ( THUMBNAIL_WIDTH + padding );
				var w:Number = c * 3 ;
				var r:Number = ( THUMBNAIL_HEIGHT + padding );
				var h:Number = r * 4 ;
				var x:Number = ( stage.stageWidth )/8 ;
				var y:Number = ( stage.stageHeight - h )/2; 
				var a:Number = ( event.stageX - x );
				var b:Number = ( event.stageY - y );
				var rectangle:Rectangle = new Rectangle( 0,0,w,h );
				if ( rectangle.contains( a, b )) {
					var i:int = int( b / r ) * 3 + int( a / c );
					var bitmap:Bitmap = images[ i ] as Bitmap;
					expand( bitmap );
				}
			}
		}
		/**
		 * Draw all the bitmaps
		 */
		private function drawAll(  ):void {
			draw( images ) ;
		}

		/**
		 * Draw the bitmaps
		 */
		private function draw( images:Array ):void 
		{
			var padding:int = 5 ;
			var w:Number = ( THUMBNAIL_WIDTH + padding ) * 3 ;
			var h:Number = ( THUMBNAIL_HEIGHT + padding ) * 4 ;
			var x:Number = ( stage.stageWidth )/8 ;
			var y:Number = ( stage.stageHeight - h )/2; 
			
			//	Cycle through all the images and shrink 'em down
			for ( var i:int = 0; i < images.length; i++ ) {
				var bitmap:Bitmap = new Bitmap( size(( images[ i ] as Bitmap ).bitmapData ) );
				var sprite:Sprite = new Sprite( );			
				sprite.x = ( THUMBNAIL_WIDTH + padding ) * int( i % 3 ) + x ;
				sprite.y = ( THUMBNAIL_HEIGHT + padding ) * int( i / 3 ) + y ;
				bitmap.x = ( THUMBNAIL_WIDTH - bitmap.width )/2 ;
				bitmap.y = ( THUMBNAIL_HEIGHT - bitmap.height )/2 ;
				sprite.addChild( bitmap );
				sprite.graphics.lineStyle( 1 );
				sprite.graphics.drawRect( 0,0, THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT ) ;
				addChild( sprite );
			}
		}
		
		private function size( data:BitmapData, width:Number = THUMBNAIL_WIDTH, height:Number = THUMBNAIL_HEIGHT ):BitmapData
		{
			var m:Matrix = new Matrix();
		 	var scale:Number = 1 ;
		 	if (data.width > width || data.height > height )
		  		scale = Math.min(width / data.width, height / data.height);
		 	m.scale(scale, scale);
		 	var b:BitmapData = new BitmapData( data.width * scale, data.height * scale ); 
		 	b.draw(data, m);
		 	return b ;
		}	
		
		/**
		 * Expand
		 */
		private function expand( bitmap:Bitmap ):void {
			//	Add the bitmap on top of all the other bitmaps
			if ( !contains( picture ))
				addChildAt( picture, numChildren );
			var f:Function = 
				function ( event:Event ):void {
					animate( bitmap );
					if ( event.type == TweenEvent.MOTION_FINISH ) {
						tween.removeEventListener( TweenEvent.MOTION_CHANGE, f );
						tween.removeEventListener( TweenEvent.MOTION_FINISH, f );
						tween.stop( );
						tween = null ;
					}
				}
			tween = new Tween( {}, "", None.easeNone, 0, 1, 1, true ) ;
			tween.addEventListener( TweenEvent.MOTION_CHANGE, f );
			tween.addEventListener( TweenEvent.MOTION_FINISH, f );
			tween.start( );
		}		
		
		private function animate( bitmap:Bitmap ):void {
			var scale:Number = Math.min( THUMBNAIL_WIDTH / bitmap.width, THUMBNAIL_HEIGHT / bitmap.height);
			var t:Number = ( tween.time / tween.duration );
			var w:Number = bitmap.width * scale ;
			w = w + ( bitmap.width - w ) * t ;
			var h:Number = bitmap.height * scale ;
			h = h + ( bitmap.height - h ) * t ;
			var x:Number = ( bitmap.width - w )/2 ;
			var y:Number = ( bitmap.height - h )/2 ; 
			var bitmapData:BitmapData = new BitmapData(w, h, true, 0x00fffff ) ;
			picture.bitmapData = bitmapData ;
			picture.bitmapData.copyPixels( bitmap.bitmapData, new Rectangle( x,y,w,h ), new Point( 0, 0 ));
			picture.x = ( stage.stageWidth - w )/2 ;
			picture.y = ( stage.stageHeight - h )/2 ;
			picture.width = w ;
			picture.height = h ;
		}
	}
}