system.require('work/collision.em');
system.require('work/motion.em');
system.require('work/units.em');

var c;
var g;
var s;
var mesh = 'meerkat:///emily2e/models/earth.dae/optimized/0/earth.dae';
var globe;
var anchor = system.self;

function resetGlobe() {
	globe.velocity = <0, 0, 0>;
	globe.position = system.self.position + <0, -3 * u.m, 0>;
}

if(typeof(globe) === 'undefined') {
	system.import('work/flock_stationary.em');
	
	system.createPresence(mesh, function(newPres) {
		globe = newPres;
		globe.scale = 0.5;
		resetGlobe();
		c = new motion.Collision(globe, coll.TestSpheres(flock), coll.Bounce(1.));
		g = new motion.Gravity(globe);
		s = new motion.Spring(globe, anchor, 10);
	});
} else {
	resetGlobe();
}
