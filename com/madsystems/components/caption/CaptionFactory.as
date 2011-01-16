package com.madsystems.components.caption
{
	import com.madsystems.builder.IBuilder;
	import com.madsystems.components.Builder;
	import com.madsystems.components.ComponentFactory;

	public class CaptionFactory extends ComponentFactory
	{
		private var builder:Builder ;
	
		override protected function create( component:XML ):Object {
			if ( !builder )
				builder = new CaptionBuilder( );
			var id:String = component.@id.toString();
			var object:Object = builder.create( { container: main, id: id } );
			if ( object )
				return object ;
			return builder.build( component ) ;
		}

		ComponentFactory.add("caption", new CaptionFactory( ));
	}
}


import com.madsystems.components.Builder;
import com.madsystems.components.caption.Caption ;
import flash.display.DisplayObjectContainer;
import com.madsystems.builder.IBuilder;

class CaptionBuilder extends Builder
{
	private var caption:Caption ;
	
	override public function create( object:Object ):Object {
		var id:String = ( object.id as String ) ;

		if ( components[ id ] is Caption ) 
			return components[ id ] ;
		trace( id );
		trace("CaptionBuilder.create("+components[ id ]+")");
			
		var color:int = int( object.color );
		var main:DisplayObjectContainer = ( object.container as DisplayObjectContainer )
		//	Create a bitmap reference to be returned synchrononously
		caption = new Caption( main, color );
		return null ;
	}
	override public function build( component:XML ):Object {
		
		
		// Return the Bitmap if we've already made it
		if ( components[ component.@id ] is Caption ) 
			return ( components[ component.@id.toString() ] as Caption ) ;
			
		//	Store a reference	
		components[ component.@id.toString() ] = caption ;

		//	Grab the text of the caption
		var string:String = component.text()[0] ;

		//	Strip returns, newlines and tabs
		var i:int = 0 ;
		while (( i = string.search(/[\r\n\t]/)) != -1 )
			string = string.substr( 0, i ) + string.substr( i+1 );
//			
//		//	Strip blocks of non-word characters
//		while (( i = string.search(/^\W*\w+/)) != -1 )
//			string = string.substr( 0, i ) + string.substr( i+1 );
		
					
		//	Return the slideshow
		caption.text = string ;
				trace( 'caption ' + string ) ;

		return caption ;	
	}
}