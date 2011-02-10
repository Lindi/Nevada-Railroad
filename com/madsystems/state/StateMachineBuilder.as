package com.madsystems.state
{
	import com.madsystems.components.ComponentFactory;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
	import com.madsystems.state.effects.Fade ;
	
	//import flash.filesystem.* ;
	
	public class StateMachineBuilder extends EventDispatcher
	{
		public var stateMachine:StateMachine ;
					
		public function StateMachineBuilder( main:DisplayObjectContainer, url:String ) {
			
			stateMachine = new StateMachine( main );
			
			
			//	Use an anonymous function reference
			//	since they execute faster than anonymous functions
			var listener:Function =
				function ( event:Event ):void
				{
					//	Kill the listener
					loader.removeEventListener( Event.COMPLETE, arguments.callee );
					
					
					//	Grab the XML and build the states
					build( new XML( loader.data ), main );
										

				};
				
			//	Load the state xml configuration
			var loader:URLLoader = new URLLoader( );
			loader.addEventListener( Event.COMPLETE, listener );
			var request:URLRequest = new URLRequest( url );
			try {
				loader.load(request);
			} catch (error:Error) {
				trace("Unable to load requested document.");
			}
		}

		private function build( application:XML, main:DisplayObjectContainer ):void { //state:State, inputs:XMLList, components:XMLList, root:XML ):StateMachineBuilder {
			
//					//	Create a factory to load the factory classes
			var factory:ComponentFactory = (ComponentFactory.getInstance()).initiatlize( main );

			//	Listen for when it's complete
			factory.dispatcher.addEventListener( Event.COMPLETE, complete );
		
			//	Build the components
			var components:Object = new Object( );
			for each ( var node:XML in application.components.* ) {
				components[ node.@id ] = new Array( );
				for ( var i:int = 0; i < node.children().length(); i++ ) { //each ( var child:XML in node.children()) {
					var child:XML = node.children()[ i] as XML;
					var list:XMLList =  (( application.* ).child(child.@type.toString()) as XMLList ) ;//.(@id == child.@id.toString());
					for each ( var component:XML in list )
						if ( component.@id == child.@id )
							break ;
					( components[ node.@id ] as Array ).push( { id: child.@id.toString( ), component: ComponentFactory.create( component ) });
				}
			}
			
			//	Build the states
			for each ( var state:XML in application.states.* ) {
				
				//	Create the new state
				if ( state.@timeout ) 
					stateMachine.states[ state.@id ] = new State( main, state.@id.toString( ), Number( state.@timeout.toString()));
				else stateMachine.states[ state.@id ] = new State( main, state.@id.toString( ));

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
					
					//	The input type is the name of the event we'll be listening for.
					var type:String = input.@type.toString() ;
					
					//	Create the object that will serve as the input
					var object:Object = new Object( );
					
					//	The event that will trigger the state transition, and/or chain of transitions 
					object.type = type ;
					
					//	The next state (if any)
					object.next = input.@next.toString() ;
					
					//	The component that will issue this event
					object.component = input.@target.toString() ;
					
					//	Any actions to take when transitioning from one
					//	state to the next
					object.transitions = [ ] ;
					
					//	Create an array for inputs of type "type", and add the input object to it
					array = ( stateMachine.states[ state.@id ] as State ).inputs[ input.@type.toString() ] ; 
					if ( !array )
						array = ( stateMachine.states[ state.@id ] as State ).inputs[ input.@type.toString() ] = new Array( );
					 array.push( object );
					 
					//	Iterate over the transitions 
					for each ( var transition:XML in input.transitions.* ) {
						
						//	Get the component that will be the target of the transition action
						var target:Object = ( stateMachine.states[ state.@id ] as State ).components[ transition.@target.toString() ] ;
						
						//	What's the name of the function we'll be calling on the target component
						var name:String = transition.@name.toString( );
						
						//	What's the array of arguments that we'll be passing
						var args:Array = new Array( );
						
						//	Go through the transition node's children (which are the parameters to 
						//	the function we'll be calling
						for each ( var argument:XML in transition.children() )  {
							var cls:Class = getDefinitionByName( argument.@type ) as Class;
							if ( cls == Boolean )
								args.push(( argument.@value.toString() == "false" ? false : true ));
							else args.push( cls( argument.@value.toString() ));
						}
						
						//	Push the transition object into the input's transition array
						if ( transition.@type == "fade" )
							object.transitions.push( new Fade( target, name, args, transition.@fade.toString( ) ));
						else object.transitions.push( new Transition( target, name, args ));
					}
				}

				//	Add the actions to it
				for each ( transition in state.transitions.* ) {
					
					//	What's the name of the function we'll be calling on the target component
					name = transition.@name.toString( );
						
					//	Get the component that will be the target of the transition action
					target = ( stateMachine.states[ state.@id ] as State ).components[ transition.@target.toString() ] ;
					
					//	Create an array for inputs of type "type", and add the input object to it
					if ( !( stateMachine.states[ state.@id ] as State ).transitions )
						array = ( stateMachine.states[ state.@id ] as State ).transitions = new Array( );
					 
					//	What's the array of arguments that we'll be passing
					args = new Array( );
						
					//	Go through the transition node's children (which are the parameters to 
					//	the function we'll be calling
					for each ( argument in transition.children() )  {
						cls = getDefinitionByName( argument.@type ) as Class;
						if ( cls == Boolean )
							args.push(( argument.@value.toString() == "false" ? false : true ));
						else args.push( cls( argument.@value.toString() ));
					}
					
					//	Push the transition object into the input's transition array
					array.push( new Transition( target, name, args ));

				}
			}
		}
		
		//	Dispatch to main when the bitmaps have done loading
		private function complete( event:Event ):void {
			dispatchEvent( event.clone());
		}
//		public function log( message:* ):void {
//			var myFile:File = File.desktopDirectory.resolvePath("nevada-log.txt");
//		    var fileStream:FileStream = new FileStream();
//		    fileStream.open(myFile, FileMode.READ);
//		    var text:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
//		    fileStream.close();
//
//			text = text + "\n" + String( message );
//		    fileStream.open(myFile, FileMode.WRITE);
//		    
//		    fileStream.writeUTFBytes( text );
//		    fileStream.close();
//		}
	}
}