package com.madsystems.components.film
{
	import com.madsystems.components.ComponentFactory ;
	import com.madsystems.builder.IBuilder ;
	import com.madsystems.components.Builder ;

	public class FilmFactory extends ComponentFactory
	{
		private var builder:Builder ;
	
		override protected function create( component:XML ):Object {
			if ( !builder )
				builder = new FilmBuilder( );
			var id:String = component.@id.toString();
			var object:Object = builder.create( { container: Nevada, id: id } );
			if ( object )
				return object ;
			return builder.build( component ) ;
		}

		//ComponentFactory.add("film", new FilmFactory( ));
	}
}

import com.madsystems.components.Builder;
import com.madsystems.components.film.Film;
import flash.display.DisplayObjectContainer;
import com.madsystems.builder.IBuilder;

class FilmBuilder extends Builder
{
	private var film:Film ;
	
	override public function create( object:Object ):Object {
		var id:String = ( object.id as String ) ;
		if ( components[ id ] is Film ) 
			return components[ id ] ;
			
		trace( id );
		trace("FilmBuilder.create("+components[ id ]+")");
			
		var Nevada:DisplayObjectContainer = ( object.container as DisplayObjectContainer )
		film = new Film( Nevada );
		return null ;
	}
	override public function build( component:XML ):Object {
		
		
		// Return the Bitmap if we've already made it
		if ( components[ component.@id ] is Film ) 
			return ( components[ component.@id.toString() ] as Film ) ;
			
		//	Store a reference	
		components[ component.@id.toString() ] = film ;
		film.url = component.@url.toString();		
		return film ;	
	}
}