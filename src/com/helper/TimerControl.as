package com.helper 
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;
	/**	
	 * ...时间计时器
	 * @project	Antwars Game 虫虫特攻队 http://www.boyaa.com
	 * @author	yokia <z334z@qq.com>
	 * @date		2014/02/12 created
	 */
	public class TimerControl 
	{
		private var _frameArr:Array = [];			// 帧事件数组
		private var _timerArr:Array = [];			// 时间事件数组
		private var _delayArr:Array = [];			// 延时事件数组
		
		private var _stage:Stage = null;
		private var _runing:Boolean = false;
		public function TimerControl() 
		{
			
		}
		private function start():void
		{
			if (!_runing)
				stage.addEventListener(Event.ENTER_FRAME, onTimerHandle);
			_runing = true;
		}
		private function stop():void
		{
			_runing = false;
			stage.removeEventListener(Event.ENTER_FRAME, onTimerHandle);
		}
		private const RUNFRAME:int = 30;			// 每秒帧数
		private var _newTime:Number = 0;
		private var _lastTime:Number = 0;
		/**
		 * 处理各计时函数
		 * @param	e
		 */
		private function onTimerHandle(e:Event):void 
		{
			_newTime = getTimer();
			var count:int = (_newTime - _lastTime) / RUNFRAME;
			_lastTime = _newTime;
			if (count == 0)
				count = 1;
			for (var i:int = 0; i < count; i++) 
			{
				runFrameFuntions();
			}
			runTimeFuntions();
			runDelayFuntions();
		}
		
		private function runFrameFuntions():void
		{
			for each (var arr:Array in _frameArr) 
			{
				var fun:Function = arr[0];
				fun.apply();
			}
		}
		
		private function runTimeFuntions():void
		{
			for each (var arr:Array in _timerArr) 
			{
				if (_newTime - arr[2] >= arr[1])
				{
					arr[2] += arr[1];
					var fun:Function = arr[0];
					fun.apply();
				}
			}
		}
		
		private function runDelayFuntions():void
		{
			for each (var arr:Array in _delayArr) 
			{
				if (_newTime - arr[2] >= arr[1])
				{
					arr[2] += arr[1];
					var fun:Function = arr[0];
					fun.apply();
					// 延时一次后，删除
					removeFun(fun, DELAY);
				}
			}
		}
		
		/**
		 * 移除函数
		 * @param	fun
		 * @param	type
		 */
		public function removeFun(fun:Function, type:int = 0):void
		{
			var i:int = 0;
			switch(type)
			{
				case FRAME:
					for (i = 0; i < _frameArr.length; i++) 
					{
						if (_frameArr[i][0] == fun)
						{
							_frameArr.splice(i, 1);
							break;
						}
					}
					break;
				case TIME:
					for (i = 0; i < _timerArr.length; i++) 
					{
						if (_timerArr[i][0] == fun)
						{
							_timerArr.splice(i, 1);
							break;
						}
					}
					break;
				case DELAY:
					for (i = 0; i < _delayArr.length; i++) 
					{
						if (_delayArr[i][0] == fun)
						{
							_delayArr.splice(i, 1);
							break;
						}
					}
					break;
				default:
					break;
			}
			if (_frameArr.length == 0 && _timerArr.length == 0 && _delayArr.length == 0)
				stop();
		}
		/**
		 * 添加时间函数
		 * @param	fun
		 * @param	time
		 */
		public function addTimerFun(fun:Function, time:int):void
		{
			var arr:Array = [fun, time, getTimer()];
			_timerArr.push(arr);
			start();
		}
		
		/**
		 * 添加延时函数
		 * @param	fun
		 * @param	delay
		 */
		public function addDelayFun(fun:Function, delay:int):void
		{
			var arr:Array = [fun, delay, getTimer()];
			_delayArr.push(arr);
			start();
		}
		
		/**
		 * 添加帧函数
		 * @param	fun
		 */
		public function addFrameFun(fun:Function):void
		{
			_frameArr.push([fun]);
			start();
		}
		
		/**
		 * 初始化使用的舞台
		 * @param	stage
		 */
		public function initStage(stage:Stage):void
		{
			_stage = stage;
		}
		
		
		/**帧*/
		public static const FRAME:int = 0;
		/**时间*/
		public static const TIME:int = 1;	
		/**延时*/
		public static const DELAY:int = 2;
		
		private function get stage():Stage 
		{
			if(_stage)
				return _stage;
			else
			{
				throw Error("TimerControl's stage not init");
			}
		}
		/**
		 * 时间计时器-单例
		 */
		public static function get instance():TimerControl 
		{
			if (!_instance)
				_instance = new TimerControl();
			return _instance;
		}
		
		private static var _instance:TimerControl = null;
	}

}