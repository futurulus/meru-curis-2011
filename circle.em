var me = system.presences[0];
var nullVec = new util.Vec3(0, 0, 0);
var up = new util.Vec3(0, 1, 0);

var repeatTimeout = 0.05;
var velocity = 10;

var doTwirl = false;

function twirl()
{
	if(doTwirl)
		me.setVelocity(up.cross(me.getPosition).normal.scale(velocity));
	else
		me.setVelocity(nullVec);
	
	system.timeout(repeatTimeout, twirl);
}
