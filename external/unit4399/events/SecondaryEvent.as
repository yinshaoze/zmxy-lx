package unit4399.events
{
	import flash.events.Event;

	public class SecondaryEvent extends Event
	{
		public static const LOGIN:String = "secondaryLogin";

		public static const LOG_OUT:String = "secondaryLogOut";

		public static const SAVE_SET:String = "secondarySaveSet";

		public static const SAVE_GET:String = "secondarySaveGet";

		public static const SAVE_LIST:String = "secondarySaveList";

		protected var _data:Object;

		public function SecondaryEvent(type:String, dataOb:Object, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			_data = dataOb;
		}

		public function get data():Object
		{
			return _data;
		}

		override public function toString():String
		{
			return formatToString("SecondaryEvent:", "type", "bubbles", "cancelable", "data");
		}

		override public function clone():Event
		{
			return new SecondaryEvent(type, data, bubbles, cancelable);
		}
	}
}
