	system.self.mesh = "meerkat:///emily2e/models/earth.dae/optimized/0/earth.dae";
	system.print("\n\nThe leader is " + system.presences[0].toString() + "\n\n");
	
	var leader = system.presences[0];
	var leaderMesh = leader.getMesh();
	var leaderPos = leader.getPosition();
	var flock = [leader];

	function addToFlock(object) {
		system.print("\nObject in proximity: ");
		system.print(object.toString());
		
		if(leaderMesh == object.getMesh()) {
			system.print("\nALSO r2d2");
		} else {
			system.print("\nNOT r2d2");
		}
	}

	for(var i=0; i<10; i++) {
		system.create_presence(leaderMesh, function(presence) {
			var MAX_DISTANCE = 4;
			flock.push(presence);
			
			/*
			 * Generates and returns a semi-random starting position for the presence
			 */
			function getInitialPos(centerPos) {
				return <centerPos.x+2*(Math.random()+0.5), centerPos.y, centerPos.z-2*(Math.random()+0.5)>;
			}
		
			/*
			 * Returns the distance between the two positions
			 */
			function distance(pos1, pos2) {
				return (pos1 - pos2).length();
			}
			
			/*
			 * If the direction of newVel is opposite the central direction,
			 * adjust so that the presence is traveling in the general direction of
			 * the leader.
			 */
			function adjust(newVel, x, y, z) {
				var adjusted = newVel;
				if(newVel.x * x < 0) {
					adjusted.x = -newVel.x;
				}
				if(newVel.y * y < 0) {
					adjusted.y = -newVel.y;
				}
				if(newVel.z * z < 0) {
					adjusted.z = -newVel.z;
				}
				return adjusted;
			}
		
			/*
			 * Creates a random velocity (not a vector)
			 * and returns it
			 */
			function randomVel() {
				var v = Math.random();
				if(v<0.5) {
					v = -(Math.random());
				} else {
					v = Math.random();
				}
				return v;
			}
			
			/*
			 * (1) Creates a random velocity vector
			 * (2) If presence is farther than MAX_DISTANCE away from central position,
			 *	   adjust the velocity vector so that it points in the general direction
			 *     of the leader
			 * (3) Set the presence's velocity to the new vector
			 * (4) Make a randomly-timed recursive call to simulate random behavior
			 */
			 
			function go(centerPos) {
				var x = randomVel();
				var y = randomVel();
				var z = randomVel();
				var newVel = <x,y,z>;
			
				var selfPos = presence.position;
				
				if(distance(leaderPos, selfPos) > MAX_DISTANCE) {
					newVel = adjust(newVel, leaderPos.x - selfPos.x, leaderPos.y - selfPos.y, leaderPos.z - selfPos.z);
				}
				
				system.self.setVelocity(newVel);
				system.timeout(4*(Math.random()+0.5),function() {
									go(centerPos);
								});
				
			}
			
			var newPos = getInitialPos(leaderPos);
			presence.setPosition(newPos);
			presence.scale = 0.1 + i * 0.1;
			go(leaderPos);
		});
	}
	
	//leader.onProxAdded(addToFlock);
	//leader.setQueryAngle(.7);

