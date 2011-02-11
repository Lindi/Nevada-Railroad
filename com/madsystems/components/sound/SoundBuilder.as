package com.madsystems.components.sound
{
	import com.madsystems.components.Builder;
	
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.*;
	import flash.media.Sound;
	import flash.net.URLRequest;

	internal class SoundBuilder extends Builder implements IEventDispatcher
	{
		private var dispatcher:EventDispatcher = new EventDispatcher( );
		private var index:int = 0 ;
		private var loaders:Array = new Array( );

		override public function build( component:XML ):Object {
			
			//	Return the Bitmap if we've already made it
			var id:String = component.@id.toString() as String ;
			var clip:AudioClip = ( components[ id ] as AudioClip ) ;
			if ( clip ) 
				return clip ;
		
			//	The image url
			var url:String = component.@url.toString( ) ;
			
			//	Increment the loader counter
			++index ;
			trace( "SoundBuilder.build("+index+")");
			trace( url );
					
			//	Create a sound reference to be returned synchrononously
			
			var sound:Sound = new Sound( );
			clip = components[ id ] = new AudioClip( sound, component.@start.toString( ), component.@stop.toString( ) );
			
							
			//	Create a loader to load the sound
			sound.addEventListener( Event.COMPLETE, 
				function ( event:Event ):void {
					//	Remove the listener
					( event.target as IEventDispatcher ).removeEventListener
						( event.type, arguments.callee );
					if (!--index )
						dispatcher.dispatchEvent( event.clone());
				});
				
			//	Silently handle errant files
			sound.addEventListener( IOErrorEvent.IO_ERROR,
				function ( event:IOErrorEvent ):void {
					( event.target as LoaderInfo ).removeEventListener
						( IOErrorEvent.IO_ERROR, arguments.callee );
				});
				
			//	If there's nothing in the loader's list
			//	otherwise, push the request on the list for loading later
				try {
					//	Make the file request and request it
					sound.load( new URLRequest( url ));					
				} catch (error:Error) {}	
			return clip ;
		}
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			dispatcher.addEventListener( type, listener, useCapture, priority, useWeakReference ) ;
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			dispatcher.addEventListener( type, listener, useCapture ) ;
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return dispatcher.dispatchEvent( event );
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return dispatcher.hasEventListener( type );
		}
		
		public function willTrigger(type:String):Boolean
		{
			return dispatcher.willTrigger( type );
		}				
	}
}