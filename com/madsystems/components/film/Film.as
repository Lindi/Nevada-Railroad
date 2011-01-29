package com.madsystems.components.film
{
	import com.madsystems.state.event.StateEvent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class Film extends Sprite
	{
		private var video:Video ;
		private var videoStream:NetStream ;
		private var Nevada:DisplayObjectContainer ;
		public  var url:String ;
		
		public function Film( Nevada:DisplayObjectContainer )
		{
			super();
			this.Nevada = Nevada ;
			var videoConnection:NetConnection = new NetConnection( );
			videoConnection.connect(null);
			videoStream = new NetStream(videoConnection);
			videoStream.client = new NetStreamClient( );
			video = new Video();
			
			addEventListener( StateEvent.RUN, run );
			addEventListener( StateEvent.NEXT, next );

		}
		private function run( event:StateEvent ):void {
			trace("film.show("+event+")");
			show( this );
			addChild(video);
			video.width = 720 ;
			video.height = 480 ;
			video.x = ( stage.stageWidth - video.width )/2 ;
			video.y = ( stage.stageHeight - video.height )/4 ;
			video.attachNetStream(videoStream);
			videoStream.play(url);			
		}
		private function next( event:StateEvent ):void {
			trace("film.next("+event+")");
			hide( this );
			removeChild( video );
			videoStream.close();
		}
		private function show( displayObject:DisplayObject ):void {
			if ( !displayObject )
				return ;
			trace("film.show("+displayObject+")");
			if ( !Nevada.contains( displayObject )) {
				if ( displayObject.parent is DisplayObjectContainer ) 
					Nevada.addChildAt( ( displayObject.parent as DisplayObjectContainer ).removeChild( displayObject ), Nevada.numChildren)
				else Nevada.addChildAt( displayObject, Nevada.numChildren );
			}
		}
		private function hide( displayObject:DisplayObject ):void {
			if ( !displayObject )
				return ;
			if ( Nevada.contains( displayObject )) {
				Nevada.removeChild( displayObject ) ;
			}			
		}		
        public function onMetaData(info:Object):void { 
            trace("onMetaData fired"); 
        } 
         
        public function onXMPData(infoObject:Object):void 
        { 
            trace("onXMPData Fired\n"); 
        } 
		
	}
}

class NetStreamClient
{   
  public function onMetaData(info:Object):void
  {
    trace("onMetaData");
  }

  public function onPlayStatus(info:Object):void
  {
    trace("onPlayStatus");
  }
  
  public function onXMPData( info:Object ):void {
    trace("onXMPData");
  }
}
