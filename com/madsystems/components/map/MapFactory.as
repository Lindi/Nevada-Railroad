package com.madsystems.components.map
{
	import com.madsystems.builder.IBuilder;
	import com.madsystems.components.Builder;
	import com.madsystems.components.ComponentFactory;


	public class MapFactory extends ComponentFactory
	{
		private var builder:Builder ;
		
		public function MapFactory( ) {}
		
		override protected function create( component:XML ):Object {
			
			if ( !builder )
				builder = new MapBuilder( );
			
			var id:String = component.@id.toString();
			var object:Object = builder.create( { id: id } );
			if ( object )
				return object ;
			return builder.build( component ) ;
		}
		//ComponentFactory.factories["map"] = new MapFactory(  ) ;
	}
}

