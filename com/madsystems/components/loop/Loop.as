﻿package com.madsystems.components.loop
{
	import com.madsystems.components.Component;
	import com.madsystems.state.event.StateEvent;
	
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class Loop extends Component
	{
		private var bitmap:Bitmap ;
		private var background:Bitmap ;
		private var index:int ;
		private var timer:Timer ;
		private var cars:Array = new Array( );

		
		public function Loop( )
		{
			super( );
			addEventListener( StateEvent.RUN, run );
			addEventListener( StateEvent.NEXT, next ) ;
			timer = new Timer( 100 );
		}
		public function add( bitmap:Bitmap, name:String ):void 
		{
			this[ name ] = bitmap ;
		}
		override public function run( event:Event ):void {
			if ( stage ) {
				init( );
			} else {
				if ( !timer.hasEventListener( TimerEvent.TIMER )) {
					timer.addEventListener(TimerEvent.TIMER,
						function( event:TimerEvent ):void {
							if ( stage ) {
								timer.removeEventListener( event.type, arguments.callee );
								timer.stop( );
								init( );
							}
						});
					timer.start( );
				}
			}
		}
		override public function next( event:Event ):void {
			
			//	Kill the timer
			if ( timer )
				timer.stop() ;
				
			//	Remove the frame event listener if there is one
			if ( hasEventListener( Event.ENTER_FRAME ))
				removeEventListener( Event.ENTER_FRAME, frame );
				
			if ( cars.length ) {
				for each ( var car:Object in cars ) {
					( car as DisplayObject ).visible = false ;
				}
			}
		}
		
		private function init( ):void {
			
			if ( !contains( background ))
				addChild( background ) ;
				
			if ( !cars.length ) {
				cars.push( addChild( bitmap )) ;
				bitmap.blendMode = BlendMode.MULTIPLY ;
				bitmap.alpha = .9 ;
				bitmap.x = ( stage.stageWidth - bitmap.width )/2 ;
				bitmap.visible = false ;
				bitmap.y = stage.stageHeight ;
				while ( cars.length < 3 ) {
					cars.push( addChild( new Bitmap( bitmap.bitmapData.clone())));
					var car:Bitmap = cars[ cars.length - 1] as Bitmap ;
					car.blendMode = BlendMode.MULTIPLY ;
					car.alpha = .9 ;
					car.x = ( stage.stageWidth - bitmap.width )/2 ;
					car.visible = false ;
					car.y = stage.stageHeight ;
				}
				index = stage.stageHeight ;
			}
			
			timer.delay = 5000 ;
			timer.addEventListener( TimerEvent.TIMER,
				function ( event:Event ):void {
					for each ( var car:Object in cars ) 
						( car as DisplayObject ).visible = true ;
					addEventListener( Event.ENTER_FRAME, frame );
					timer.stop( );
					timer.reset( );
				});
			timer.start( );
		}
		
		private function frame( event:Event ):void {
			index -= 125 ;
			for ( var i:int = 0; i < cars.length; i++ ) {
				var car:Bitmap = ( cars[ i ] as Bitmap );
				car.y = index + ( car.height * i ) ;
			}
			if ( car.y < -car.height ) {
				removeEventListener( Event.ENTER_FRAME, frame );
				index = 1080 ;
				timer.start( );
			}
		}
	}
}