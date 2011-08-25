var pilotAvatar = function() {
    system.require('std/movement/units.em');
    system.require('std/movement/motion.em');
    system.require('std/movement/collision.em');

    var refereeID = '###'; // this gets replaced by a presence UUID automatically
    if(refereeID == '##' + '#') {
        // the hashes didn't get replaced, so there probably is no referee
        system.print('Warning: trying to run pilot script from outside a soccer game!');
        refereeID = system.self.toString();
    }

    var GAME = 'soccer';
    var ballVis = null;
    var canCatch = true;
    var canThrow = false;
    var colliders = [];
    var collDetection = null;
    var SPEED = 5 * u.m / u.s;
    var BRAKE = 2.5 * u.m / u.s;
    var CATCH_DELAY = 0.5 * u.s; // amount of time after throwing that you don't try to catch again

    function addRotateBinding(direction, key) {
        simulator._binding.addToggleAction(GAME + '.' + direction,
                                           function(on) { rotate(direction, on); },
                                           true, false);
        simulator._binding.addBinding(['button', key], GAME + '.' + direction);
    }

    addRotateBinding('left', 'f');
    addRotateBinding('right', 'h');
    addRotateBinding('up', 't');
    addRotateBinding('down', 'g');
    addRotateBinding('rollLeft', 'r');
    addRotateBinding('rollRight', 'y');

    simulator._binding.addToggleAction(GAME + '.brake',
                                       std.core.bind(simulator.moveSelf,
                                                     simulator,
                                                     <0, 0, 1>),
                                       BRAKE / simulator.defaultVelocityScaling,
                                       -BRAKE / simulator.defaultVelocityScaling);
    simulator._binding.addBinding(['button', 'b'], GAME + '.brake');

    simulator._binding.addAction(GAME + '.throw', throwBall);
    simulator._binding.addBinding(['button-pressed', 'space'], GAME + '.throw');

    function rotate(direction, on) {
        rotations[direction].on = on;

        var angVel = <0, 0, 0>;
        for(var dir in rotations) {
            if(rotations[dir].on)
                angVel += rotations[dir].axis;
        }

        setOrientationVel(<angVel.normal(); angVel.length()>);
    }

    function setOrientationVel(v) {
        simulator._moverot.rotateLocalOrientation(v, true);
    }

    var rotations = {
        left: { axis: <0, 1, 0>, on: false },
        right: { axis: <0, -1, 0>, on: false },
        up: { axis: <1, 0, 0>, on: false },
        down: { axis: <-1, 0, 0>, on: false },
        rollLeft: { axis: <0, 0, 1>, on: false },
        rollRight: { axis: <0, 0, -1>, on: false }
    };

    system.self.mesh = 'meerkat:///gabrielle/models/spaceship.dae/optimized/spaceship.dae';
    system.self.scale = 2;
    system.self.modelOrientation = <0, 1, 0; Math.PI / 2>;
    simulator.moveSelf(<0, 0, -1>, SPEED / simulator.defaultVelocityScaling, true);
    simulator._camera.setMode('third')
    simulator.updateCameraOffset();

    function onJoin(msg, sender) {
        if(!('ball' in msg)) {
            system.__debugPrint('"ball" not found in reply to soccer join message -- aborting');
            return;
        }

        ballVis = system.createVisible(msg.ball);
        colliders.push(ballVis);
        if(msg.players) {
            for(var id in msg.players)
                colliders.push(system.createVisible(id));
        }
        collDetection = new motion.Collision(system.self, coll.TestSpheres(colliders),
                                             onSoccerCollision);
    };

    function onSoccerCollision(self, collision) {
        if(collision.other.id != ballVis.toString())
            return;

        if(canCatch)
            {soccer: 'catch'} >> system.createVisible(refereeID) >> [onCatch];
    };

    function onCatch(msg, sender) {
        canCatch = false;
        canThrow = true;
    };

    function throwBall() {
        if(canThrow)
            {
                soccer: 'throw',
                direction: system.self.orientation * <0, 0, -1>
            } >> system.createVisible(refereeID) >> [onThrow];
    };

    function onThrow(msg, sender) {
        canThrow = false;
        system.timeout(CATCH_DELAY, function() {
            canCatch = true;
        });
    };

    {soccer: 'join'} >> system.createVisible(refereeID) >> [onJoin];
};