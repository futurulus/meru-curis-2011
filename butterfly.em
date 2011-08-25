system.require('std/core/repeatingTimer.em');
var butterflyTimer;

(function (){

	var flapPeriod = 0.25;

	var up = true;
	var upOrient = new util.Quaternion();
	var downOrient = new util.Quaternion(<0, 0, 1>, Math.PI);

	function flap()
	{
		  up = !up;

		  if(up)
		      system.self.orientation = upOrient;
		  else
		      system.self.orientation = downOrient;
	};

	butterflyTimer = new std.core.RepeatingTimer(flapPeriod / 2., flap);

})();
