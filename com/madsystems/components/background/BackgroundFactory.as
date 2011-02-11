package com.madsystems.components.background
{
	import com.madsystems.components.Builder;
	import com.madsystems.components.ComponentFactory;
	import flash.events.Event;
	import flash.events.IEventDispatcher;


	public class BackgroundFactory extends ComponentFactory
	{
		private var builder:Builder ;
		public function BackgroundFactory( ) {}
			
		override protected function create( component:XML ):Object {
			if ( !builder ) 
				builder = new BackgroundBuilder( );
			return builder.build( component ) ;
		}
	}
}