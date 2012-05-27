package
{
	import com.bit101.components.PushButton;
	import com.bit101.components.Text;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.ClipboardTransferMode;
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeDragActions;
	import flash.desktop.NativeDragManager;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class Main extends Sprite
	{
		private const HINT_WAIT_DRAG_NODE:String = "Drag your node.exe to me!";
		private const HINT_WAIT_DRAG_APP:String = "Drag your APP JS to me!";
		private const HINT_WAIT_DROP:String = "Looks great! Drop it!";
		private const UNRECOGNIZED:String = "Unrecognized format!";
		private const STOP_APP:String = "Stop APP";
		private const REPEAT_LAST_COMMAND:String = "repeat last command";
		
		private var nodeFile:File = File.applicationDirectory;
		private var jsFile:File = File.desktopDirectory;
		private var process:NativeProcess;
		private var txt_output:TextField;
		private var txt_version:Text;
		private var btn_stop:PushButton;
		private var btn_clear:PushButton;
		private var dragTarget:Sprite = new Sprite();
		private var na:NativeApplication = NativeApplication.nativeApplication;
		private var txt_hint:TextField;
		private var lastCommand:Vector.<String>;
		private var mySo:SharedObject = SharedObject.getLocal("RhinodeGUI");
		
		public function Main():void
		{
			stage ? init() : addEventListener(Event.ADDED_TO_STAGE, init);
			na.addEventListener(Event.EXITING, onAppExiting);
		}
		
		private function init(e:Event = null):void
		{
			stage.stageFocusRect = false;
			
			var format:TextFormat;
			format = new TextFormat();
			format.font = "Verdana";
			format.color = 0x2B2B2B;
			format.size = 12;
			format.bold = false;
			
			txt_output = new TextField();
			txt_output.defaultTextFormat = format;
			txt_output.autoSize = TextFieldAutoSize.LEFT;
			txt_output.multiline = true;
			txt_output.x = 150;
			txt_output.y = 10;
			addChild(txt_output);
			
			if (NativeProcess.isSupported)
			{
				btn_stop = new PushButton(this, 10, 10, "Stop", onClick);
				btn_clear = new PushButton(this, 10, 40, "Clean output", onClick);
				btn_stop.enabled = false;
				
				format = new TextFormat();
				format.font = "Verdana";
				format.color = 0xCDCDCD;
				format.size = 50;
				format.bold = true;
				
				txt_hint = new TextField();
				txt_hint.autoSize = TextFieldAutoSize.CENTER;
				txt_hint.defaultTextFormat = format;
				//txt_hint.x = (stage.stageWidth - txt_hint.textWidth) * 0.5;
				txt_hint.x = 0;
				txt_hint.y = stage.stageHeight * 0.5;
				txt_hint.width = stage.stageWidth;
				txt_hint.mouseEnabled = false;
				addChildAt(txt_hint, 0);
				
				dragTarget.graphics.beginFill(0xFF0000, 0);
				dragTarget.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
				dragTarget.graphics.endFill();
				dragTarget.focusRect = false;
				addChildAt(dragTarget, 0);
				dragTarget.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, onDragEnter);
				dragTarget.addEventListener(NativeDragEvent.NATIVE_DRAG_OVER, onDragOver);
				dragTarget.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, onDragDrop);
				dragTarget.addEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, onDragExit);
				dragTarget.addEventListener(NativeDragEvent.NATIVE_DRAG_COMPLETE, onDragComplete);
				dragTarget.addEventListener(NativeDragEvent.NATIVE_DRAG_START, onDragStart);
				dragTarget.addEventListener(NativeDragEvent.NATIVE_DRAG_UPDATE, onDragUpdate);
				/*if (Capabilities.os.toLowerCase().indexOf("win") > -1)
				{
					nodeFile = nodeFile.resolvePath("C:/Program Files (x86)/nodejs/node.exe");
					trace(nodeFile.nativePath);
				}*/
				
				//trace(mySo.data.nodeFile);
				if (mySo.data.nodeFile) {
					nodeFile.nativePath = mySo.data.nodeFile;
					// 測試看看
					if (nodeFile.exists) {
						node(new < String > ["-v"]);
						txt_hint.text = HINT_WAIT_DRAG_APP;
					}else {
						txt_hint.text = HINT_WAIT_DRAG_NODE;
					}
				}else {
					txt_hint.text = HINT_WAIT_DRAG_NODE;
				}
			}
			else
			{
				txt_output.text = "NativeProcess not supported.";
			}
		}
		
		private function onClick(e:MouseEvent):void
		{
			var btn:PushButton = e.target as PushButton;
			var filter:FileFilter;
			/*if (btn == btn_setup)
			{
				nodeFile.addEventListener(Event.SELECT, onNodeEXESelected);
				filter = new FileFilter("exe", "*.exe");
				nodeFile.browseForOpen("Select node.exe", [filter]);
			}*/
			/*else if (btn == btn_browseAndRun)
			   {
			   jsFile.addEventListener(Event.SELECT, onExecutableJSSelected);
			   filter = new FileFilter("Javascript", "*.js");
			   jsFile.browseForOpen("Select *.js", [filter]);
			 }*/
			if (btn == btn_stop)
			{
				if (btn_stop.label == STOP_APP)
				{
					process.exit(true);
				}
				else if (btn_stop.label == REPEAT_LAST_COMMAND)
				{
					node(lastCommand);
				}
			}
			else if (btn == btn_clear)
			{
				txt_output.text = "";
			}
		}
		
		private function onNodeEXESelected(e:Event):void
		{
			//trace(nodeFile.nativePath);
			nodeFile.removeEventListener(Event.SELECT, onNodeEXESelected);
			txt_output.appendText("setup complete, thank you!\n");
			
			node(new <String>["-v"]);
		}
		
		/*private function onExecutableJSSelected(e:Event):void
		   {
		   //trace(jsFile.nativePath);
		   jsFile.removeEventListener(Event.SELECT, onExecutableJSSelected);
		   node(new <String>[jsFile.nativePath]);
		   btn_stop.enabled = true;
		 }*/
		
		private function node(args:Vector.<String>):void
		{
			//trace(args);
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			nativeProcessStartupInfo.executable = nodeFile;
			nativeProcessStartupInfo.arguments = args;
			
			if (process)
				process.exit(true);
			
			process = new NativeProcess();
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
			process.addEventListener(ProgressEvent.STANDARD_INPUT_PROGRESS, inputProgressListener);
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onProgressError);
			process.addEventListener(NativeProcessExitEvent.EXIT, onProcessExit);
			process.addEventListener(Event.STANDARD_ERROR_CLOSE, onEvent);
			process.addEventListener(Event.STANDARD_INPUT_CLOSE, onEvent);
			process.addEventListener(Event.STANDARD_OUTPUT_CLOSE, onEvent);
			process.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onEvent);
			process.addEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, onEvent);
			process.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onEvent);
			process.start(nativeProcessStartupInfo);
			
			if (args[0].lastIndexOf(".js") > -1)
			{
				btn_stop.enabled = true;
			}
			
			lastCommand = args;
		}
		
		private function inputProgressListener(e:ProgressEvent):void
		{
			//trace("inputProgressListener : " + e);
			process.closeInput();
		}
		
		private function onOutputData(e:ProgressEvent):void
		{
			//trace("onOutputData : " + e);
			txt_output.appendText(process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable));
			btn_stop.label = STOP_APP;
		}
		
		private function onProgressError(e:ProgressEvent):void
		{
			//trace("onProgressError : " + e);
			txt_output.appendText(process.standardError.readUTFBytes(process.standardError.bytesAvailable));
			txt_output.appendText("\n");
		}
		
		private function onEvent(e:Event):void
		{
			//trace(e);
		}
		
		private function onProcessExit(e:NativeProcessExitEvent):void
		{
			btn_stop.enabled = true;
			btn_stop.label = REPEAT_LAST_COMMAND;
		}
		
		// drag **************************************************************************************************************************
		private function onDragEnter(e:NativeDragEvent):void
		{
			//trace(e);
			var transferable:Clipboard = e.clipboard;
			//trace(transferable.formats);
			var obj:Object = transferable.getData(ClipboardFormats.FILE_LIST_FORMAT, ClipboardTransferMode.ORIGINAL_PREFERRED);
			if ((obj[0].nativePath.lastIndexOf("node.exe") > -1 || obj[0].nativePath.lastIndexOf(".js") > -1) && transferable.hasFormat(ClipboardFormats.FILE_LIST_FORMAT))
			{
				NativeDragManager.dropAction = NativeDragActions.MOVE;
				NativeDragManager.acceptDragDrop(dragTarget);
				txt_hint.text = HINT_WAIT_DROP;
			}
			else
			{
				txt_hint.text = UNRECOGNIZED;
			}
		}
		
		private function onDragOver(e:NativeDragEvent):void
		{
			//trace(e);
		}
		
		private function onDragDrop(e:NativeDragEvent):void
		{
			//trace("onDragDrop : " + e);
			var clipboard:Clipboard = e.clipboard;
			var obj:Object = clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT, ClipboardTransferMode.ORIGINAL_PREFERRED);
			//t.obj(obj);
			//trace(obj[0].nativePath);
			if (obj[0].nativePath.lastIndexOf("node.exe") > -1) {
				mySo.data.nodeFile = obj[0].nativePath;
				nodeFile.nativePath = obj[0].nativePath;
				node(new < String > ["-v"]);
				txt_hint.text = HINT_WAIT_DRAG_APP;
			}else if (obj[0].nativePath.lastIndexOf(".js") > -1) {
				jsFile.nativePath = obj[0].nativePath;
				node(new <String>[jsFile.nativePath]);
				txt_hint.text = "";
			}
		}
		
		private function onDragExit(e:NativeDragEvent):void
		{
			//trace("onDragExit : " + e);
			if (nodeFile.nativePath.lastIndexOf("node.exe") < 0)
			{
				txt_hint.text = HINT_WAIT_DRAG_NODE;
			}
			else
			{
				txt_hint.text = HINT_WAIT_DRAG_APP;
			}
		}
		
		private function onDragUpdate(e:NativeDragEvent):void
		{
			//trace("onDragUpdate : " + e);
		}
		
		private function onDragStart(e:NativeDragEvent):void
		{
			//trace("onDragStart : " + e);
		}
		
		private function onDragComplete(e:NativeDragEvent):void
		{
			//trace("onDragComplete : " + e);
		}
		
		// **********************************************************************************************************************************
		private function onAppExiting(e:Event):void
		{
			if (process)
				process.exit(true);
		}
	}

}