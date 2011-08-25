/* motion.em
 *
 * An object motion controller library
 *
 * Author: Will Monroe
 *
 * Defines a set of classes that continuously monitor a presence's state and
 * change its position or velocity when necessary.  To assign a motion
 * controller to a presence, simply create a controller with the presence as
 * the first parameter to the constructor:
 *		var controller = new motion.SomeType(presence, options...);
 */

system.require('std/core/repeatingTimer.em');
system.require('std/core/pretty.em');

system.require('units.em');

if(typeof(motion) === 'undefined')
	motion = {};
if(typeof(motion.util) === 'undefined')
	motion.util = {};

motion.util._isVector = function(obj) {
	return (typeof(obj) !== 'undefined' &&
			'__getType' in obj && obj.__getType() == 'vec3');
};

motion.util._isQuat = function(obj) {
	return (typeof(obj) !== 'undefined' &&
			'__getType' in obj && obj.__getType() == 'quat');
};

motion.util._isVisible = function(obj) {
    return (typeof(obj) !== 'undefined' && '__getType' in obj &&
            (obj.__getType() == 'presence' || obj.__getType() == 'visible'));
};

/**
 * Motion controllers operate on repeating timers.  The last (optional)
 * argument to every class of controller specifies the repeat period at
 * which the timer operates; assigning longer periods means less network
 * traffic but a slower update rate.  defaultPeriod is the period for all
 * controllers whose last argument is not given.
 * @constant
 */
motion.defaultPeriod = 0.06 * u.s;


/**
 * @class Base class for all motion controllers.  This sets up the basic
 * repeating timer code, with a callback specified by base classes.  Generally
 * intended as an abstract base class, but could be useful on its own with a
 * specialized callback.  The core methods available for all controllers are
 * also defined here.
 *
 * @param presence The presence to control.  This may be changed later by
 *		assigning to <code>controller.presence</code>.
 * @param fn The callback function to call repeatedly, with a presence as a
 * @param period (optional =defaultPeriod) The period at which the callback is
 *		called
 */
motion.Motion = system.Class.extend({
	init: function(presence, fn, period) {
		if(typeof(period) === 'undefined')
			period = motion.defaultPeriod;

		var self = this; // so callbacks can refer to instance variables
		
		self.period = period;
		self.presence = presence;
		self.timer = new std.core.RepeatingTimer(self.period, function() {
			fn(self.presence);
		});
	},
	
	/**
	 * Pauses the operation of the controller.  The controller can be resumed
	 * at any time by calling <code>reset</code>.
	 */
	suspend: function() {
		this.timer.suspend();
	},
	
	/**
	 * Restarts the controller, resuming if suspended.
	 */
	reset: function() {
		this.timer.reset();
	},
	
	/**
	 * @return <code>true</code> if the controller is currently suspended,
	 *		<code>false</code> otherwise.
	 */
	isSuspended: function () {
		return this.timer.isSuspended();
	}
});

/**
 * @class A controller for applying accelerations to an object.
 *
 * @param presence The presence to control
 * @param accelFn (optional =get from presence.accel field) A function that
 *		should return the acceleration on a presence at any point in time.  If
 *		accelFn returns undefined ("return;"), the acceleration will be
 *		unchanged from the last call.  If accelFn itself is undefined (or not
 *		provided), the controller will use the value of presence.accel.
 * @param period (optional =defaultPeriod) The period at which the
 *		acceleration is updated
 */
motion.Acceleration = motion.Motion.extend({
	init: function(presence, accelFn, period) {
		var self = this;
		if(typeof(presence.accel) === 'undefined')
			presence.accel = <0, 0, 0>;
		if(typeof(accelFn) === 'undefined')
			accelFn = function(p) { return p.accel; };
		else if(typeof(accelFn) !== 'function')
			throw('second argument "accelFn" to motion.Acceleration (' +
					system.core.pretty(accelFn) +
					' is not a function or undefined');
		
		var callback = function(p) {
			var accel = accelFn(p);
			if(motion.util._isVector(accel))
				p.accel = accel;
			else if(typeof(accel) != 'undefined')
				throw('in motion.Acceleration callback: accelFn should return ' +
						'a vector or undefined (instead got ' +
						std.core.pretty(accel) + ')');
			
			// we need to apply a change in velocity directly, since
			// acceleration is not a core feature
			p.velocity = p.velocity + p.accel.scale(self.period);
		};
		this._super(presence, callback, period);
	}
});

/**
 * @class A controller for manipulating the velocity of a presence.
 * @param presence The presence to control
 * @param posFn A function that should return the new velocity of the presence
 * 		at any point in time (just return; to leave velocity unchanged)
 * @param period (optional =defaultPeriod) The period at which the presence's
 *		velocity is updated
 */
motion.Velocity = motion.Motion.extend({
	init: function(presence, velFn, period) {
		if(typeof(accelFn) !== 'function')
			throw('second argument "velFn" to motion.Velocity (' +
					system.core.pretty(velFn) + ') is not a function');
		
		var callback = function(p) {
			var vel = velFn(p);
			if(motion.util._isVector(vel))
				p.velocity = vel;
			else if(typeof(vel) != 'undefined')
				throw('in motion.Velocity callback: velFn should return ' +
						'a vector or undefined (instead got ' +
						std.core.pretty(vel) + ')');
		};
		this._super(presence, callback, period);
	}
});

/**
 * @class A controller for manipulating the position of a presence directly.
 * Note that if this is used for constant updates, the position changes will
 * appear abrupt and jittery -- this type of controller is best used for
 * sudden, infrequent changes (such as teleportation).
 *
 * @param presence The presence to control
 * @param posFn A function that should return the new position of an object
 * 		at any point in time (just return; to leave position unchanged)
 * @param period (optional =defaultPeriod) The period at which the object's position is
 *		updated
 */
motion.Position = motion.Motion.extend({
	init: function(presence, posFn, period) {
		if(typeof(posFn) !== 'function')
			throw('second argument "posFn" to motion.Position (' +
					system.core.pretty(posFn) + ') is not a function');
		
		var callback = function(p) {
			var pos = posFn(p);
			if(motion.util._isVector(pos))
				p.position = pos;
			else if(typeof(pos) != 'undefined')
				throw('in motion.Position callback: posFn should return ' +
						'a vector or undefined (instead got ' +
						std.core.pretty(pos) + ')');
		};
		this._super(presence, callback, period);
	}
});

/**
 * @class A controller for manipulating the orientation of a presence.  This
 *		is best used for infrequent updates or in combination with an
 *		OrientationVel controller; frequent raw orientation updates will
 *		appear jittery.
 * @param presence The presence to control
 * @param orientFn A function that should return the new orientation of the
 *		presence at any point in time (just return; to leave orientation
 *		unchanged)
 * @param period (optional =defaultPeriod) The period at which the object's
 *		orientation is updated
 */
motion.Orientation = motion.Motion.extend({
	init: function(presence, orientFn, period) {
		if(typeof(orientFn) !== 'function')
			throw('second argument "orientFn" to motion.Orientation (' +
					system.core.pretty(orientFn) + ') is not a function');
		
		var callback = function(p) {
			var orient = orientFn(p);
			if(motion.util._isQuat(orient))
				p.orientation = orient;
			else if(typeof(orient) != 'undefined')
				throw('in motion.Orientation callback: orientFn should return ' +
						'a quaternion or undefined (instead got ' +
						std.core.pretty(orient) + ')');
		};
		this._super(presence, callback, period);
	}
});

/**
 * @class A controller for manipulating the orientation velocity of a
 * 		presence.
 * @param presence The presence to control
 * @param oVelFn A function that should return the new orientation velocity
 * 		of the presence at any point in time (just return; to leave orientation
 *		unchanged)
 * @param period (optional =defaultPeriod) The period at which the object's
 * 		orientation velocity is updated
 */
motion.OrientationVel = motion.Motion.extend({
	init: function(presence, oVelFn, period) {
		if(typeof(oVelFn) !== 'function')
			throw('second argument "oVelFn" to motion.Orientation (' +
					system.core.pretty(oVelFn) + ') is not a function');
		
		var callback = function(p) {
			var oVel = oVelFn(p);
			if(motion.util._isQuat(oVel))
				p.orientationVel = oVel;
			else if(typeof(oVel) != 'undefined')
				throw('in motion.Orientation callback: oVelFn should return ' +
						'a quaternion or undefined (instead got ' +
						std.core.pretty(oVel) + ')');
		};
		this._super(presence, callback, period);
	}
});

/**
 * The default acceleration of an object under a Gravity controller.
 * @constant
 */
motion.defaultGravity = 9.80665 * u.m / u.s / u.s;

/**
 * Accelerates a presence downward under a constant gravitational force.
 *
 * @param presence The presence to accelerate
 * @param accel (optional =<0, -defaultGravity, 0>) The acceleration of
 *		gravity (as either a scalar quantity or a vector).  This may be
 *		changed later through <code>controller.accel</code>, but only as a
 *		vector.
 * @param period (optional =defaultPerid) The period at which the presence's
 *		velocity is updated
 */
motion.Gravity = motion.Acceleration.extend({
	init: function(presence, accel, period) {
		var self = this;
		
		if(typeof(accel) === 'number')
			self.accel = <0, -accel, 0>;
		else
			self.accel = accel || <0, -motion.defaultGravity, 0>;
		
		this._super(presence, function() { return self.accel; }, period);
	}
});

/**
 * Accelerates a presence under a harmonic spring force.
 *
 * @param presence The presence to control
 * @param anchor The anchor point around which the presence oscillates.  This
 *		can be a vector (point in space) or another presence or visible (which
 * 		will be examined as its position changes).  It can be changed later 
 *		through <code>controller.anchor</code>.
 * @param stiffness The stiffness or "spring constant" of the spring force --
 *		the greater the stiffness, the greater the force at the same distance
 * @param damping (optional =0) The damping or "friction" of the spring motion
 * @param eqLength (optional =0) The equilibrium length of the spring; if
 *		positive, the presence will be accelerated *away* from the anchor
 *		point if it gets too close
 * @param period (optional =defaultPeriod) The period at which the presence's
 *		velocity is updated
 */
motion.Spring = motion.Acceleration.extend({
	init: function(presence, anchor, stiffness, damping, eqLength, period) {
		var self = this;
		
		self.stiffness = stiffness;
		self.eqLength = eqLength || 0;
		self.damping = damping || 0;
		
		self.anchor = anchor;
		var anchorFn;
		if(typeof(self.anchor) === 'object' && 'x' in self.anchor)
			anchorFn = function() {	return self.anchor; };
		else if(typeof(anchor) === 'object' && 'position' in self.anchor)
			anchorFn = function() { return self.anchor.position; };
		else
			throw("Second argument 'anchor' to motion.Spring constructor ('" +
					std.core.pretty(anchor) +
					"') is not a vector or presence");
		
		var accelFn = function(p) {
			var mass = ('mass' in p ? p.mass : 1);
		
			var disp = (p.position - anchorFn());
			var len = disp.length();
			if(len < 1e-08)
				// even if eqLength is nonzero, we don't know which way to push
				// the object if it's directly on top of the anchor.
				return <0, 0, 0>;
			
			return disp.scale((self.stiffness * (self.eqLength - len) -
					self.damping * p.velocity.dot(disp)) / (len * mass));
		};
		
		this._super(presence, accelFn, period);
	}
});

motion._allCollisions = [];

/**
 * @class A generic controller to detect and respond to collisions.
 * 		All arguments except <code>period</code> can be modified later through
 *		fields of the same name (e.g. controller.testFn).
 *
 * @param presence The presence whose collisions are to be detected (the
 *		"colliding presence")
 * @param testFn A function that should detect any collisions when called
 *		repeatedly and return one in the form of a "collision object"
 * @param responseFn A function to be called when a collision happens
 * @param period (optional =defaultPeriod) The period at which to check for
 *		collisions
 *
 * @see collision.em
 */
motion.Collision = motion.Motion.extend({
	init: function(presence, testFn, responseFn, period) {
		var self = this;
		
		self.testFn = testFn;
		self.responseFn = responseFn;
		
        var onCollisionMessage = function(message, sender) {
            if(message.collision.other === presence.toString()) {
                message.collision.other = message.collision.self;
                message.collision.self = presence.toString();
                message.collision.normal = message.collision.normal.neg();
                message.collision.impact = message.collision.impact.neg();
            }

            motion._allCollisions.push(message.collision);

            self.responseFn(presence, message.collision);
        };

        self.collisionHandler = (onCollisionMessage <<
                [{'action':'collision':},
                {'id':presence.toString():},
                {'collision'::}]);

		var testCollision = function(p) {
            var collision = self.testFn(p);
            if(collision) {
                {
                    action: 'collision', 
                    id: collision.self, 
                    collision: collision
                } >> system.createVisible(collision.self) >> [];

                if(typeof(collision.other) === 'string') {
                    {
                        action: 'collision',
                        id: collision.other,
                        collision: collision
                    } >> system.createVisible(collision.other) >> []; 
                }
            }
		};
		
		this._super(presence, testCollision, period);
	},

    suspend: function() {
        self.collisionHandler.suspend();
        this._super();
    },

    reset: function() {
        self.colisionHandler.reset();
        this._super();
    }
});

/**
 * The default vector to use as "up" in making a presence look forward.
 * @constant
 */
motion.defaultUp = <0, 1, 0>;

/**
 * The default orientation of an presence.
 * @constant
 */
motion.defaultOrientation = new util.Quaternion();

/**
 * @class A controller that always points an object in the direction it is
 *		currently moving.
 *
 * @param presence The presence to control.
 * @param baseOrientation The orientation for the presence that makes it point
 *		along the negative z axis.  This can be used to reorient "sideways"
 *		meshes taken from the CDN.
 * @param up (optional =defaultUp) The direction that the presence will use to
 * 		orient itself so it is right-side up in addition to facing forward
 * @param period (optional =defaultPeriod) The period at which to update the
 * 		presence's orientation.
 */
motion.LookForward = motion.Orientation.extend({
	init: function(presence, baseOrientation, up, period) {
		up = up || motion.defaultUp;
		baseOrientation = baseOrientation || motion.defaultOrientation;
		
		// This section was an attempt to guess an orientation velocity using
		// the 'accel' field created by some of the other controllers, but it
		// just seems to make the jittering worse.
		// TODO: make this feature work
		/*
		var useAccel = function(p) {
			if(!('accel' in p))
				return;
			
			var omega = p.velocity.cross(p.accel).
					div(p.velocity.lengthSquared());
			return (new util.Quaternion(omega.normal(), 1)).
					scale(omega.length());
		};
		this.oVelController = new motion.OrientationVel(presence, useAccel,
				period);
		*/
		
		var lookForward = function(p) {
			if(p.velocity.length() < 1e-8)
				return;
			
			return (util.Quaternion.fromLookAt(p.velocity, up)).
					mul(baseOrientation);
		};
		this._super(presence, lookForward, period);
	}
});

/* collision.em
 *
 * A library of standard collision functions for the generic Collision motion
 * controller
 *
 * Author: Will Monroe
 *
 * The typical usage of the Collision motion controller is
 *      new motion.Collision(presence, test, response);
 * test and response are functions called by Collision's machinery.  These two
 * callback functions will frequently fall into a few different general
 * categories that are implemented here to avoid code duplication.
 *
 * The coll module contains "metafunctions" -- themselves functions, but which
 * should not be passed directly into Collision; rather, when called with
 * certain arguments, they return a function that can be passed to Collision.
 * These arguments are used to customize the functions to meet different
 * requirements of the client.  For example:
 *      new motion.Collision(presence, coll.TestSpheres(otherVisibles),
 *              coll.Bounce(.8));
 * Be careful to always call the metafunctions, even when using all defaults
 * (when sometimes no parameters are necessary):
 *      new motion.Collision(presence, coll.TestSpheres(otherVisibles),
 *              coll.Bounce()); // not just ...coll.Bounce); !
 */


if(typeof(coll) === 'undefined')
    coll = {};

/* Standard test metafunctions
 * ---------------------------
 * Every test metafunction takes in some extra arguments and returns a
 * function that can be used in a Collision motion controller.  The function
 * that is returned takes one parameter, the presence to test, and returns a
 * collision object.  Collision objects contain these fields:
 *      self - the id of the presence that was being tested for collisions
 *      other - the id of the visible that self recently collided with
 *      normal - a vector pointing outwards from other, perpendicular to the
 *          surface of the collision
 *      impact - the difference in the velocities of the two bodies before
 *          collision (self.velocity - other.velocity)
 *      position - the (approximate) contact point of the two colliding bodies
 */

/**
 * @function TestSpheres(visibles)
 * @param visibles All other visibles to detect collisions against
 * @return A collision test function that tests the colliding presence (passed
 *      to the Collision motion controller) against the visibles listed in the
 *      parameter visibles using bounding spheres obtained from the scale
 *      field.  Collision normals, etc. are reported as if the presence and
 *      all visibles are spherical.
 */
coll.TestSpheres = function(visibles) {
    return function(presence) {
        for(v in visibles) {
            if(visibles[v].toString() === presence.toString())
                continue;
            
            var approach = presence.scale + visibles[v].scale;
            var disp = presence.position - visibles[v].position;
            if(disp.lengthSquared() < approach * approach &&
                    disp.dot(presence.velocity) <= 0) {
                var impact = approach - disp.length();
                var collision = {
                    self: presence.toString(),
                    other: visibles[v].toString(),
                    normal: disp.normal(),
                    impact: presence.velocity - visibles[v].velocity,
                    position: presence.position + disp.scale(presence.scale - impact / 2)
                };
                return collision;
            }
        }
    };
};

coll.TestSphereToPlanes = function(planes) {
    for(p in planes)
        p.mass = 0;
    
    return function(presence) {
        for(p in planes) {
            var disp = presence.position - planes[p].anchor;
            var distance = disp.dot(planes[p].normal);
            if(distance < presence.scale &&
                    planes[p].normal.dot(presence.velocity) <= 0) {
                var collision = {
                    self: presence.toString(),
                    other: planes[p],
                    normal: planes[p].normal,
                    impact: presence.velocity,
                    position: presence.position - planes[p].normal.scale(distance)
                };
                return collision;
            }
        }
    };
};

coll.TestBounds = function(upper, lower) {
    return coll.TestSphereToPlanes([
        {anchor: upper, normal: <-1, 0, 0>},
        {anchor: upper, normal: <0, -1, 0>},
        {anchor: upper, normal: <0, 0, -1>},
        {anchor: lower, normal: <1, 0, 0>},
        {anchor: lower, normal: <0, 1, 0>},
        {anchor: lower, normal: <0, 0, 1>}
    ]);
};

/* Standard callback metafunctions
 * -------------------------------
 * Callback metafunctions return functions that can be used as callbacks for
 * the Collision motion controller.  The metafunctions take arguments used
 * to customize the callback function that is returned, which in turn takes a
 * collision object (as defined above in "test metafunctions").
 */

/**
 * @function Stop()
 * @return A collision response function that stops the colliding presence at
 *      the point of collision.
 */
coll.Stop = function() {
    return function(presence, collision) {
        presence.velocity = <0, 0, 0>;
        presence.position = presence.position +
                collision.normal.scale(collision.impact);
    };
};

/**
 * @function Bounce(elast)
 * @param elast The elasticity of collisions.  For normal results, this should
 *      be a number between 0 and 1, inclusive.
 * @return A collision response function that bounces the colliding object off
 *      the other object at an equal angle, multiplying its velocity by the
 *      given elasticity.
 */
coll.Bounce = function(elast) {
    if(typeof(elast) === 'undefined')
        elast = 1;
    
    function mass(p) {
        if(typeof(p) === 'string')
            p = system.createVisible(p);
        
        if('mass' in p)
            return p.mass;
        else if('physics' in p && 'mass' in p.physics)
            return p.physics.mass;
        else
            return 1;
    }

    return function(presence, collision) {
        if(typeof(collision.other) === 'string')
            var vel = system.createVisible(collision.other).velocity;
        else
            var vel = <0, 0, 0>;
        
        if(collision.normal.dot(presence.velocity - vel) >= 0 ||
                mass(collision.self) == 0)
            return;
        
        if(mass(collision.other) == 0)
            var massFactor = 1;
        else
            var massFactor = mass(collision.other) / (mass(collision.self) +
                    mass(collision.other));

        presence.velocity = presence.velocity +
                collision.normal.scale((1 + elast) * massFactor *
                collision.normal.dot(collision.impact));
    };
};

var table;
var cue;
var balls = [];

var ballMesh = 'meerkat:///emily2e/models/earth.dae/optimized/0/earth.dae';
var tableMesh = 'meerkat:///wmonroe4/billiard_table.dae/optimized/0/billiard_table.dae';

var NUM_BILLIARD_BALLS = 2;
var TABLE_SCALE = 8.4;
var BALL_SCALE = 0.16;
var TABLE_OFFSET = TABLE_SCALE * 0.2; 
var TABLE_LENGTH = 0.74 * TABLE_SCALE;
var TABLE_WIDTH = 0.45 * TABLE_SCALE;
var TABLE_BOUNDS = {
    max: <TABLE_LENGTH, TABLE_OFFSET + 0.5, TABLE_WIDTH>,
    min: <-TABLE_LENGTH, TABLE_OFFSET - 0.5, -TABLE_WIDTH>
};
var CUE_OFFSET = 3;
var CUE_VELOCITY = 3;
var ELASTICITY = 0.8;

function onTableCreated(pres) {
    table = pres;
    table.scale = TABLE_SCALE; 

    for(var i = 0; i < NUM_BILLIARD_BALLS; i++) {
        system.createPresence(ballMesh, onBallCreated);
    }
}

function onBallCreated(pres) {
    balls.push(pres);
    pres.scale = BALL_SCALE;
    pres.position = table.position + <-3 * BALL_SCALE * balls.length, TABLE_OFFSET, 0>;
    if(table && balls.length == NUM_BILLIARD_BALLS)
        system.createPresence(ballMesh, onCueCreated);
}

function onCueCreated(pres) {
    cue = pres;
    balls.push(cue);
    cue.scale = BALL_SCALE;
    cue.position = table.position + <CUE_OFFSET, TABLE_OFFSET, 0>;
    cue.coll = new motion.Collision(cue, coll.TestSpheres(balls),
            coll.Bounce(ELASTICITY));
//    cue.bounds = new motion.Collision(cue,
//            coll.TestBounds(table.position + TABLE_BOUNDS.max,
//                    table.position + TABLE_BOUNDS.min), 
//            coll.Bounce(ELASTICITY));

    for(var i in balls)
    {
        balls[i].coll = new motion.Collision(balls[i], coll.TestSpheres(balls),
                coll.Bounce(ELASTICITY));
//        balls[i].bounds = new motion.Collision(balls[i],
//                coll.TestBounds(table.position + TABLE_BOUNDS.max, 
//                        table.position + TABLE_BOUNDS.min),
//                coll.Bounce(ELASTICITY));
    }
}

function hitCue() {
    cue.velocity = <-CUE_VELOCITY, 0, 0>;
}

system.createPresence(tableMesh, onTableCreated);

