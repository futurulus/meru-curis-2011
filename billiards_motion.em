runBilliards = function() {

     system.require('std/movement/motion.em');
     system.require('std/movement/collision.em');

     var table;
     var cue;

     var balls = [];
     var ballIDs = {};
     var stopped = [];
     var pockets = [];
     var pocketIDs = {};

     var NUM_ROWS = 3;
     var NUM_BILLIARD_BALLS = 6;

     var ballMeshes = [];
     for(var i = 1; i <= NUM_BILLIARD_BALLS + 1; i++) {
	 if(i == 6)
	     continue;

	 ballMeshes.push('meerkat:///wmonroe4/' + i + 'ball.dae/optimized/0/' +
			 i + 'ball.dae');
     }
     var cueBallMesh = 'meerkat:///wmonroe4/cueball.dae/optimized/0/cueball.dae';
     var tableMesh = 'meerkat:///wmonroe4/billiard_table.dae/optimized/0/billiard_table.dae';

     var TABLE_SCALE = 8.4;
     var BALL_SCALE = 0.16;
     var TABLE_OFFSET = TABLE_SCALE * 0.2;
     var TABLE_LENGTH = 0.74 * TABLE_SCALE;
     var TABLE_WIDTH = 0.45 * TABLE_SCALE;
     var TABLE_BOUNDS = {
         max: <TABLE_LENGTH, TABLE_OFFSET + 0.5, TABLE_WIDTH>,
         min: <-TABLE_LENGTH, TABLE_OFFSET - 0.5, -TABLE_WIDTH>
     };
     var DELTA = 2.5 * BALL_SCALE;
     var POCKET_ROW_DELTA = <TABLE_LENGTH, 0, 0>;
     var POCKET_COL_DELTA = <0, 0, TABLE_WIDTH>;
     var POCKET_SCALE = 0.03 * TABLE_SCALE;
     var SIDE_POCKET_DELTA = <0, 0, BALL_SCALE>;
     var NUM_POCKETS = 6;
     var CUE_OFFSET = 0.3 * TABLE_SCALE;
     var CUE_VELOCITY_FACTOR = 0.5;
     var ELASTICITY = 0.8;
     var FRICTION = 0.4;
     var ROLLING_FRICTION = 0.000;
     var DEFAULT_QUERY_ANGLE = 0.001;

     frictionController = motion.ForceTorque.extend({
         init: function(presence, coefficient, period) {
             var radial = <0, -presence.scale, 0>;

             var posFn = function(p) {
                 return p.position + radial;
             };
             var forceFn = function(p) {
                 var angVel = p.orientationVel.axis().scale(p.orientationVel.length());
                 // transform to world coordinates
                 angVel = p.orientation.mul(angVel);
                 var tangVel = p.velocity - radial.cross(angVel);
                 if(tangVel.length() < 1e-08)
                     return <0, 0, 0>;

                 return tangVel.scale(-coefficient * motion.util.mass(p) *
                         motion.defaultGravity / Math.max(tangVel.length(), 1));
             };
             this._super(presence, forceFn, posFn, period);
         }
     });

     function debugPrintStopped() {
         var status = '';
         for(var i in stopped) {
             if(stopped[i] == 'pocketed')
                 status += 'O';
             else if(stopped[i])
                 status += '.';
             else
                 status += '>';
         }

         //system.__debugPrint(status + '\n');
     }

     function onMovementStopped() {
         system.__debugPrint('all motion stopped\n');
     }

     function allBallsStopped() {
         for(var i in stopped)
             if(!stopped[i])
                 return false;

         return true;
     }

     function getBallNumber(pres) {
         var num = parseInt(pres.mesh.slice(pres.mesh.lastIndexOf('/') + 1,
                                            pres.mesh.lastIndexOf('ball')));
         if(isNaN(num)) {
             system.__debugPrint('couldn\'t recognize ball: \n' +
                                 pres.mesh);
             return 0;
         }

         return num;
     }

     function stopBall(pres) {
         if(!stopped[ballIDs[pres.toString()]]) {
             stopped[ballIDs[pres.toString()]] = true;
             debugPrintStopped();
             if(allBallsStopped())
                 onMovementStopped();
         }
         pres.orientationVel = <0, 0, 0, 0>;
         pres.velocity = <0, 0, 0>;
     }

     function rollingVelFn(pres) {
         if(pres.velocity.lengthSquared() <
                 ROLLING_FRICTION * ROLLING_FRICTION) {
             stopBall(pres);
             return <0, 0, 0>;
         }

         return pres.velocity - pres.velocity.normal() * ROLLING_FRICTION;
     }

     function onBallPocketed(num) {
         system.__debugPrint('ball ' + num + ' pocketed\n');
     }

     function pocketEndResponse(pres, evt) {
         if(!('plane' in evt.other) || evt.other.plane.normal.y < 0.5)
             return;

         ballNumber = ballIDs[pres.toString()];
         pres.mesh = 'meerkat:///elliotconte/models/DSTARIN.dae/optimized/DSTARIN.dae';
         pres.gravity.suspend();
         pres.coll.suspend();
         pres.pockets.suspend();
         pres.velocity = <0, 0, 0>;
         pres.position = table.position;

         onBallPocketed(ballNumber);
         stopBall(pres);
         stopped[ballNumber] = 'pocketed';
     }

     function pocketStartResponse(pres, evt) {
         if(pres.bounds.isSuspended() ||
                 !(evt.other.id in pocketIDs))
             return;

         pres.friction.suspend();
         pres.bounds.suspend();
         pres.pockets.suspend();
         pres.gravity = new motion.Gravity(pres);
         pres.pockets = new motion.Collision(pres, coll.TestSphereToPlanes([{
                     anchor: table.position + TABLE_BOUNDS.min,
                     normal: <0, 1, 0>
                 }]), pocketEndResponse);
     }

     function billiardsBounce(pres, evt) {
         if(!(evt.other.id in ballIDs))
             return;

         system.__debugPrint('bounce! ' + ballIDs[pres.toString()] + '->' +
                             ballIDs[evt.other.id] + '\n');

         coll.Bounce(ELASTICITY)(pres, evt);
         stopped[ballIDs[evt.other.id]] = false;
         stopped[ballIDs[pres.toString()]] = false;
         debugPrintStopped();
     }

     function onTableCreated(pres) {
         table = pres;
         table.orientation = new util.Quaternion();
         table.scale = TABLE_SCALE;
         var DELTA = 2.1 * BALL_SCALE;

         for(i = -1; i <= 1; i++) {
             for(var j = -1; j <= 1; j += 2) {
                 var position = table.position + <0, TABLE_OFFSET, 0> +
                         POCKET_ROW_DELTA.scale(i) + POCKET_COL_DELTA.scale(j);
                 if(i == 0)
                     position = position + SIDE_POCKET_DELTA.scale(j);
                 system.createPresence('', onPocketCreated(position));
             }
         }

     }

     function onPocketCreated(pocketPos) {
         return function(pres) {
             pres.position = pocketPos;
             pres.scale = POCKET_SCALE;
             pockets.push(pres);
             pocketIDs[pres.toString()] = true;
             if(pockets.length == NUM_POCKETS) {
                 var i = 0;

                 for(var row = 0; row < NUM_ROWS; row++) {
                     for(var ball = 0; ball < row + 1; ball++) {
                         var ballPos = table.position + <-DELTA * row, TABLE_OFFSET,
                                                          DELTA * (ball - row / 2)>;
                         system.createPresence(ballMeshes[i], onBallCreated(ballPos));
		         i++;
                     }
                 }
             }
         };
     }

     function onBallCreated(position) {
         return function(pres) {
             balls.push(pres);
             ballIDs[pres.toString()] = getBallNumber(pres);
             stopped.push(true);
             pres.scale = BALL_SCALE;
             pres.position = position;
             pres.queryAngle = DEFAULT_QUERY_ANGLE;
             if(balls.length == NUM_BILLIARD_BALLS &&
                pockets.length == NUM_POCKETS)
                 system.createPresence(cueBallMesh, onCueCreated);
         };
     }

     function onCueCreated(pres) {
         cue = pres;
         balls.push(cue);
         ballIDs[cue.toString()] = 0;
         stopped.push(true);
         cue.scale = BALL_SCALE;
         cue.position = table.position + <CUE_OFFSET, TABLE_OFFSET, 0>;
         cue.queryAngle = DEFAULT_QUERY_ANGLE;

         for(var i in balls)
         {
             balls[i].coll = new motion.Collision(balls[i],
                     coll.TestSpheres(balls), billiardsBounce,
                     motion.defaultPeriod * (Math.random() + 0.5));
             balls[i].bounds = new motion.Collision(balls[i],
                     coll.TestBounds(table.position + TABLE_BOUNDS.max,
                                     table.position + TABLE_BOUNDS.min),
                     coll.Bounce(ELASTICITY),
                     motion.defaultPeriod * (Math.random() + 0.5));
             balls[i].friction = new frictionController(balls[i], FRICTION,
                     motion.defaultPeriod * (Math.random() + 0.5));
             balls[i].pockets = new motion.Collision(balls[i],
                     coll.TestSpheres(pockets), pocketStartResponse,
                     motion.defaultPeriod * (Math.random() + 0.5));
             balls[i].rolling = new motion.Velocity(balls[i], rollingVelFn,
                     motion.defaultPeriod * (Math.random() + 0.5));
         }
     }

     function hitCue(msg, sender) {
         disp = cue.position - sender.getPosition();
         disp.y = 0;
         cue.velocity = disp * CUE_VELOCITY_FACTOR;
         stopped[0] = false;
         debugPrintStopped();
     }

     hitCue << [{'action':'touch':}];

     system.createPresence(tableMesh, onTableCreated);

};