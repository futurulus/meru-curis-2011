var me = system.presences[0];
var xrot = new util.Quaternion(new util.Vec3(1, 0, 0), .5);
var yrot = new util.Quaternion(new util.Vec3(0, 1, 0), .5);
var zrot = new util.Quaternion(new util.Vec3(0, 0, 1), .5);
var nullq = new util.Quaternion(0, 0, 0, 1);

me.setOVel = me.setOrientationVel;
me.setO = me.setOrientation;

function resetO()
{
	me.setOVel(nullq);
	me.setO(nullq);
}
