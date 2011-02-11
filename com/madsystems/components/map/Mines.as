﻿package com.madsystems.components.map
{
	import com.madsystems.components.Component;
	import com.madsystems.state.event.StateEvent;
	
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.Regular;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.utils.Timer;
	import flash.events.IEventDispatcher ;


	internal class Mines extends Component
	{
		private var overlays:Array ;
		private var reverse:Boolean ;
		private var sprites:Array ;
		private var index:int ;
		private var filter:BlurFilter = new BlurFilter( 12, 12, 1 );		
		
		public function Mines( overlays:XML, reverse:String, autoPlay:String )
		{
			super();
			this.reverse = ( reverse == "true" ? true : false ) ;
			
			this.overlays = new Array( ) ;
			for each ( var overlay:XML in overlays.overlay ) {
				this.overlays.push
				( 
					{ 
						cx: Number( overlay.@cx.toString()),
						cy: Number( overlay.@cy.toString()), 
						r: Number( overlay.@r.toString()),
						alpha: ( this.reverse ? 1 : 0 )
					} 
				);
			}
			//	The paths will draw on this 
			//	Do we need to add this sprite to the display list
			//	if we're rendering it to a bitmap
			sprites = new Array( );
			var sprite:Sprite = addChild( new Sprite( )) as Sprite ;
			sprite.filters = [ filter ] ;
			sprite.transform.colorTransform = new ColorTransform( 1, 0, 0, .7 );
			sprites.push( sprite ) ;
			sprites.push( addChild( new Sprite( )));
			
			if ( autoPlay == "true" )
				addEventListener( StateEvent.RUN, run );
			addEventListener( StateEvent.NEXT, next );
		}
		


		
		public function play( ):void {
			addEventListener( Event.ENTER_FRAME, frame );
			if ( reverse ) {
				index = overlays.length -1;
				hide( overlays.concat());
			} else {
				index = 0 ;
				display( overlays.concat() ); 
			}
		}

		override public function run(event:Event):void {
			play( );
		}
	

		override public function next(event:Event):void {
			for each ( var overlay:Object in overlays ) {
				if ( overlay.tween ) {
					( overlay.tween as Tween ).stop( );
					overlay.tween = null ;
				}
			}
			if ( hasEventListener( Event.ENTER_FRAME ))
				removeEventListener( Event.ENTER_FRAME, frame );
		}
		 
		private function hide( overlays:Array ):void {
			var overlay:Object = overlays[ index ];
			var tween:Tween = overlay.tween = new Tween( overlay, "alpha", Regular.easeIn, 1, 0, 1, true ) ;
			var listener:Function = function ( event:TweenEvent ):void {
				if ( event.type == TweenEvent.MOTION_FINISH ) {
					overlay.tween = null ;
					( event.target as Tween ).removeEventListener
						( TweenEvent.MOTION_CHANGE, arguments.callee );
					( event.target as Tween ).removeEventListener
						( TweenEvent.MOTION_FINISH, arguments.callee );
					tween.stop( );
					tween = null ;
					
				}
			}
			tween.addEventListener( TweenEvent.MOTION_CHANGE, listener ) ;
			tween.addEventListener( TweenEvent.MOTION_FINISH, listener ) ;
			tween.start();
			
			
			if ( --index > -1 ) {
				var timer:Timer = new Timer( 125, 1 );
				timer.addEventListener( TimerEvent.TIMER_COMPLETE,
					function ( event:TimerEvent ):void {
						timer.stop( );
						hide( overlays );
						( event.target as IEventDispatcher ).removeEventListener
							( event.type, arguments.callee );
					});	
				timer.start( );
			}			
		}
		private function display( overlays:Array ):void {


			var overlay:Object = overlays[ index ];
			var tween:Tween = overlay.tween = new Tween( overlay, "alpha", Regular.easeIn, 0, 1, 1, true ) ;
			var listener:Function = function ( event:TweenEvent ):void {
				if ( event.type == TweenEvent.MOTION_FINISH ) {
					overlay.tween = null ;
					( event.target as Tween ).removeEventListener
						( TweenEvent.MOTION_CHANGE, arguments.callee );
					( event.target as Tween ).removeEventListener
						( TweenEvent.MOTION_FINISH, arguments.callee );
					tween.stop( );
					tween = null ;
				}
			}
			tween.addEventListener( TweenEvent.MOTION_CHANGE, listener ) ;
			tween.addEventListener( TweenEvent.MOTION_FINISH, listener ) ;
			tween.start();
			
			
			if ( ++index < overlays.length ) {
				var timer:Timer = new Timer( 125, 1 );
				timer.addEventListener( TimerEvent.TIMER_COMPLETE,
					function ( event:TimerEvent ):void {
						timer.stop( );
						display( overlays );
						( event.target as IEventDispatcher ).removeEventListener
							( event.type, arguments.callee );
					});	
				timer.start( );
			}
		}
		
		private function frame( event:Event ):void {
			
			//	First, clear the sprites
			for each ( var sprite:Sprite in sprites ) 
				sprite.graphics.clear();
			
			//	Draw all the objects we've added to the bin
			for ( var i:int = 0, finished:Boolean = true; i < overlays.length; i++ ) {
				var overlay:Object = overlays[ i] ;
				finished = finished && ( reverse ? overlay.alpha == 0 : overlay.alpha == 1 );
				for each ( sprite in sprites ) {
					sprite.graphics.beginFill( 0xffffff, overlay.alpha );
					sprite.graphics.drawCircle( overlay.cx, overlay.cy, overlay.r );
					sprite.graphics.endFill();
				}
			}			
			if ( finished ) {
				removeEventListener( Event.ENTER_FRAME, frame );
				dispatchEvent( new Event( Event.COMPLETE ));
			}
		}
	}
}