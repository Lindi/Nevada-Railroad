package com.madsystems.state
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	

	public class StateMachine 
	{
		public var state:State ;
		public var states:Object = {};
		private var main:DisplayObjectContainer ;
		
		public function StateMachine( main:DisplayObjectContainer )
		{
			this.main = main ;
			main.addEventListener( Event.COMPLETE,
				function ( event:Event ):void {
					main.removeEventListener( Event.COMPLETE, arguments.callee );
					for each ( var input:Object in state.inputs ) {
						if ( !state.hasEventListener( input.type ))
							state.addEventListener( input.type, next );
					}
					state.run();
				});
		}
		
		public function add( id:String, state:IState ):void {
			if ( !states[ id ] )
				states[ id ] = state ;
		}

		public function next( input:Event ):void {
	
			var next:String = state.next( input ) ;
			trace( "next("+next+")");
			if ( next ) {
				//	Remove event listeners from the state
				//	This should be refactored to allow many components
				//	for one input type
				
				//	And then we should probably add a condition that tests
				//	of the type of component, or we should store the component
				//	id and test for the id of the component that dispatched
				//	the event
				for each ( var event:Object in state.inputs ) {
					if ( !state.hasEventListener( event.type ))
						state.removeEventListener( event.type, arguments.callee );
				}

				//	Store a reference to the new state
				state = states[ next ] ;
							trace( "next("+state.id+")");

				//	Now listen to the events in this state
				for each ( event in state.inputs ) {
					if ( !state.hasEventListener( event.type ))
						state.addEventListener( event.type, arguments.callee );
				}
				state.run( ) ;
			}
		}
	}
}
	

