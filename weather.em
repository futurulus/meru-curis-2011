system.require('work/motion.em');
system.require('work/units.em');

// General weather box settings
var width = 100 * u.m;
var ground = -20 * u.m;
var sky = 50 * u.m;
var center = system.self.position;
center.y = ground;

// Cloud settings
var cloudScale = sky / 0.0675;
var cloudOffset = cloudScale * 0.025;
var cloudMesh = 'meerkat:///wmonroe4/clouds.dae/optimized/0/clouds.dae';
var cloudDome;

// Lightning settings
var duration = 0.25 * u.s;
var spacing = 5 * u.s;
var lightningMesh = 'meerkat:///wmonroe4/lt2.dae/optimized/0/lt2.dae';
var lightningBolt;

// Snow settings
var snowSpeed = 1.5 * u.m / u.s;
var snowMesh = 'meerkat:///wmonroe4/snow_large_em.dae/optimized/0/snow_large_em.dae';

// Rain settings
var rainSpeed = 20 * u.m / u.s;
var rainMesh = 'meerkat:///wmonroe4/rain_large.dae/optimized/0/rain_large.dae';

// Precipitation (rain/snow) settings
var precipScale = 20 * u.m;
var precipBlocks = [];
var precipSpeed = rainSpeed;
var precipMesh = rainMesh;

system.createPresence(lightningMesh, function(p) {
	lightningBolt = p;
	p.scale = (sky - ground) * Math.sqrt(5) / 4;
	p.mesh = '';
});

var stop = {lightning: false};

function startLightning() {
	flashOn();
}

function flashOn() {
	if(stop.lightning) {
		stop.lightning = false;
		return;
	}
	
	var x = center.x + width * (Math.random() - 0.5);
	var z = center.z + width * (Math.random() - 0.5);
	var y = (ground + sky) / 2;
	
	var theta = 2 * Math.PI * Math.random();
	
	system.print('<' + x + ', ' + z + '>\n');
	
	lightningBolt.position = <x, y, z>;
	lightningBolt.orientation = new util.Quaternion(<0, 1, 0>,
			theta);
	lightningBolt.mesh = lightningMesh;
	
	system.timeout(duration, flashOff);
}

function randomExponential(lambda) {
	var u = 1 - Math.random();
	return -Math.log(u) / lambda;
}

function flashOff() {
	lightningBolt.mesh = '';
	system.timeout(randomExponential(1 / spacing), flashOn);
}

function stopLightning() {
	stop.lightning = true;
}

function createBlock(pos) {
	if(pos.x > center.x + width) {
		pos.x = center.x - width;
		pos.z += 2 * precipScale;
	}
	
	if(pos.z > center.z + width) {
		pos.z = center.z - width;
		pos.y -= 2 * precipScale;
	}
	
	if(pos.y < ground)
		return;
	
	system.createPresence(precipMesh, function(newBlock) {
		newBlock.position = pos;
		newBlock.scale = precipScale * Math.sqrt(3);
		newBlock.controller = new motion.Position(newBlock, function(p) {
			if(p.position.y + precipScale < ground) {
				var newPos = p.position;
				newPos.y += Math.ceil((sky - ground) /
						(2 * precipScale)) * 2 * precipScale;
				p.position = newPos;
			}
		}, 0.125 + 0.25 * Math.random());
		
		precipBlocks.push(newBlock);
		
		system.timeout(.001, function() {
			createBlock(pos + <2 * precipScale, 0, 0>);
		});
	});
}

function makePrecip() {
	var pos = <center.x - width, sky, center.z - width>;
	
	createBlock(pos);
}

function stopPrecip() {
	pausePrecip();
	for(var i in precipBlocks)
		precipBlocks[i].mesh = '';
}

function pausePrecip() {
	for(var i in precipBlocks)
		precipBlocks[i].velocity = <0, 0, 0>;
}

function startPrecip() {
	for(var i in precipBlocks) {
		precipBlocks[i].mesh = precipMesh;
		precipBlocks[i].velocity = <0, -precipSpeed, 0>;
	}
}

function rain() {
	precipMesh = rainMesh;
	precipSpeed = rainSpeed;
	startPrecip();
}

function snow() {
	precipMesh = snowMesh;
	precipSpeed = snowSpeed;
	startPrecip();
}

function makeClouds() {
	var resetDome = function (dome) {
		cloudDome = dome;
		cloudDome.position = center + <0, cloudOffset, 0>;
		cloudDome.scale = cloudScale;
	}
	
	if(typeof(cloudDome) === 'undefined') {
		system.createPresence(cloudMesh, resetDome);
	} else {
		resetDome(cloudDome);
	}
}