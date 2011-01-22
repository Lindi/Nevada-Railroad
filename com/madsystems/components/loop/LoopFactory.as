package com.madsystems.components.loop
{
	import com.madsystems.components.ComponentFactory;
	import com.madsystems.components.Builder ;

	public class LoopFactory extends ComponentFactory
	{
		private var builder:Builder ;

		override protected function create( component:XML ):Object {
			if ( !builder )
				builder = new LoopBuilder( );
			var id:String = component.@id.toString();
			var object:Object = builder.create( { id: id } );
			if ( object )
				return object ;
			return builder.build( component ) ;
		}

		//ComponentFactory.add("loop", new LoopFactory( ));
	}
}



