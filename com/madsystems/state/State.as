package com.madsystems.state
{
	import com.madsystems.state.event.StateEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import mx.core.UIComponent;
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject 
	import com.madsystems.components.Component;;
	
	public class State extends EventDispatcher implements IState
	{
		
		//	In Java, these should be final
		public var components:Array ;
		public var inputs:Object ;
		public var id:String ;
		public var uicomponent:UIComponent ;
		public var main:DisplayObjectContainer ;
		
		
		public function State( main:DisplayObjectContainer )
		{
			super( );
			this.main = main ;
			uicomponent = new UIComponent( );
			components = new Array( );
			inputs = new Object( );
		}

		public function run( ):void {
			trace("run("+id+")");
			//	N.B.:  You must iterate over the array to ensure that
			//	components are added to the uicomponent in the correct order
			for ( var i:int = 0; i < components.length; i++ ) {
				var component:Object = components[ i ] ;
				if ( component is DisplayObject )
					show(( component as DisplayObject ), uicomponent );
				( component as EventDispatcher ).dispatchEvent( new StateEvent( StateEvent.RUN ));
			}
			main.addChild( uicomponent );
		}
		
		private function dispatch ( event:Event ):void {
			trace( "dispatch("+event+")");
			//	This is fine for now, but it might be a problem
			//	if we want to test the event target in the state machine
			dispatchEvent( event.clone());
		}
		public function next( event:Event ):String {
			trace( "next("+event+")");
			
			
			//	Find the right row of the input table
			var input:Array ;
			for ( var type:String in inputs ) {
				if ( type == event.type ) {
					input = inputs[ type ] ;
					break ;
				}
			}
					
			if ( input ) {
				//	First find the row
				for ( var i:int = 0; i < input.length; i++ ) {
					var id:String= ( event.target as Component ).id ;
					if ( input[ i ].component == id )
						break ;
				}
				
				//	Go throw each transition and execute it
				for each ( var transition:Transition in input[ i ].transitions ) {
					transition.execute();
				}
				var next:String = input[i].next ;
				if ( next ) {
					main.removeChild( uicomponent );
					return next ;
				}
			}
			return null ;
		}
		/**
		 * show
		 * 
		 * Adds a display object to the main display object container
		 * If the display object has a parent, it re-parents the
		 * display object in the main display object container
		 **/ 
		private function show( displayObject:DisplayObject, container:DisplayObjectContainer ):void {
			if ( !container )
				return ;
			if ( !displayObject )
				return ;
			if ( !container.contains( displayObject )) {
				if ( displayObject.parent is DisplayObjectContainer ) 
					container.addChild( ( displayObject.parent as DisplayObjectContainer ).removeChild( displayObject ))
				else container.addChild( displayObject );
			}
		}
		/**
		 * hide
		 * 
		 * Removes a display object from the main display object container
		 **/ 
		private function hide( displayObject:DisplayObject, container:DisplayObjectContainer ):void {
			if ( !container )
				return ;
			if ( !displayObject )
				return ;
			if ( container.contains( displayObject )) {
				container.removeChild( displayObject ) ;
			}			
		}		
	}
}