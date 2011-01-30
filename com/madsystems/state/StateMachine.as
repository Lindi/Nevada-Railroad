package com.madsystems.state
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import com.madsystems.state.event.StateEvent ;
	

	public class StateMachine 
	{
		public var state:State ;
		public var states:Object = {};
		private var nevada:DisplayObjectContainer ;
		
		public function StateMachine( nevada:DisplayObjectContainer )
		{
			this.nevada = nevada ;
			nevada.addEventListener( Event.COMPLETE,
				function ( event:Event ):void {
					nevada.removeEventListener( Event.COMPLETE, arguments.callee );
					addEventListeners( state );
					state.run();
				});
		}
		
		public function add( id:String, state:IState ):void {
			if ( !states[ id ] )
				states[ id ] = state ;
		}
		
		private function addEventListeners( state:State ):void {
			for ( var type:String in state.inputs ) {
				var inputs:Array = state.inputs[ type ] as Array ;
				for each ( var target:Object in inputs ) {
					var component:IEventDispatcher = ( state.components[ target.component ] as IEventDispatcher ); 
					if ( component )
						component.addEventListener( type, next );					
				} 
			}
			
			//	Listen for a state timeout
			if ( state.timer )
				state.addEventListener( StateEvent.TIMEOUT, next );
		}		
		private function removeEventListeners( state:State ):void {
			for ( var type:String in state.inputs ) {
				var inputs:Array = state.inputs[ type ] as Array ;
				for each ( var target:Object in inputs ) {
					var component:IEventDispatcher = ( state.components[ target.component ] as IEventDispatcher ); 
					if ( component )
						component.removeEventListener( type, next );					
				} 
			}
			
			//	Remove the timeout listener
			if ( state.timer )
				state.removeEventListener( StateEvent.TIMEOUT, next );
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
				removeEventListeners( state );

				//	Store a reference to the new state
				state = states[ next ] ;

				//	Now listen to the events in this state
				addEventListeners( state ) ;
				
				//	Rune the state
				state.run( ) ;
			}
		}
	}
}
	

