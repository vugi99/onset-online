(this.webpackJsonpreact_ts_webpack=this.webpackJsonpreact_ts_webpack||[]).push([[0],[,,,,,,,,,,,,,,,,,function(e,t,n){e.exports=n(42)},,,,,function(e,t,n){},function(e,t,n){},,,,,,,,,,,function(e,t,n){},function(e,t,n){},function(e,t,n){},function(e,t,n){},function(e,t,n){},function(e,t,n){},function(e,t,n){},function(e,t,n){},function(e,t,n){"use strict";n.r(t);var a,c=n(0),o=n.n(c),i=n(8),r=n.n(i),l=(n(22),n(23),n(1)),u=n(2),s=n(3),p=n(16),b=n(6),d=function(e){return function(){return w.dispatch(e.apply(void 0,arguments))}},m=Object(u.b)("NOTIFY_SPEED"),f=Object(u.b)("NOTIFY_DECOMPTE"),O=Object(u.b)("NOTIFY_TIME"),j=Object(u.b)("NOTIFY_POSITION"),E=Object(u.b)("PLAYER_FINISHED"),v=Object(u.b)("PASS_CHECKPOINT"),N=Object(u.b)("HIDE_CHECKPOINT"),I=Object(u.b)("CLEAR_FINISH_TIME");window.NotifySpeed=d(m),window.NotifyDecompte=d(f),window.NotifyTime=d(O),window.PlayerFinished=d(E),window.PlayerPassedCheckpoint=d(v),window.HideCheckPoint=d(N),window.ClearFinishTime=d(I),window.NotifyPosition=d(j);var y=Object(u.c)({speed:0,decompte:-1,time:0,total:0,position:0,checkpointInfos:{all:[]}},(a={},Object(s.a)(a,m.type,(function(e,t){return Object(b.a)({},e,{speed:Math.abs(Number.parseFloat(t.payload))})})),Object(s.a)(a,f.type,(function(e,t){return Object(b.a)({},e,{decompte:Number.parseInt(t.payload),win:void 0})})),Object(s.a)(a,O.type,(function(e,t){return Object(b.a)({},e,{time:Number.parseInt(t.payload)})})),Object(s.a)(a,j.type,(function(e,t){var n=JSON.parse(t.payload);return Object(b.a)({},e,{position:n.pos,total:n.total})})),Object(s.a)(a,v.type,(function(e,t){var n=JSON.parse(t.payload);return Object(b.a)({},e,{checkpointInfos:{last:n.nb,time:e.time,visible:!0,all:[].concat(Object(p.a)(e.checkpointInfos.all),[{id:n.nb,time:e.time}])}})})),Object(s.a)(a,N.type,(function(e){return Object(b.a)({},e,{checkpointInfos:Object(b.a)({},e.checkpointInfos,{visible:!1})})})),Object(s.a)(a,E.type,(function(e,t){var n=JSON.parse(t.payload);return Object(b.a)({},e,{speed:0,decompte:-1,time:0,win:{time:n.time,pos:n.place},checkpointInfos:{all:[]}})})),Object(s.a)(a,I.type,(function(e){return Object(b.a)({},e,{win:void 0})})),a)),w=Object(u.a)({reducer:y}),h=(n(34),function(){var e=Object(l.b)((function(e){return e.speed})),t=e<=20?-140:e-20-140;return console.log("Player Speed : ",e),o.a.createElement("div",{className:"gauge"},o.a.createElement("div",{className:"needle",style:{transform:"rotate(".concat(t,"deg)")}},o.a.createElement("div",{className:"needleBody"})),o.a.createElement("div",{className:"textSpeed"},e))}),k=(n(35),function(){var e=Object(l.b)((function(e){return e.decompte}));return-1!==e?o.a.createElement("div",{className:"decompte"},"(",e,")"):null}),P=(n(36),function(e){return e<10?"0".concat(e):"".concat(e)}),S=function(){var e=Object(l.b)((function(e){return e.time}));console.log("Time : ",e);var t=e/1e3,n=Math.floor(t/60),a=Math.floor(t%60),c=e%1e3;return 0!==e?o.a.createElement("div",{className:"counterContainer"},o.a.createElement("div",{className:"counterBox"},P(n),":",P(a),":",c)):null},T=(n(37),function(){var e=Object(l.b)((function(e){return e.checkpointInfos}));console.log("Checkpoints data : ",e);var t=e.time;if(t&&e.visible){var n=t/1e3,a=Math.floor(n/60),c=Math.floor(n%60);return o.a.createElement("div",{className:"checkpointPassed"},"Checkpoint #",e.last," ",a,":",c)}return null}),_=(n(38),function(){var e=Object(l.b)((function(e){return e.win}));return console.log("Win Data : ",e),e?o.a.createElement("div",{className:"winDisplay"},"( FINISHED ",e.pos," )"):null}),C=(n(39),function(){var e=Object(l.b)((function(e){return{pos:e.position,total:e.total}})),t=e.pos,n=e.total;return o.a.createElement("div",{className:"position"},t," / ",n)}),F=function(){return o.a.createElement(l.a,{store:w},o.a.createElement(S,null),o.a.createElement(T,null),o.a.createElement(k,null),o.a.createElement(h,null),o.a.createElement(C,null),o.a.createElement(_,null))};n(40),n(41);r.a.render(o.a.createElement(F,null),document.getElementById("root"))}],[[17,1,2]]]);
//# sourceMappingURL=main.chunk.js.map