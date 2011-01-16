package com.madsystems.components.loop
{
	import com.madsystems.components.Builder;
	import com.madsystems.components.loop.Loop ;
	import com.madsystems.builder.IBuilder;
	import com.madsystems.components.ComponentFactory ;
	import flash.display.DisplayObjectContainer;
	import flash.display.Bitmap ;
	
	internal class LoopBuilder extends Builder
	{
		private var loop:Loop ;
		
		override public function create( object:Object ):Object {
			var id:String = ( object.id as String ) ;
			if ( components[ id ] is Loop ) 
				return components[ id ] ;
				
			trace( id );
			trace("LoopBuilder.create("+components[ id ]+")");
				
			var main:DisplayObjectContainer = ( object.container as DisplayObjectContainer );
			loop = new Loop( main );
			return null ;
		}
		
		override public function build( component:XML ):Object {
			// Return the Bitmap if we've already made it
			if ( components[ component.@id ] is Loop ) 
				return ( components[ component.@id.toString() ] as Loop ) ;
			components[ component.@id.toString() ] = loop ;
			//	Store a reference to the train image
			//	Add the slideshow images 
			for each ( var image:XML in component.image ) 
				loop.add( ComponentFactory.create( image ) as Bitmap, image.@name.toString() );
			return loop ;	
		}
	}
}