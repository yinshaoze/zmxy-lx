package speculum.loader
{
	import flash.system.LoaderContext;
	import flash.system.ApplicationDomain;
	import flash.system.Security;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.events.DataEvent;
	import flash.utils.setTimeout;
	import flash.utils.getDefinitionByName;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import unit4399.events.*;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.globalization.DateTimeFormatter;
	import flash.globalization.LocaleID;

	public class SpeculumLoader extends MovieClip
	{
		private var _loaderContext:LoaderContext;
		private var _loader:Loader;
		private var game:* = null;
		private var config:Object = null;
		private var _balance:Number = 50000;
		private var formatter:DateTimeFormatter = new DateTimeFormatter(LocaleID.DEFAULT);

		public function SpeculumLoader(params:Object = null):void
		{
			super();
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			this.formatter.setDateTimePattern("yyyy-MM-dd HH:mm:ss");
			addEventListener(Event.ADDED_TO_STAGE, this.loadConfig);
		}

		private function loadConfig(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, this.loadConfig);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, this.loadGame);
			loader.load(new URLRequest("game.json"));
		}

		private function loadGame(e:Event):void
		{
			trace("loadGame");
			removeEventListener(Event.COMPLETE, this.loadGame);
			this.config = JSON.parse(e.target.data);

			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onLoadComplete);
			loader.load(new URLRequest(this.config.gamefile), new LoaderContext(false, ApplicationDomain.currentDomain));
		}

		private function onLoadComplete(e:Event):void
		{
			trace("onLoadComplete");
			removeEventListener(Event.COMPLETE, this.onLoadComplete);
			var loaderInfo:LoaderInfo = LoaderInfo(e.target);
			this.game = loaderInfo.content;
			try
			{
				this.game.setHold(this);
			}
			catch (e:Error)
			{
				trace(e);
			}
			this.addChild(this.game as DisplayObject);
			trace("ok");
			var self:SpeculumLoader = this;
			setTimeout(function():void
				{
					self._pushMoneyEvents();
					self._initUnion();
					self._initUnionMembers();
					self._ensureUnionMemberVo();
				}, 1500);
		}

		/* API */

		private var logInfo:Object = null;
		public var isSecondaryLog:Object = {uid: 1, name: "test", nickName: "test"};
		public var nickName:String = "test";
		public function get isLog():Object
		{
			trace("isLog");
			return this.logInfo;
		}

		public function showLogPanel():void
		{
			trace("showLogPanel");
			var log:Object = {
					uid: 1,
					name: "test"
				};
			this.logInfo = log;
			setTimeout(function():void
				{
					stage.dispatchEvent(new SaveEvent(SaveEvent.LOG, log));
				}, 500);
		}

		public function getServerTime():void
		{
			trace("getServerTime");
			setTimeout(function():void
				{
					stage.dispatchEvent(new DataEvent("serverTimeEvent", false, false, formatter.format(new Date())));
				}, 1000);
		}

		public function getData(ui:Boolean = true, index:Number = 0):void
		{
			trace("getData");
			var request:URLRequest = new URLRequest(config.server + "http://api.speculum.fake/save/get/" + index);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, function(e:Event):void
				{
					stage.dispatchEvent(new SaveEvent(SaveEvent.SAVE_GET, JSON.parse(e.target.data).data, true, false));
				});
			loader.load(request);
		}

		public function getList():void
		{
			trace("getList");
			var request:URLRequest = new URLRequest(config.server + "http://api.speculum.fake/save/list");
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, function(e:Event):void
				{
					stage.dispatchEvent(new SaveEvent(SaveEvent.SAVE_LIST, JSON.parse(e.target.data), true, false));
				});
			loader.load(request);
		}

		public function saveData(title:String, data:Object, ui:Boolean = true, index:int = 0):void
		{
			trace("saveData");

			var request:URLRequest = new URLRequest(config.server + "http://api.speculum.fake/save/save");
			request.method = "POST";
			request.data = JSON.stringify( {
						"index": index,
						"title": title,
						"data": data,
						"datetime": formatter.format(new Date())
					});
			request.contentType = "application/json";
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, function(e:Event):void
				{
					stage.dispatchEvent(new SaveEvent(SaveEvent.SAVE_SET, true, true, false));
				});
			loader.load(request);
		}

		private function _pushMoneyEvents():void
		{
			var balance:Number = this._balance;
			stage.dispatchEvent(new PayEvent(PayEvent.GET_MONEY, {balance: balance}, true, false));
			stage.dispatchEvent(new PayEvent(PayEvent.RECHARGED_MONEY, {balance: balance}, true, false));
			stage.dispatchEvent(new PayEvent(PayEvent.PAIED_MONEY, {balance: balance}, true, false));
		}

		private function _unionEvent(type:String, apiName:String, payload:Object, delayMs:int = 300):void
		{
			var self:SpeculumLoader = this;
			setTimeout(function():void
				{
					self.stage.dispatchEvent(new UnionEvent(type, {apiName: apiName, data: JSON.stringify(payload)}, true, false));
				}, delayMs);
		}

		private function _unionError():void
		{
			var self:SpeculumLoader = this;
			setTimeout(function():void
				{
					self.stage.dispatchEvent(new UnionEvent(UnionEvent.UNION_ERROR, {eId: "10003"}, true, false));
				}, 300);
		}

		/* money */

		public function getBalance():void
		{
			trace("getBalance");
			var self:SpeculumLoader = this;
			setTimeout(function():void
				{
					self.stage.dispatchEvent(new PayEvent(PayEvent.GET_MONEY, {balance: self._balance}, true, false));
				}, 500);
		}

		public function decMoney_As3(...rest:Array):void
		{
			trace("decMoney_As3");
			var self:SpeculumLoader = this;
			setTimeout(function():void
				{
					self.stage.dispatchEvent(new PayEvent(PayEvent.DEC_MONEY, {balance: self._balance}, true, false));
				}, 400);
		}

		public function payMoney_As3(...rest:Array):void
		{
			trace("payMoney_As3");
			this._pushMoneyEvents();
		}

		public function getPaiedMoney(...rest:Array):void
		{
			trace("getPaiedMoney");
			var self:SpeculumLoader = this;
			setTimeout(function():void
				{
					self.stage.dispatchEvent(new PayEvent(PayEvent.PAIED_MONEY, {balance: self._balance}, true, false));
				}, 500);
		}

		public function getTotalPaiedFun(exInfo:Object = null):void
		{
			trace("getTotalPaiedFun");
			var self:SpeculumLoader = this;
			setTimeout(function():void
				{
					self.stage.dispatchEvent(new PayEvent(PayEvent.PAIED_MONEY, {balance: self._balance}, true, false));
				}, 500);
		}

		public function getTotalRechargedFun(exInfo:Object = null):void
		{
			trace("getTotalRechargedFun");
			var self:SpeculumLoader = this;
			setTimeout(function():void
				{
					self.stage.dispatchEvent(new PayEvent(PayEvent.RECHARGED_MONEY, {balance: self._balance}, true, false));
				}, 500);
		}

		public function getStoreState():void
		{
			trace("getStoreState");
			var self:SpeculumLoader = this;
			setTimeout(function():void
				{
					self.stage.dispatchEvent(new DataEvent("StoreStateEvent", false, false, "1"));
				}, 500);
		}

		public function buyPropNd(param1:Object):void
		{
			trace("buyPropNd");
			param1.balance = this._balance;
			setTimeout(function():void
				{
					stage.dispatchEvent(new ShopEvent(ShopEvent.SHOP_BUY_ND, param1, true, false));
				}, 500);
		}

		/* union */

		public function getVariables(idx:int, ids:Array):void
		{
			trace("getVariables, idx: " + idx + ", ids: " + ids);
			var payload:Array = [];
			if (ids != null)
			{
				for (var i:int = 0; i < ids.length; i++)
				{
					payload.push({id: ids[i], value: "0"});
				}
			}
			this._unionEvent(UnionEvent.UNION_VARIABLES_SUCCESS, "get_variables", payload);
		}

		public function getOwnUnion(...rest:Array):void
		{
			trace("getOwnUnion");
			this._unionEvent(UnionEvent.UNION_VISITOR_SUCCESS, "own_union", {unionInfo: {}, member: {}}, 300);
		}

		private function _initUnion(delayMs:int = 300):void
		{
			this._unionEvent(UnionEvent.UNION_VISITOR_SUCCESS, "own_union", {unionInfo: {}, member: {}}, delayMs);
		}

		private function _initUnionMembers(delayMs:int = 500):void
		{
			this._unionEvent(UnionEvent.UNION_MEMBER_SUCCESS, "member_list", [], delayMs);
		}

		private function _ensureUnionMemberVo():void
		{
			try
			{
				var umClass:Class = Class(getDefinitionByName("union.model.UnionManager"));
				var um:Object = umClass["getIns"]();
				if (um == null)
				{
					return;
				}
				var info:Object = um["unionInfo"];
				if (info == null)
				{
					return;
				}
				if (info["memberVo"] == null)
				{
					var mvClass:Class = Class(getDefinitionByName("union.model.vo.MemberVo"));
					info["memberVo"] = new mvClass();
				}
			}
			catch (e:Error)
			{
				trace("ensureUnionMemberVo failed: " + e);
			}
		}

		public function unionCreate(...rest:Array):void
		{
			this._unionEvent(UnionEvent.UNION_VISITOR_SUCCESS, "create_union", false);
		}

		public function getUnionList(...rest:Array):void
		{
			this._unionEvent(UnionEvent.UNION_VISITOR_SUCCESS, "list_union", []);
		}

		public function applyUnion(...rest:Array):void
		{
			this._unionEvent(UnionEvent.UNION_VISITOR_SUCCESS, "apply_union", false);
		}

		public function getUnionMembers(...rest:Array):void
		{
			this._unionEvent(UnionEvent.UNION_MEMBER_SUCCESS, "member_list", []);
		}

		public function quitUion(...rest:Array):void
		{
			this._unionEvent(UnionEvent.UNION_MEMBER_SUCCESS, "quit_union", true);
		}

		public function usePersonalContribution(...rest:Array):void
		{
			this._unionEvent(UnionEvent.UNION_MEMBER_SUCCESS, "use_pesonal_contribution", 0);
		}

		public function setMemberExtra(...rest:Array):void
		{
			this._unionEvent(UnionEvent.UNION_MEMBER_SUCCESS, "union_extra_change", true);
		}

		public function setUnionExtra(...rest:Array):void
		{
			this._unionEvent(UnionEvent.UNION_MEMBER_SUCCESS, "union_extra_change", true);
		}

		public function doTask(...rest:Array):void
		{
			this._initUnionMembers(250);
			this._ensureUnionMemberVo();
			this._unionEvent(UnionEvent.UNION_GROW_SUCCESS, "union_task", false, 400);
		}

		public function doExchange(...rest:Array):void
		{
			this._initUnionMembers(250);
			this._ensureUnionMemberVo();
			this._unionEvent(UnionEvent.UNION_GROW_SUCCESS, "union_exchange", false, 400);
		}

		public function getTaskValue(...rest:Array):void
		{
			this._initUnionMembers(250);
			this._ensureUnionMemberVo();
			this._unionEvent(UnionEvent.UNION_GROW_SUCCESS, "union_task_complete", {}, 400);
		}

		public function getApplyList(...rest:Array):void
		{
			this._unionEvent(UnionEvent.UNION_MASTER_SUCCESS, "union_apply_list", []);
		}

		public function auditMember(...rest:Array):void
		{
			this._unionEvent(UnionEvent.UNION_MASTER_SUCCESS, "union_member_audit", false);
		}

		public function applyMultiAudit(...rest:Array):void
		{
			this._unionEvent(UnionEvent.UNION_MASTER_SUCCESS, "union_multi_member_audit", false);
		}

		public function removeMember(...rest:Array):void
		{
			this._unionEvent(UnionEvent.UNION_MASTER_SUCCESS, "union_remove_member", false);
		}

		public function dissolveUnion(...rest:Array):void
		{
			this._unionEvent(UnionEvent.UNION_MASTER_SUCCESS, "union_dissolve", false);
		}

		public function useUnionContribution(...rest:Array):void
		{
			this._unionEvent(UnionEvent.UNION_MASTER_SUCCESS, "use_union_contribution", 0);
		}

		public function transferUnion(...rest:Array):void
		{
			this._unionEvent(UnionEvent.UNION_MASTER_SUCCESS, "union_transfer", false);
		}

		public function getUnionLog(...rest:Array):void
		{
			this._unionEvent(UnionEvent.UNION_VISITOR_SUCCESS, "union_log", []);
		}

		public function getRoleList(...rest:Array):void
		{
			this._unionEvent(UnionEvent.UNION_ROLE_SUCCESS, "set_role", []);
		}

		public function setRole(...rest:Array):void
		{
			this._unionEvent(UnionEvent.UNION_ROLE_SUCCESS, "set_role", true);
		}

		public function doVariable(...rest:Array):void
		{
			this._unionEvent(UnionEvent.UNION_VARIABLES_SUCCESS, "change_variable", true);
		}

		/* rank */

		public function getRankListsData(...rest:Array):void
		{
			trace("getRankListsData");
			var self:SpeculumLoader = this;
			setTimeout(function():void
				{
					self.stage.dispatchEvent(new RankListEvent(RankListEvent.RANKLIST_SUCCESS, {apiName: "4", data: []}, true, false));
				}, 300);
		}

		public function getRankListByOwn(...rest:Array):void
		{
			trace("getRankListByOwn");
			var self:SpeculumLoader = this;
			setTimeout(function():void
				{
					self.stage.dispatchEvent(new RankListEvent(RankListEvent.RANKLIST_SUCCESS, {apiName: "2", data: []}, true, false));
				}, 300);
		}

		/* secondary account */

		public function getSecondarySaveList(...rest:Array):void
		{
			trace("getSecondarySaveList");
			var self:SpeculumLoader = this;
			var request:URLRequest = new URLRequest(self.config.server + "http://api.speculum.fake/save/list");
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, function(e:Event):void
				{
					var list:Array = JSON.parse(e.target.data) as Array;
					if (list == null)
					{
						list = [];
					}
					self.stage.dispatchEvent(new SecondaryEvent(SecondaryEvent.SAVE_LIST, {code: "30000", data: list}, true, false));
				});
			loader.load(request);
		}

		public function getSecondaryData(index:Number):void
		{
			trace("getSecondaryData: " + index);
			var self:SpeculumLoader = this;
			var request:URLRequest = new URLRequest(self.config.server + "http://api.speculum.fake/save/get/" + index);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, function(e:Event):void
				{
					var entry:Object = JSON.parse(e.target.data).data;
					if (entry == null)
					{
						self.stage.dispatchEvent(new SecondaryEvent(SecondaryEvent.SAVE_GET, {code: "99999"}, true, false));
					}
					else
					{
						self.stage.dispatchEvent(new SecondaryEvent(SecondaryEvent.SAVE_GET, {code: "40000", data: entry}, true, false));
					}
				});
			loader.load(request);
		}

		public function secondaryLogOut(...rest:Array):void
		{
			trace("secondaryLogOut");
			var self:SpeculumLoader = this;
			setTimeout(function():void
				{
					self.stage.dispatchEvent(new SecondaryEvent(SecondaryEvent.LOG_OUT, {code: "20000"}, true, false));
				}, 300);
		}

		public function userLogOut(...rest:Array):void
		{
			trace("userLogOut");
			stage.dispatchEvent(new Event("userLoginOut"));
		}

		public function showSecondaryLogPanel(...rest:Array):void
		{
			trace("showSecondaryLogPanel");
		}

		public function submitScoreToRankLists(idx:uint, rankInfoAry:Array):void
		{
			trace("submitScoreToRankLists, idx: " + idx + ", rankInfoAry: " + rankInfoAry);
			setTimeout(function():void
				{
					stage.dispatchEvent(new RankListEvent(RankListEvent.RANKLIST_SUCCESS, {
									apiName: "3",
									data: [ {
											code: "1",
											message: "NOT SUPPORTED"
										}]
								}, true, false));
				}, 500);
		}
	}
}
