package com.madsystems.components.gallery
{
	import com.madsystems.components.Builder;
	import com.madsystems.components.ComponentFactory;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;


	public class GalleryFactory extends ComponentFactory
	{
		private var builder:Builder ;
	
		override protected function create( component:XML ):Object {
			if ( !builder )
				builder = new GalleryBuilder( );
			return builder.build( component ) ;
		}
		private function complete( event:Event ):void {
			dispatcher.dispatchEvent( event.clone());
			( builder as IEventDispatcher ).removeEventListener( Event.COMPLETE, complete );
		}
		//ComponentFactory.add("gallery", new GalleryFactory( ));
	}
}