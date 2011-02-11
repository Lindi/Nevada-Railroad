package com.madsystems.components.sound
{
	import com.madsystems.state.event.StateEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	

	internal class AudioClip extends EventDispatcher
	{
		private var sound:Sound ;
		private var channel:SoundChannel ;
		
		public function AudioClip( sound:Sound, start:String, stop:String )
		{
			super();
			this.sound = sound ;
			if ( start == "true" )
				addEventListener( StateEvent.RUN, run ) ;
			if ( stop == "true" )
				addEventListener( StateEvent.NEXT, next ) ;
		}
	
		private function run( event:Event ):void {
			play( );		
		}	
		
		private function next( event:Event ):void {
			stop( );
		}
		
		public function play( ):void {
			if ( !channel ) {
				channel = sound.play( );
				channel.addEventListener( Event.SOUND_COMPLETE, complete );
			}
		}
		
		private function complete( event:Event ):void {
			dispatchEvent( event.clone());
			stop( ) ;
		}
		public function stop( ):void {
			if ( channel ) {
				channel.stop( );
				if ( channel.hasEventListener( Event.SOUND_COMPLETE ))
					channel.removeEventListener( Event.SOUND_COMPLETE, complete );
				channel = null ;
			}	
		}
	}
}