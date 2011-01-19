package com.madsystems.state
{
	import com.madsystems.components.ComponentFactory;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
	
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

					//	Listen for when it's complete
					factory.dispatcher.addEventListener( Event.COMPLETE, complete );
					
					//	Grab the XML and build the states
					build( new XML( loader.data ), main );
										
					//	We're done now
					//dispatchEvent( new Event( Event.COMPLETE ));
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

		private function build( application:XML, main:DisplayObjectContainer ):void { //state:State, inputs:XMLList, components:XMLList, root:XML ):StateMachineBuilder {
			
			
			//	Build the components
			var components:Object = new Object( );
			for each ( var node:XML in application.components.* ) {
				components[ node.@id ] = new Array( );
				for ( var i:int = 0; i < node.children().length(); i++ ) { //each ( var child:XML in node.children()) {
					var child:XML = node.children()[ i] as XML;
					var component:XML = ( application.* ).child(child.@type.toString()).(@id == child.@id)[0];
					var display:Object =  ComponentFactory.create( component ) ;
					( components[ node.@id ] as Array ).push( { id: child.@id.toString( ), component: display });
				}
			}
			
			//	Build the states
			for each ( var state:XML in application.states.* ) {
				
				//	Create the new state
				if ( state.@timeout ) 
					stateMachine.states[ state.@id ] = new State( main, Number( state.@timeout.toString()));
				else stateMachine.states[ state.@id ] = new State( main );

				//	Set its id
				( stateMachine.states[ state.@id ] as State ).id = state.@id.toString();
				
				//	Store the initial state
				if ( state.@initialState.toString() == "yes" )
					stateMachine.state = ( stateMachine.states[ state.@id ] as State ) ;
					
				//	Push the components on to the components array and
				//	define a property on the state components array for
				//	easy access to the component	
				var a:Array = components[ state.@id.toString() ] as Array ;
				for ( i = 0; i < a.length; i++ ) { 
					var array:Array = ( stateMachine.states[ state.@id ] as State ).components ;
					array.push( a[i].component ) ;
					array[ a[i].id ] = a[i].component ;
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
		}
		
		//	Dispatch to main when the bitmaps have done loading
		private function complete( event:Event ):void {
			dispatchEvent( event.clone());
		}
	}
}