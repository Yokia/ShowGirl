package com.helper 
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**	
	 * ...简易按钮
	 * @project	Antwars Game 虫虫特攻队 http://www.boyaa.com
	 * @author	yokia <z334z@qq.com>
	 * @date		2014/02/11 created
	 */
	public class MyButton extends Sprite 
	{
		private const ALPHA_NUM:Number = .7;
		private var _sp:Sprite = new Sprite();
		private var _txt:TextField = new TextField();
		private var _alpha:Number = ALPHA_NUM;
		private var _currentColor:uint = 0x0000ff;
		private var _buttonWidth:int = 0;
		private var _buttonHeight:int = 0;
		public function MyButton(txt:String, width:int = 100, height:int = 30) 
		{
			super();
			_buttonWidth = width;
			_buttonHeight = height;
			drawButton();
			
			buttonMode = true;
			_txt.defaultTextFormat = new TextFormat(null, height / 2, 0xffffff);
			_txt.text = txt;
			_txt.autoSize = TextFieldAutoSize.LEFT;
			_txt.mouseEnabled = false;
			_txt.x = width - _txt.width >> 1;
			_txt.y = height - _txt.height >> 1;
			addChild(_txt);
			
			addEventListener(MouseEvent.MOUSE_OVER, onOver);
			addEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
		
		/**
		 * 设置按钮文本
		 * @param	str
		 */
		public function setText(str:String = ""):void
		{
			_txt.text = str;
			_txt.x = width - _txt.width >> 1;
			_txt.y = height - _txt.height >> 1;
		}
		
		public function getTextFiled():TextField
		{
			return _txt;
		}
		
		/**
		 * 设置按钮颜色
		 * @param	color
		 */
		public function setColor(color:uint = 0xffffff):void
		{
			_currentColor = color;
			drawButton();
		}
		
		private function drawButton():void
		{
			graphics.clear();
			graphics.beginFill(_currentColor, _alpha);
			graphics.drawRect(0, 0, _buttonWidth, _buttonHeight);
			graphics.endFill();
			
		}
					
		private function onOut(e:MouseEvent):void 
		{
			_alpha = ALPHA_NUM;
			drawButton();
		}
		
		private function onOver(e:MouseEvent):void 
		{
			_alpha = 1;
			drawButton();
		}
	}

}