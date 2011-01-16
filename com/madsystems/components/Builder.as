package com.madsystems.components
{
	import com.madsystems.builder.IBuilder;
	
	public class Builder implements IBuilder
	{
		protected var components:Object = new Object( );

		public function create( object:Object ):Object	{ return null ;}
		public function build( component:XML ):Object	{ return null ;}
	}
}