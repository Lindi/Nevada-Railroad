package com.madsystems.components.transition
{
	import com.madsystems.state.event.StateEvent;
	
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.None;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	
	
	public class Transition extends EventDispatcher
	{
		public var components:Array = new Array(2);
		private var tween:Tween ;
		private var listener:Function ;
		private var main:DisplayObjectContainer ;
		
		public function Transition( main:DisplayObjectContainer ) {
			this.main = main ;

			//	Create tweens and listeners
			tween = new Tween( {}, "", None.easeNone, 0, 1, 1, true ) ;

			//	When the component is added
			addEventListener( StateEvent.RUN, run );
			addEventListener( StateEvent.NEXT, next );
			
		}
		private function run( event:StateEvent ):void {
			trace("transition.run("+event+")");
			//	Show all the components
			for ( var i:int = 0; i < components.length; i++ ) {
				var array:Array = components[ i ] as Array ;
				for each ( var component:DisplayObject in array ) {
					show( component );
					//if ( i == 1 )
					//( component as EventDispatcher ).dispatchEvent( event.clone());
				}
			}
						
			//	Start the tween
			tween.addEventListener( TweenEvent.MOTION_CHANGE, transition );
			tween.addEventListener( TweenEvent.MOTION_FINISH, transition );		
			tween.start( );
			
		}
		private function next( event:StateEvent ):void {
			trace("transition.next("+event+")");
			var components:Array = components[ 0 ] as Array ;
			for each ( var component:DisplayObject in components ) {
				hide( component );	
				( component as EventDispatcher ).dispatchEvent( event.clone());
			}
			tween.removeEventListener( TweenEvent.MOTION_CHANGE, transition );
			tween.removeEventListener( TweenEvent.MOTION_FINISH, transition );		
			tween.stop();				
		}
		private function show( displayObject:DisplayObject ):void {
			if ( !displayObject )
				return ;
			trace("show("+displayObject+")");
			if ( !main.contains( displayObject )) {
				if ( displayObject.parent is DisplayObjectContainer ) 
					main.addChild( ( displayObject.parent as DisplayObjectContainer ).removeChild( displayObject ))
				else main.addChild( displayObject );
			} else {
					//main.addChild( ( displayObject.parent as DisplayObjectContainer ).removeChild( displayObject ))				
			}
		}
		public function transition( event:TweenEvent ):void {
			//trace("transition("+event+")");
			var t:Number = ( tween.time / tween.duration );
			var index:int ;
			var array:Array = components[ index ] ;
			for each ( var component:DisplayObject in array )
				component.alpha = 1 - t ;
			array = components[ ++index ] ;
			for each ( component in array )
				component.alpha = t ;
			if ( event.type == TweenEvent.MOTION_FINISH ) {
				tween.stop( );
				
				//	Shut everything down
//				var components:Array = components[ 0 ] as Array ;
//				for each ( component in components )
//					hide( component );	
//				tween.removeEventListener( TweenEvent.MOTION_CHANGE, transition );
//				tween.removeEventListener( TweenEvent.MOTION_FINISH, transition );		
//				tween.stop();				

				dispatchEvent( event.clone() );
			}				
		}

		private function hide( displayObject:DisplayObject ):void {
			trace("transition.hide("+displayObject+")");
			if ( !displayObject )
				return ;
			if ( displayObject.parent ) {
				(  displayObject.parent as DisplayObjectContainer ).removeChild( displayObject ) ;
			}			
		}

	}
}