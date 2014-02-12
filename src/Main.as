package 
{
	import com.greensock.easing.Quart;
	import com.greensock.TweenLite;
	import com.helper.MyButton;
	import com.helper.TimerControl;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...简易拼图
	 * @author yokia <z334z@qq.com>
	 */
	public class Main extends Sprite 
	{
		private var _loader:Loader;
		private var _cutCount:int = 3;									// 图片切割数
		private var _littlePicArr:Array = [];							// 小图片保存数组
		private var _rightPic:DisplayObject;							// 正确的图片
		private var _bitMap:BitmapData;									// 位图数据
		private var _progressText:TextField = new TextField();			// 加载进度显示文本
		private var _urlArr:Array = [];									// 图片路径数组
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private var seeRightPicButton:MyButton;			// 查看原图按钮
		private var resetButton:MyButton;				// 重置按钮
		private var beginButton:MyButton;				// 开始按钮
		/**
		 * 初始化
		 * @param	e
		 */
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			TimerControl.instance.initStage(stage);
			_loader = new Loader();			
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onPicProgress);

			_urlArr[0] = "1.jpg";
			_urlArr[1] = "2.jpg";
			_urlArr[2] = "3.jpg";
			_urlArr[3] = "4.jpg";
					
			addChild(_progressText);
			// 画一个灰色的背景
			var mask:Shape = new Shape();
			mask.graphics.beginFill(0x000000, .5);
			mask.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			mask.graphics.endFill();
			addChild(mask);
			
			seeRightPicButton = new MyButton("查看原图");
			addChild(seeRightPicButton);
			
			seeRightPicButton.x = stage.stageWidth - seeRightPicButton.width - 20;
			seeRightPicButton.y = stage.stageHeight - seeRightPicButton.height - 20;
			
			resetButton = new MyButton("重置");
			resetButton.x = seeRightPicButton.x - seeRightPicButton.width - 20;
			resetButton.y = seeRightPicButton.y;
			resetButton.setColor(0x000000);
			addChild(resetButton);
			
			beginButton = new MyButton("开始");
			beginButton.x = resetButton.x - resetButton.width - 20;
			beginButton.y = resetButton.y;
			beginButton.setColor(0xff0000);
			addChild(beginButton);
			// 为各个按钮添加侦听事件
			resetButton.addEventListener(MouseEvent.CLICK, onResetClick);
			seeRightPicButton.addEventListener(MouseEvent.MOUSE_DOWN, onSeeRightPic);
			seeRightPicButton.addEventListener(MouseEvent.MOUSE_UP, onSeeRightPic);
			beginButton.addEventListener(MouseEvent.CLICK, onGameStart);
			
			
			// 初始化倒计时文本
			_timeTextFiled = new TextField();
			_timeTextFiled.defaultTextFormat = new TextFormat(null, 44, 0xffffff, true);
			_timeTextFiled.x = stage.stageWidth - _timeTextFiled.width >> 1;
			_timeTextFiled.y = 30;
			_timeTextFiled.autoSize = TextFieldAutoSize.LEFT;
			addChild(_timeTextFiled);
			_timeTextFiled.visible = false;
		}
		
		/**
		 * 加载进度
		 * @param	e
		 */
		private function onPicProgress(e:ProgressEvent):void 
		{
			_progressText.visible = true;
			var percent:int = e.bytesLoaded / e.bytesTotal * 100;
			_progressText.text = "加载中..." + percent + "%";
			_progressText.x = stage.stageWidth - _progressText.width >> 1;
			_progressText.y = stage.stageHeight >> 1;
			addChild(_progressText);
		}
		
		private function onSeeRightPic(e:MouseEvent):void 
		{
			if (!_isGameStart)
				return;
			addChild(_rightPic);
			if (e.type == MouseEvent.MOUSE_DOWN)
			{
				_rightPic.visible = true;
			}
			else
			{
				_rightPic.visible = false;
			}
		}
		
		private var _time:int = 30;				// 每次游戏的时间
		private var _timeTextFiled:TextField;
		/**
		 * 游戏开始，将图片块打乱
		 * @param	e
		 */
		private function onGameStart(e:MouseEvent):void 
		{
			removeBlocks();
			_isGameFinish = false;
			_isGameStart = true;
			var index:int = _cutCount - 3;
			if (index >= _urlArr.length)
				index = Math.floor(Math.random() * _urlArr.length);
			_loader.load(new URLRequest(_urlArr[index]));
			
			beginButton.visible = false;
			
			_time = (_cutCount - 2) * 30;
			_timeTextFiled.text = _time.toString();
			_timeTextFiled.x = stage.stageWidth - _timeTextFiled.width >> 1;
			_timeTextFiled.visible = true;
			//Timepiece.instance.addTimerFun(onCountTime, 1000);
			TimerControl.instance.addTimerFun(onCountTime, 1000);
		}
		
		private function onCountTime():void 
		{
			_time--;
			_timeTextFiled.text = _time >= 10?_time.toString():String(_time + 100).substr(1);
			if (_time <= 0)
			{
				_isGameStart = false;
				TimerControl.instance.removeFun(onCountTime, TimerControl.TIME);
				TimerControl.instance.addDelayFun(function delay():void
				{
					onResetClick(null);				
				}, 1000);
				
			}
		}
		
		/**
		 * 随机获取数组中的元素
		 * @param	arr
		 * @return
		 */
		private function getArrRandObject(arr:Array):Object
		{
			return arr[Math.floor(Math.random() * arr.length)];
		}
		
		/**
		 * 自动还原
		 * @param	e
		 */
		private function onResetClick(e:MouseEvent):void 
		{
			_isGameStart = false;
			_isFirstClick = true;
			for each (var picObject:Object in _littlePicArr) 
			{
				TweenLite.to(picObject.pic, .5, {x:picObject.x, y:picObject.y, ease:Quart.easeOut } );
			}
			beginButton.visible = true;
			beginButton.setText("开始");
			_timeTextFiled.text = "游戏结束，请重新开始";
			_timeTextFiled.x = stage.stageWidth - _timeTextFiled.width >> 1;
			TimerControl.instance.removeFun(onCountTime, TimerControl.TIME);
		}
		
		/**
		 * 图像加载完成
		 * @param	e
		 */
		private function onLoadComplete(e:Event):void 
		{
			_progressText.visible = false;
			// 等比例缩放
			_loader.content.scaleX = _loader.content.scaleY = 600 / _loader.content.width;
			_bitMap = new BitmapData(_loader.content.width, _loader.content.height);
			_bitMap.draw(_loader);
			
			_rightPic && _rightPic.parent && _rightPic.parent.removeChild(_rightPic);
			_rightPic = _loader.content;
			_rightPic.x = (stage.stageWidth - _loader.content.width >> 1);
			_rightPic.y = (stage.stageHeight - _loader.content.height >> 1);			
			_rightPic.visible = true;
			addChild(_rightPic);
			
			cutPicInPart();
			
			// 随机排布小图片
			for (var i:int = 0; i < 100; i++) 
			{
				var firstObject:Object = getArrRandObject(_littlePicArr);
				var secondObject:Object = getArrRandObject(_littlePicArr);
				
				var tempX:int = firstObject.pic.x;
				var tempY:int = firstObject.pic.y;
				firstObject.pic.x = secondObject.pic.x;				
				firstObject.pic.y = secondObject.pic.y;
				
				secondObject.pic.x = tempX;
				secondObject.pic.y = tempY;				
			}
		}
		
		/**
		 * 移除所有的小图
		 */
		private function removeBlocks():void
		{
			for each (var obj:Object in _littlePicArr) 
			{
				//obj.pic.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				//obj.pic.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				obj.pic.removeEventListener(MouseEvent.CLICK, onClickPic);
				obj.pic.parent && obj.pic.parent.removeChild(obj.pic);
			}
			_littlePicArr = [];
		}
		
		/**
		 * 将大图切成小图
		 */
		private function cutPicInPart():void
		{
			_rightPic.visible = false;
			
			var x_num:int = _rightPic.width / _cutCount;
			var y_num:int = _rightPic.height / _cutCount;
			
			for (var i:int = 0; i < _cutCount; i++) 
			{
				for (var j:int = 0; j < _cutCount; j++) 
				{
					var matrix:Matrix = new Matrix();
					matrix.translate( -x_num * i, -y_num * j);
					var block:Sprite = new Sprite();
					block.x = x_num * i + (stage.stageWidth - _loader.content.width >> 1);
					block.y = y_num * j + (stage.stageHeight- _loader.content.height >> 1);
					block.buttonMode = true;
					var obj:Object = { pic:block, x:block.x, y:block.y };
					_littlePicArr.push(obj);
					block.graphics.lineStyle();
					block.graphics.beginBitmapFill(_bitMap, matrix);
					block.graphics.drawRect(0 ,0, x_num-2, y_num-2);//通过背景图填充的方式分割图片
					block.graphics.endFill();
					addChild(block);
					// 添加事件
					//block.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
					//block.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					block.addEventListener(MouseEvent.CLICK, onClickPic);
				}
			}
		}
		private var _isFirstClick:Boolean = true;
		private var _swapPosition:Array = [];
		private var _firstPic:Sprite;
		private var _isGameFinish:Boolean = false;
		private var _isGameStart:Boolean = false;
		/**
		 * 点击图片，进行交换
		 * @param	e
		 */
		private function onClickPic(e:MouseEvent):void 
		{
			if (_isGameFinish || !_isGameStart)
				return;
			if (_isFirstClick)
			{
				_isFirstClick = !_isFirstClick;
				_swapPosition[0] = e.currentTarget.x;
				_swapPosition[1] = e.currentTarget.y;
				_firstPic = e.currentTarget as Sprite;
			}
			else
			{
				_firstPic.x = e.currentTarget.x;
				_firstPic.y = e.currentTarget.y;
				e.currentTarget.x = _swapPosition[0];
				e.currentTarget.y = _swapPosition[1];
				_isFirstClick = true;
			}
			e.currentTarget.scaleX = e.currentTarget.scaleY = .95;
			e.currentTarget.parent.addChild(e.currentTarget);
			TweenLite.to( e.currentTarget, 0.3, { scaleX:1, scaleY:1, ease:Quart.easeOut } );
			checkDone();
		}
		
		/**
		 * 鼠标松开
		 * @param	e
		 */
		private function onMouseUp(e:MouseEvent):void 
		{
			//e.currentTarget.stopDrag();
			// 边界判断
			if (e.currentTarget.x >= stage.stageWidth - e.currentTarget.width)
				e.currentTarget.x = stage.stageWidth - e.currentTarget.width;
			else if (e.currentTarget.x <= 0)
				e.currentTarget.x = 0;
			else if (e.currentTarget.y >= stage.stageHeight - e.currentTarget.height)
				e.currentTarget.y = stage.stageHeight - e.currentTarget.height;
			else if (e.currentTarget.y <= 0)
				e.currentTarget.y = 0;
			TweenLite.to( e.currentTarget, 0.3, { scaleX:1, scaleY:1, ease:Quart.easeOut } );
		}
		
		/**
		 * 鼠标按下
		 * @param	e
		 */
		private function onMouseDown(e:MouseEvent):void 
		{
			if (!_isGameStart)
				return;
			//e.currentTarget.startDrag();
			e.currentTarget.scaleX = e.currentTarget.scaleY = .98;
			e.currentTarget.parent.addChild(e.currentTarget);
		}
		
		/**
		 * 检测游戏是否结束
		 */
		private function checkDone():void
		{
			for each (var obj:Object in _littlePicArr) 
			{
				if (obj.pic.x != obj.x || obj.pic.y != obj.y)
					return;
			}
			_isGameFinish = _isFirstClick = true;
			_isGameStart = false;
			
			_cutCount++;
			beginButton.setText("下一关");
			beginButton.visible = true;
			_timeTextFiled.visible = false;
			TimerControl.instance.removeFun(onCountTime, TimerControl.TIME);
		}
		
	}
	
}