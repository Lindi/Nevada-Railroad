package com.madsystems.components.gallery
{
	import com.madsystems.components.Component;
	import com.madsystems.state.event.StateEvent;
	
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	internal class Gallery extends Component
	{		
		public var images:Array ;
		private var button:Sprite ;
		private var thumbnails:Array = new Array( );
		private var picture:Bitmap = new Bitmap( );
		private var tween:Tween ;
		private var startX:uint ;
		private const THUMBNAIL_WIDTH:uint = 150 ;
		private const THUMBNAIL_HEIGHT:uint = 200 ;
		
		public function Gallery( images:Array, button:Sprite ) 
		{
			super( );
			this.images = images ;
			this.button = button ;
			this.button.alpha = .5 ;
			this.button.addEventListener( MouseEvent.MOUSE_UP, mouseUp );
			addEventListener( StateEvent.RUN, run );
			addEventListener( StateEvent.NEXT, next );
			addEventListener( MouseEvent.MOUSE_UP, mouseUp );
		}
		

		override public function run( event:Event ):void {
			draw( images );
		}
		override public function next( event:Event ):void {
			if ( contains( picture ))
				removeChild( picture );
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
				
				//	Dim out the image toggle button
				button.alpha = .5 ;
				
			} else {
				var padding:int = 5 ;
				var c:Number = ( THUMBNAIL_WIDTH + padding );
				var w:Number = c * 2 ;
				var r:Number = ( THUMBNAIL_HEIGHT + padding );
				var h:Number = r * int( Math.ceil( images.length / 2 )) ;
				var x:Number = ( stage.stageWidth )/3 ;
				var y:Number = ( stage.stageHeight + h )/2; 
				var a:Number = ( event.stageX - x );
				var b:Number = ( y - event.stageY );//- y );
				var rectangle:Rectangle = new Rectangle( 0,0,w,h );
				if ( rectangle.contains( a, b )) {
					var i:int = int( b / r ) * 2 + int( a / c );
					var bitmap:Bitmap = images[ i ] as Bitmap;
					expand( bitmap );
				}
				
				//	Brighten the image toggle button
				button.alpha = 1 ;
				
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
			if ( !thumbnails.length ) {
				var padding:int = 25 ;
				var w:Number = ( THUMBNAIL_WIDTH + padding ) * 3 ;
				var h:Number = ( THUMBNAIL_HEIGHT + padding ) * int( Math.ceil( images.length / 2 )) ;
				var x:int = int( stage.stageWidth )/3 ;
				var y:int = int( stage.stageHeight + h )/2; 
				graphics.clear();
				
				//	Cycle through all the images and shrink 'em down
				for ( var i:int = 0; i < images.length; i++ ) {
					var bitmap:Bitmap = new Bitmap( size(( images[ i ] as Bitmap ).bitmapData ) );
					var sprite:Sprite = new Sprite( );			
					sprite.x = ( THUMBNAIL_WIDTH + padding ) * int( i % 2 ) + x ;
					sprite.y = y - ( THUMBNAIL_HEIGHT + padding ) * ( int( i / 2 )+ 1 ) ;//+ y ;
					bitmap.x = ( THUMBNAIL_WIDTH - bitmap.width )/2 ;
					bitmap.y = ( THUMBNAIL_HEIGHT - bitmap.height )/2 ;
					sprite.addChild( bitmap );
					var frame:Shape = ( sprite.addChild( new Shape()) as Shape );
					frame.graphics.lineStyle( 3, 0xFCC10F )
					frame.graphics.drawRect( 0,0, THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT ) ;
					addChild( sprite );
					thumbnails.push( sprite ) ;
				}
			}
		}
		
		private function size( data:BitmapData, width:Number = THUMBNAIL_WIDTH, height:Number = THUMBNAIL_HEIGHT ):BitmapData
		{
			var m:Matrix = new Matrix( );
		 	var scale:Number = 1 ;
		 	if (data.width > width || data.height > height )
		  		scale = Math.min(width / data.width, height / data.height);
		 	m.scale(scale, scale);
		 	var b:BitmapData = new BitmapData( int( data.width * scale ), int( data.height * scale )); 
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
			picture.bitmapData = new BitmapData( bitmap.width, bitmap.height, true ) ;
			picture.x = ( stage.stageWidth - bitmap.width )/2 ;
			picture.y = ( stage.stageHeight - bitmap.height )/2 ;
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
			tween = new Tween( {}, "", None.easeNone, 0, 1, .25, true ) ;
			tween.addEventListener( TweenEvent.MOTION_CHANGE, f );
			tween.addEventListener( TweenEvent.MOTION_FINISH, f );
			tween.start( );
		}		
		
		private function animate( bitmap:Bitmap ):void 
		{
			var scale:Number = Math.min( THUMBNAIL_WIDTH / bitmap.width, THUMBNAIL_HEIGHT / bitmap.height);
			var t:Number = ( tween.time / tween.duration );
			var w:int = int( bitmap.width * scale );
			w = int( w + ( bitmap.width - w ) * t );
			var h:int = int( bitmap.height * scale );
			h = int( h + ( bitmap.height - h ) * t );
			var x:int = int(( bitmap.width - w )/2 );
			var y:int = int(( bitmap.height - h )/2 ); 
			picture.bitmapData.fillRect( picture.bitmapData.rect, 0 );
			picture.bitmapData.copyPixels( bitmap.bitmapData, new Rectangle( x,y,w,h ), new Point( x, y ));
		}
	}
}