package com.madsystems.components.button
{
	import com.madsystems.components.Builder;
	import com.madsystems.components.ComponentFactory;
	import flash.events.Event;
	import flash.events.IEventDispatcher;


	public class ButtonFactory extends ComponentFactory
	{
		private var builder:Builder ;
	
		override protected function create( component:XML ):Object {
			if ( !builder ) 
				builder = new ButtonBuilder( );
			return builder.build( component ) ;
		}

		//ComponentFactory.add("button", new ButtonFactory( ));

	}
}