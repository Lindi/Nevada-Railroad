package com.madsystems.state
{
	import com.madsystems.state.event.StateEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.core.UIComponent;
	import flash.display.DisplayObjectContainer;
	
	public class State extends EventDispatcher implements IState
	{
		
		//	In Java, these should be final
		public var components:Array ;
		public var inputs:Array ;
		public var id:String ;
		public var component:UIComponent ;
		public var main:DisplayObjectContainer ;
		
		public function State( main:DisplayObjectContainer )
		{
			super( );
			this.main = main ;
			components = new Array( );
			inputs = new Array( );
		}

		public function run( ):void {
			trace("run("+id+")");
				
			//	Puke
			//	This can probably be done in one loop
			for each ( var input:Object in inputs ) {
				var type:String = input.type ;
				for each ( object in components ) {
					component = ( object.component as EventDispatcher );
					if ( object.id == input.component )
						break ;
				}
				if ( component ) 
					component.addEventListener( type, dispatch );
			}
			for each ( var object:Object in components ) {
				var component:EventDispatcher = ( object.component as EventDispatcher );
				trace( component );
				component.dispatchEvent( new StateEvent( StateEvent.RUN ));
			}
		}
		
		private function dispatch ( event:Event ):void {
			trace( "dispatch("+event+")");
			
			//	This is fine for now, but it might be a problem
			//	if we want to test the event target in the state machine
			dispatchEvent( event.clone());
		}
		public function next( event:Event ):String {
			trace( "next("+event+")");
			var input:Object ;
			for each ( var object:Object in inputs ) {
				input = object ;
				if ( input.type == event.type )
					break ;
			}
					
			if ( input ) {
				if ( input.condition is Condition ) {
					var condition:Condition = ( inputs.condition as Condition );
					if ( condition.test( event ))
						return ( input.next  as String );
				} else {
					
					//	Remove the event listener
					for each ( var i:Object in inputs ) {
						var type:String = input.type ;
						var component:EventDispatcher ;
						for each ( object in components ) {
							if ( object.id == i.component ) {
								component = ( object.component as EventDispatcher );
								break ;
							}
						}
						if ( component ) 
							component.removeEventListener( type, dispatch );
					}
					
					for each ( object in components ) {
						component = ( object.component as EventDispatcher );
						if ( object.deactivate )
							component.dispatchEvent( new StateEvent( StateEvent.NEXT ));
					}
					if (( input.next as String ).length )
						return ( input.next  as String );
				}
			}
			return null ;
		}
	}
}