system.import('std/core/repeatingTimer.em');
system.import('work/lookAt.em');

var freeze = false;
var timerLength = 0.05;
var timer;

function recalculateVelocity(pres)
{
  if(freeze)
    pres.velocity = <0, 0, 0>;
  else
  {
    var v = <0, 1, 0>.cross(pres.position);
    pres.velocity = v;
    look(pres, v);
  }
};

function spin(pres)
{
	timer = new std.core.RepeatingTimer(timerLength, function(){recalculateVelocity(pres);});
};

