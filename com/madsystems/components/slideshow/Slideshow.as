package com.madsystems.components.slideshow
{
	import com.madsystems.state.event.StateEvent;
	
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.None;
	import flash.events.Event ;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import com.madsystems.components.Component;
	
	public class Slideshow extends Component
	{
		public var images:Array = new Array( );
		private var tween:Tween ;
		private var index:int = 0 ;
		private var a:Bitmap ;
		private var b:Bitmap ;
	
		
		public function add( bitmap:Bitmap ):void {
			if ( !images.length )
				addChild( bitmap );
			images.push( bitmap );
		}
		public function Slideshow(  ) {
			//	Create tweens and listeners
			tween = new Tween( {}, "", None.easeNone, 0, 1, 5, true ) ;
			tween.addEventListener( TweenEvent.MOTION_START, start );
			tween.addEventListener( TweenEvent.MOTION_CHANGE, change );
			tween.addEventListener( TweenEvent.MOTION_FINISH, finish );	
						
			addEventListener( StateEvent.RUN, run );				
			addEventListener( StateEvent.NEXT, next ) ;
		}
		override public function run( event:Event ):void {
			index = 0 ;
			tween.start();
		}
		override public function next( event:Event ):void {
			tween.stop( );
			addChild( images[ 0 ] as Bitmap );		
		}
		private function start( event:TweenEvent ):void {
			a = images[ index ] as Bitmap ;
			
			if ( a ) {
				a.alpha = 1 ;
				if ( !contains( a ))
					show( a );
			}
	
			index++ 
			index %= images.length ;
			
			b = images[ index ] as Bitmap ;
			if ( b ) {
				b.alpha = 0 ;
				if ( !contains( b ))
					show( b );
			}				
		}
		private function change( event:TweenEvent ):void {
			var t:Number = ( tween.time / tween.duration );
			if (( a != null ) && ( b != null )) {
				a.alpha = 1 - t ;
				b.alpha = t ;
			}
		}
		private function finish( event:TweenEvent ):void {
			var t:Number = ( tween.time / tween.duration );
			if (( a != null ) && ( b != null )) {
				a.alpha = 1 - t ;
				b.alpha = t ;					
				if ( contains( a ))
					removeChild( a );
				tween.stop( );
				tween.rewind( );
				tween.start( ) ;
			}
		}
		private function show( picture:DisplayObject ):void {
			if ( !picture )
				return ;
			if ( !contains( picture )) {
				if ( picture.parent is DisplayObjectContainer ) 
					addChild( ( picture.parent as DisplayObjectContainer ).removeChild( picture ))
				else addChild( picture );
			}
		}
	}
}