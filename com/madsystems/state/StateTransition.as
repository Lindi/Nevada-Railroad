package com.madsystems.state
{
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.Regular;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.IBitmapDrawable;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	import mx.core.UIComponent;
	
	internal class StateTransition
	{
		private var main:DisplayObjectContainer ;
		private var bitmap:Bitmap ;
		private var tween:Tween ;
		private var uicomponent:UIComponent = new UIComponent( );
		private var state:State ;
		private var matrix:Matrix = new Matrix( );
		
		public function StateTransition( main:DisplayObjectContainer )
		{
			this.main = main ;
			this.bitmap = new Bitmap( new BitmapData( 1920, 1080, false ));
			this.uicomponent.addChild( bitmap );
			this.tween = new Tween( bitmap, "alpha", Regular.easeIn, 1, 0, 1, true ) ;
			tween.addEventListener( TweenEvent.MOTION_CHANGE, frame ) ;
			tween.addEventListener( TweenEvent.MOTION_FINISH, frame ) ;
			tween.stop( );
		}

		internal function run(  ):void {
			main.addChildAt( uicomponent, main.numChildren );
			tween.start() ;
		}
		internal function next( state:State ):void {
			bitmap.alpha = 1 ;
			bitmap.bitmapData.fillRect( bitmap.bitmapData.rect, 0 );
			bitmap.bitmapData.draw( state.uicomponent );
			
//			for ( var i:int = 0; i < state.uicomponent.numChildren; i++) {
//				var child:IBitmapDrawable = ( state.uicomponent.getChildAt( i ) as IBitmapDrawable );
//				var x:Number = ( child as DisplayObject ).x ;
//				var y:Number = ( child as DisplayObject ).y ;
//				var scaleX:Number = ( child as DisplayObject ).scaleX ;
//				var scaleY:Number = ( child as DisplayObject ).scaleY ;
//				matrix.identity() ;
//				matrix.scale( scaleX, scaleY );
//				matrix.tx = x ;
//				matrix.ty = y ;
//				bitmap.bitmapData.draw( child, matrix, new ColorTransform( 1, 1, 1, ( child as DisplayObject ).alpha ));
//			}
		}
		
		private function frame( event:TweenEvent ):void {
			if ( event.type == TweenEvent.MOTION_FINISH ) {
				tween.stop() ;	
				main.removeChild( uicomponent ) ;
			}
		}
	}
}