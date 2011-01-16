package com.madsystems.components.transition
{
	import com.madsystems.builder.IBuilder;
	import com.madsystems.components.Builder;
	import com.madsystems.components.ComponentFactory;

	public class TransitionFactory extends ComponentFactory
	{
		override protected function create( component:XML ):Object {
			var builder:Builder = new TransitionBuilder( );
			var id:String = component.@id.toString();
			var object:Object = builder.create( { container: main, id: id } );
			if ( object )
				return object ;
			return builder.build( component ) ;
						
		}

		ComponentFactory.factories["transition"] = new TransitionFactory( ) ;
	}
}

import com.madsystems.components.Builder;
import com.madsystems.components.slideshow.Slideshow ;
import com.madsystems.components.ComponentFactory;
import com.madsystems.components.transition.Transition ;
import com.madsystems.builder.IBuilder;
import flash.display.Bitmap;
import flash.display.DisplayObjectContainer;

class TransitionBuilder extends Builder
{
	private var transition:Transition ;
	
	override public function create( object:Object ):Object {
		var id:String = ( object.id as String ) ;
		if ( components[ id ] is Transition ) 
			return components[ id ]  ;
			
		var main:DisplayObjectContainer = ( object.container as DisplayObjectContainer ) ;	
		transition = new Transition( main ) ;
		return null ;
	}
	override public function build( component:XML ):Object {
		
		//	Create the transition
		if ( components[ component.@id ] is Transition ) 
			return ( components[ component.@id ] as Transition );
			
		//	Create a transition reference to be returned synchrononously
		components[ component.@id ] = transition ;

		//	Grab a reference to all the components
		var xml:XML = ( component.parent() as XML );
		
		//	Add components to the transition
		for each ( var object:XML in component.components.* ) {
			var index:int = ( ( object.parent() as XML).@id.toString() == "to" ? 1 : 0 );
			var array:Array = transition.components[ index ] ;
			if ( !array ) 
				transition.components[ index ] = array = new Array( ) ;
			for each ( var child:XML in xml.children()) {
				if ( child.@id == object.@id ) {
					array.push( ComponentFactory.create( child ));
				}
			}	
		}
			
		//	Return the transition
		return transition ;	
	}
}