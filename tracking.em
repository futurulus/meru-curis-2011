system.require('std/core/repeatingTimer.em');
system.require('work/lookAt.em');
system.require('work/spin.em');
var trackingTimer;
var butterfly;

(function () {

	var timerDelay = 0.05;
	var mesh = 'meerkat:///wmonroe4/butterfly.dae/original/0/butterfly.dae';
	system.create_presence(mesh, function(newPres){
		butterfly = newPres;
		butterfly.position = <0, 0, 10>;
		spin(butterfly);
	});
	
	function track(pres1, pres2)
	{
		lookAt(pres1, pres2.position);
		
		/* */
		var vRel = pres2.velocity - pres1.velocity;
		var disp = pres2.position - pres1.position;
		var axis = disp.cross(vRel).normal();
		var rotation = Math.sqrt(vRel.lengthSquared() * 1. / disp.lengthSquared());
		pres1.orientationVel = (new util.Quaternion(axis, 1)).scale(rotation);
		/* */
	};

	trackingTimer = new std.core.RepeatingTimer(timerDelay, function(){
		if(typeof(butterfly) != 'undefined')
			track(system.self, butterfly);
	});

})();

