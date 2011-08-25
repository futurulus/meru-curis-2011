system.import('work/motion.em');

system.self.mesh = 'meerkat:///elliotconte/models/rocket.dae/optimized/0/rocket.dae';

var baseOrientation = new util.Quaternion(
	-0.31108397245407104,
	-0.6350014209747314,
	0.31108397245407104,
	0.6350014209747314
);

var look = new motion.LookForward(system.self, baseOrientation);
var spr = new motion.Spring(system.self, system.self.position, 4);