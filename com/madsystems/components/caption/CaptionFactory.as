package com.madsystems.components.caption
{
	import com.madsystems.builder.IBuilder;
	import com.madsystems.components.Builder;
	import com.madsystems.components.ComponentFactory;

	public class CaptionFactory extends ComponentFactory
	{
		private var builder:Builder ;
	
		public function CaptionFactory( ) {}

		override protected function create( component:XML ):Object {
			if ( !builder )
				builder = new CaptionBuilder( );
			var id:String = component.@id.toString();
			var color:Number = Number( component.@color.toString( ));
			var blend:Number = Number( component.@blend.toString( ));
			blend = ( blend ? blend : .2 ) ;
			var object:Object = builder.create( { id: id, color: color, blend: blend } );
			if ( object )
				return object ;
			return builder.build( component ) ;
		}
		//ComponentFactory.add("caption", new CaptionFactory( ));
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
			
		var color:Number = Number( object.color );
		var blend:Number = Number( object.blend );

		//	Create a bitmap reference to be returned synchrononously
		caption = new Caption( color, blend );
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
		
					
		//	Return the slideshow
		caption.text = string ;
		return caption ;	
	}
}