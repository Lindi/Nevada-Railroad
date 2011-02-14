package com.madsystems.state.effects
{
	import com.madsystems.state.ITransition;
	import fl.transitions.Tween;
	import fl.transitions.easing.Regular ;
	import fl.transitions.TweenEvent 
	import flash.display.DisplayObject;;
	
	public class Fade implements ITransition
	{
		public var target:Object ;
		public var name:String ;
		public var args:Array ;
		private var tween:Tween ;
		
		public function Fade( target:Object, name:String, args:Array, fade:String )
		{
			this.target = target ;
			this.name = name ;
			this.args = args ;
			if ( fade == "in" ) 
				tween = new Tween( {}, "", Regular.easeIn, 0, 1, 1, true ) ;
			else tween = new Tween( {}, "", Regular.easeIn, 1, 0, 1, true ) ;
			tween.addEventListener( TweenEvent.MOTION_CHANGE, frame ) ;
			tween.addEventListener( TweenEvent.MOTION_FINISH, frame ) ;
			tween.stop();
		}
		
		private function frame( event:TweenEvent ):void {
			( target as DisplayObject ).alpha = tween.position ;
			//trace( tween.position );
			if ( event.type == TweenEvent.MOTION_FINISH ) {
//				( event.target as Tween ).removeEventListener
//					( TweenEvent.MOTION_CHANGE, arguments.callee );
//				( event.target as Tween ).removeEventListener
//					( TweenEvent.MOTION_FINISH, arguments.callee );
				tween.stop( );
				
			}
		}
		public function execute( ):void
		{
//			//	Check to see whether or not we're listening already
////			if ( !tween.hasEventListener( TweenEvent.MOTION_CHANGE ))
//				tween.addEventListener( TweenEvent.MOTION_CHANGE, frame ) ;
////			if ( !tween.hasEventListener( TweenEvent.MOTION_FINISH ))
//				tween.addEventListener( TweenEvent.MOTION_FINISH, frame ) ;
			tween.rewind( );
			tween.start( );	
		}

	}
}