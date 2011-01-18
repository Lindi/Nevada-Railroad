package com.madsystems.state
{
	import com.madsystems.components.ComponentFactory;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName ;
	
	public class StateMachineBuilder extends EventDispatcher
	{
		public var stateMachine:StateMachine ;
					
		public function StateMachineBuilder( main:DisplayObjectContainer ) {
			
			stateMachine = new StateMachine( main );
			
			
			//	Use an anonymous function reference
			//	since they execute faster than anonymous functions
			var listener:Function =
				function ( event:Event ):void
				{
					//	Kill the listener
					loader.removeEventListener( Event.COMPLETE, arguments.callee );
					
//					//	Create a factory to load the factory classes
					var factory:ComponentFactory = ( new ComponentFactory(  )  ).initiatlize( main );

					//	Grab the XML and build the states
					build( new XML( loader.data ), main );
					
//					
//					for each ( var state:XML in root.states.state ) {
//						if ( stateMachine.states[ state.@id ] )
//							continue ;
//						var inputs:XMLList = state.inputs.input ;
//						var components:XMLList = state.components.component ;
//						create( state, main ).build( stateMachine.states[ state.@id ] as State, inputs, components, root );
//					}
					
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

//		private function create( state:XML, main:DisplayObjectContainer ):StateMachineBuilder {
//			//	Create the new state
//			stateMachine.states[ state.@id ] = new State( main );
//			
//			//	Set its id
//			( stateMachine.states[ state.@id ] as State ).id = state.@id.toString();
//			
//			trace( "state.@initialState.toString() " + state.@initialState.toString());
//			if ( state.@initialState.toString() == "yes" )
//				stateMachine.state = ( stateMachine.states[ state.@id ] as State ) ;
//			return this ;			
//		}
		private function build( application:XML, main:DisplayObjectContainer ):void { //state:State, inputs:XMLList, components:XMLList, root:XML ):StateMachineBuilder {
			
			
			//	Build the components
			var components:Object = new Object( );
			for each ( var node:XML in application.components.* ) {
				components[ node.@id ] = new Object( );
				for each ( var child:XML in node.children()) {
					var component:XML = ( application.* ).child(child.@type.toString()).(@id == child.@id)[0]; 
					if (!( components[ node.@id ] ))
						components[ node.@id ] = new Object( );	
					components[ node.@id ][ child.@id ] = ComponentFactory.create( component ) ;
					
					//	Set the component id
					//	This will be used by the state to determine which component issued an event
					( components[ node.@id ][ child.@id ] ).id = child.@id.toString( );
				}
			}
			
			//	Build the states
			for each ( var state:XML in application.states.* ) {
				//	Create the new state
				stateMachine.states[ state.@id ] = new State( main );
				
				//	Set its id
				( stateMachine.states[ state.@id ] as State ).id = state.@id.toString();
				
				//	trace( "state.@initialState.toString() " + state.@initialState.toString());
				if ( state.@initialState.toString() == "yes" )
					stateMachine.state = ( stateMachine.states[ state.@id ] as State ) ;
					
				//	Push the components on to the components array and
				//	define a property on the state components array for
				//	easy access to the component	
				for ( var id:String in components[ state.@id.toString() ] ) {
					var array:Array = ( stateMachine.states[ state.@id ] as State ).components ;
					array.push( components[ state.@id ][ id ] );
					array[ id ] = components[ state.@id ][ id ] ;
				}	
					
				
				//	Add the inputs to it
				for each ( var input:XML in state.inputs.* ) {
					var type:String = input.@type.toString() ;
					var object:Object = new Object( );
					object.type = type ;
					object.next = input.@next.toString() ;
					object.component = input.@target.toString() ;
					object.transitions = [ ] ;
					array = ( stateMachine.states[ state.@id ] as State ).inputs[ input.@type.toString() ] ; 
					if ( !array )
						array = ( stateMachine.states[ state.@id ] as State ).inputs[ input.@type.toString() ] = new Array( );
					 array.push( object );
					for each ( var transition:XML in input.transitions.* ) {
						var target:Object = ( stateMachine.states[ state.@id ] as State ).components[ transition.@target.toString() ] ;
						var name:String = transition.@name.toString( );
						var args:Array = new Array( );
						for each ( var argument:XML in transition.children() )  {
							var cls:Class = getDefinitionByName( argument.@type ) as Class;
							if ( cls == Boolean )
								args.push(( argument.@value.toString() == "false" ? false : true ));
							else args.push( cls( argument.@value.toString() ));
						}
						object.transitions.push( new Transition( target, name, args ));
					}
				}
			}
//			for each ( var component:XML in components ) {
//				var id:String = component.@id.toString();
//				state.components.push
//				( 
//					{ 
//						component: ComponentFactory.create( root.components.*.(@id == component.@id)[0] ),
//					  	id: id,
//					  	activate: ( component.@deactivate.toString() == "true" ),
//					  	deactivate: ( component.@deactivate.toString() == "true" )
//					}
//				);
//			}
						
			//return this ;
		}
	}
}