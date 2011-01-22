package com.madsystems.components.image
{
	import com.madsystems.components.Builder;
	import com.madsystems.components.ComponentFactory;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;


	public class BitmapFactory extends ComponentFactory implements IEventDispatcher
	{
		private var builder:Builder ;
	
	
		public function BitmapFactory( ) {}
		
		override protected function create( component:XML ):Object {
			if ( !builder ) {
				builder = new BitmapBuilder( );
				( builder as IEventDispatcher ).addEventListener( Event.COMPLETE, complete );
			}
			return builder.build( component ) ;
		}
		
		private function complete( event:Event ):void {
			dispatcher.dispatchEvent( event.clone());
			( builder as IEventDispatcher ).removeEventListener( Event.COMPLETE, complete );
		}

		//ComponentFactory.add("image", new BitmapFactory( ));

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