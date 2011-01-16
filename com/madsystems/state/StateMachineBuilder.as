package com.madsystems.state
{
	import com.madsystems.components.ComponentFactory;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class StateMachineBuilder extends EventDispatcher
	{
		public var stateMachine:StateMachine ;
		//private var state:State ;
					
		public function StateMachineBuilder( main:DisplayObjectContainer ) {
			
			stateMachine = new StateMachine( main );
			
			
			//	Use an anonymous function reference
			//	since they execute faster than anonymous functions
			var listener:Function =
				function ( event:Event ):void
				{
					//	Kill the listener
					loader.removeEventListener( Event.COMPLETE, arguments.callee );
					
					//	Grab the XML and build the states
					var root:XML = new XML( loader.data );
					
					//	Create a factory to load the factory classes
					var factory:ComponentFactory = ( new ComponentFactory(  )  ).initiatlize( main );
					
					for each ( var state:XML in root.states.state ) {
						if ( stateMachine.states[ state.@id ] )
							continue ;
						var inputs:XMLList = state.inputs.input ;
						var components:XMLList = state.components.component ;
						create( state ).build( stateMachine.states[ state.@id ] as State, inputs, components, root );
					}
					
					//	We're done now
					dispatchEvent( new Event( Event.COMPLETE ));
				};
				
			//	Load the state xml configuration
			var loader:URLLoader = new URLLoader( );
			loader.addEventListener( Event.COMPLETE, listener );
			var request:URLRequest = new URLRequest( "states.xml" );
			try {
				loader.load(request);
			} catch (error:Error) {
				trace("Unable to load requested document.");
			}
		}

		private function create( state:XML ):StateMachineBuilder {
			//	Create the new state
			stateMachine.states[ state.@id ] = new State(  );
			
			//	Set its id
			( stateMachine.states[ state.@id ] as State ).id = state.@id.toString();
			
			trace( "state.@initialState.toString() " + state.@initialState.toString());
			if ( state.@initialState.toString() == "yes" )
				stateMachine.state = ( stateMachine.states[ state.@id ] as State ) ;
			return this ;			
		}
		private function build( state:State, inputs:XMLList, components:XMLList, root:XML ):StateMachineBuilder {
			
			for each ( var component:XML in components ) {
				var id:String = component.@id.toString();
				state.components.push
				( 
					{ 
						component: ComponentFactory.create( root.components.*.(@id == component.@id)[0] ),
					  	id: id,
					  	activate: ( component.@deactivate.toString() == "true" ),
					  	deactivate: ( component.@deactivate.toString() == "true" )
					}
				);
			}
						
			//	Add the inputs to it
			for each ( var input:XML in inputs ) {
				var type:String = input.@type.toString() ;
				var object:Object = new Object( );
				object.type = type ;
				object.next = input.@next.toString() ;
				object.component = input.@component.toString() ;
				state.inputs.push( object );
			}
			return this ;
		}
	}
}