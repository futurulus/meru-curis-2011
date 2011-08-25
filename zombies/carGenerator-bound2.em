/*
 * File: carGenerator.em
 * created by G1
 * ---------------------
 * Given a graph object of a street system, lets a car loose on the road.
 * The car obeys appropriate traffic rules specific to a street block.
 * 
 * Usage:
 *      system.import(<streetGenerator.em file here>);
 *      var street = createStreet(<appropriate parameters here>);
 *      system.import(<carGenerator.em file here>);
 *      for(var i = 0; i < <# cars to be created>; i++) createCar(street);
 *
 */

system.require("std/shim/quaternion.em");
system.require("std/movement/units.em");
system.require("std/shim/bbox.em");
system.require("std/core/queryDistance.em");
system.require("std/movement/motion.em");
system.import("test/hatchetGenerator.em");

/*
 * When called, stops the rotation of the presence passed in as a parameter
 */
function stopRotation(presence) {
    presence.orientationVel = new util.Quaternion();
}

/*
 * This function lets the presence passed in as a parameter gradually face
 * its target direction by rotating at a specified rate instead of jumping
 * to face the target direction.
 *
 * @param presence The presence that is to rotate
 * @param oldDirectionVec The direction vector for the presence's current
 *			orientation
 * @param targetDirectionVec The direction vector for the presences's target
 *			orientation
 * @param rotationPeriod The total amount of time it will take for the
 * 			presence to make a 360-degree rotation
 */
function rotate(presence, oldDirectionVec, targetDirectionVec, rotationPeriod) {
    var cross = targetDirectionVec.cross(oldDirectionVec);
    var theta = Math.acos( targetDirectionVec.dot(oldDirectionVec)/(targetDirectionVec.length()*oldDirectionVec.length()) );
    var time = theta/(2*Math.PI/rotationPeriod);
    if(cross.y > 0) { // clockwise
        presence.orientationVel = (new util.Quaternion(<0,-1,0>,1)).scale(2*Math.PI/rotationPeriod);
    } else { // counter-clockwise
        presence.orientationVel = (new util.Quaternion(<0,1,0>,1)).scale(2*Math.PI/rotationPeriod);
    }
    system.timeout(time, function() {
        stopRotation(presence);
    });
}

/*
 * Given the current edge the car is traveling through and the index of the node
 * the car is traveling towards, selects the next edge and node for the car.
 */
function selectNextEdge(index, edge) {

    // If there is only one edge connected to the node the car is traveling to,
    // then it means that the road is not through. So by returning the current
    // edge as the next edge, the car takes a u-turn.
    if(edge.nodes[index].edges.length == 1) {
        return edge;   
    }
    
    // Else, creates an array of edges radiating from the target node that does not
    // include the current node, so that a new edge can be randomly selected.
    var viableEdges = [];
    for(var i = 0; i < edge.nodes[index].edges.length; i++) {
        if(edge.nodes[index].edges[i] == edge) continue;
        viableEdges.push(edge.nodes[index].edges[i]);
    }
    
    // If there is more than one edge connected to the node, but there are no viable
    // edges other than the current edge, that means the the only other edge is blocked.
    // Thus car makes a u-turn.
    if(viableEdges.length == 0) return edge;
    
    // Otherwise, selects randomly from the viable edges array
    else return viableEdges[Math.floor(Math.random()*viableEdges.length)];
}

/*
 * Given the current target node and the next edge the car will be traveling on,
 * returns the next target node by checking in with the current target node and
 * making sure that it isn't the one that is being returned.
 */
function selectNextIndex(index, currEdge, nextEdge) {
    if(nextEdge.nodes[0] == currEdge.nodes[index]) return 1;
    return 0;
}

/*
 * Given two nodes, returns the vector resulting from subtracting the position of
 * the second node from that of the first.
 */
function diffVec(nextNode, prevNode) {
    var x = nextNode.position.x - prevNode.position.x;
    var y = nextNode.position.y - prevNode.position.y;
    var z = nextNode.position.z - prevNode.position.z;
    var diff = <x,y,z>;
    return diff;
}

function getScaleArray(steps) {
    var result = [];
    var step = Math.cos(0.25*Math.PI)/steps;
    for(var i = 0; i < steps; i++) {
        var first = step*i;
        var second = Math.sqrt(1-(first*first));
        system.__debugPrint("\n\n first: "+first+" second: "+second);
        result.push({first:first,second:second});
    }
    for(var i = result.length-1; i >= 0; i--) {
        var second = result[i].first;
        var first = Math.sqrt(1-(second*second));
        system.__debugPrint("\n\n first: "+first+" second: "+second);
        result.push({first:first,second:second});
    }
    result.shift();
    return result;
}

function turn(car, index, edge, nextIndex, nextEdge, speed, scaleArr) {
    function recurseTurn(car, circle, scaleArr) {
        if(circle.length == 0) {
            recurseDrive(nextIndex, nextEdge, car, scaleArr);
            return;
        }

        var target = circle.shift();
        target.y = car.position.y;
        var diff = target - car.position;
        var vel = diff.scale(speed/diff.length());
        car.velocity = vel;
        car.orientation = util.Quaternion.fromLookAt(vel);
        
        system.timeout(diff.length()/vel.length(), function() {
            recurseTurn(car, circle, scaleArr);
        });
    }

    var r = edge.directions[index].length()*0.2;
    var nodeA = edge.nodes[(index+1)%2].position + edge.directions[index].scale(0.8);
    var first = edge.directions[index].scale(0.2);
    var second = nextEdge.directions[nextIndex].scale(0.2);
    
    var circle = [];
    for(var i = 0; i < scaleArr.length; i++) {
        circle.push(nodeA + first.scale(scaleArr[i].first) + second.scale(1-scaleArr[i].second));
    }
    
    recurseTurn(car, circle, scaleArr);
}

/*
 * Returns the direction the car will turn in at the next intersection
 */
function getTurn(currDir, currNode, nextNode) {
    var nextDir = diffVec(nextNode, currNode);
    var theta = Math.acos(nextDir.dot(currDir)/(nextDir.length()*currDir.length()));
    
    if(theta < 0.1*Math.PI) return "straight";
    if(theta > 0.9*Math.PI) return "u";

    var cross = nextDir.cross(currDir);
    if(cross.y > 0) { // clockwise
        return "right";
    }
    return "left";
}

/*
 * Given the target node it is driving towards, this function sets the correct
 * velocity and orientation for the car. Then the next target node to travel
 * towards is selected and a recursive call is made so that the car would orient
 * itself correctly after it has finished traveling to the current target node.
 */
function recurseDrive(index, edge, car, scaleArr) {
    if(car.velocity.length > 0) var currDirectionVec = car.velocity;
    else var currDirectionVec = (system.self.orientation).mul(<0,0,-1>);
    
    var multiplier = 0.5;
    var dx = edge.nodes[index].position.x - car.position.x;
    var dy = 0;
    var dz = edge.nodes[index].position.z - car.position.z;
    var diff = <dx, dy, dz>;
    var vel = <dx*multiplier, dy*multiplier, dz*multiplier>;
    car.velocity = vel;

    var nextEdge = selectNextEdge(index, edge);
    var nextIndex = selectNextIndex(index, edge, nextEdge);
    var nextTurn = getTurn(edge.directions[index], edge.nodes[index], nextEdge.nodes[nextIndex]);
    
    if(nextTurn == "left" || nextTurn == "right") {
        system.timeout(diff.length()*0.7/vel.length(), function() {
            turn(car, index, edge, nextIndex, nextEdge, vel.length(), scaleArr);
        });
    } else {
        system.timeout(diff.length()/vel.length(), function() {
            recurseDrive(nextIndex, nextEdge, car, scaleArr);
        });
    }
}

function carFactory(carobj, gph, sp, ctrlr) {
    return function(presence) {
        var target = null;
        var graph = gph;
        var space = sp;
        var car = presence;
        var controller = ctrlr;
        var inSinc = false;
        var scaleArr = getScaleArray(5);
        
        function proxAdded(prox) {
            if(prox.mesh.indexOf("zombie") != -1) {
                system.__debugPrint("\nHas encountered a zombie!\n");
                //throwHatchet(car.position, prox.position);
                target = prox;
            }
        }
        
        function followCar() {
            if(!inSinc) return;
            controller.orientation = presence.orientation;
            controller.position = presence.position + presence.orientation.mul(<0, 1.5*presence.scale, 4*presence.scale>);
            controller.velocity = presence.velocity;
            system.timeout(0.07, followCar);
        }
        
        function addKeyBindings() {
            system.__debugPrint("\nIn createPresence callback...");
            
            simulator._binding.addAction('startCar', function() {
                recurseDrive(1, graph.edges[0], car, scaleArr);
            });
            
            var moveCarFBinding =  [{ key: ['button-pressed', 'u' ], action:'startCar' } ];
            simulator._binding.addBindings(moveCarFBinding);
            
            // sinc controller and car so that they face same direction
            simulator._binding.addAction('sincCar', function() {
                inSinc = true;
                controller.mesh = "";
                followCar();
            });
            
            var sincCarBinding = [{ key: ['button-pressed', 'j' ], action:'sincCar' }];
            simulator._binding.addBindings(sincCarBinding);
            
            // stop controller-car sinc
            simulator._binding.addAction('stopSinc', function() {
                controller.velocity = <0,0,0>;
                inSinc = false;
            });
            
            var stopSincBinding = [{key:['button-pressed','k' ],action:'stopSinc'}];
            simulator._binding.addBindings(stopSincBinding);
            
            // throw hatchet
            simulator._binding.addAction('hatchet',function() {
                system.__debugPrint("\nAction hatchet was called!");
                if(target == null) {
                    system.__debugPrint("\nThere is no target, so returning...");
                    return;
                }
                if((target.position-car.position).length() < 10) {
                    system.__debugPrint("\nzombie in range, so shooting hatchet...");
                    throwHatchet(car.position, target.position);
                }
                system.__debugPrint("\nzombie NOT in range");
            });
            
            var hatchetBinding = [{key:['button-pressed','h'],action:'hatchet'}];
            simulator._binding.addBindings(hatchetBinding);
            
        }
        
        presence.loadMesh(function() {
            var bb = presence.untransformedMeshBounds().across();
            system.__debugPrint("\nCreating car...");
            system.__debugPrint("\nBounding box of car is " + bb + "\n");
            presence.scale = space*0.06;
            presence.position = <graph.nodes[0].position.x, graph.nodes[0].position.y, graph.nodes[0].position.z>;
            presence.position = presence.position + <0,space*0.005+space*0.06*bb.y/2,0>;
            presence.orientation = util.Quaternion.fromLookAt(graph.nodes[0].edges[0].directions[1]);
            controller.mesh = "";
            presence.onProxAdded(proxAdded,true);
            presence.setQueryAngle(0.05);
            // test
            var proxSet = system.getProxSet(car);
            for(var i = 0; i < proxSet.length; i++) {
                if(proxSet[i].mesh.indexOf("zombie") != -1) system.__debugPrint("\nZombie already in proxSet!");
            } //
        });
        
        addKeyBindings();
    }
}

/*
 * Given a graph representation of a system of streets to travel on, this function
 * creates a car and lets it loose on the road. A random mesh for the car is picked
 * from the carmeshes array.
 */
function createCar(graph, space, controller){
    if(graph.nodes.length == 0 || graph.edges.length == 0) {
        system.__debugPrint("\nError: street is an empty or malformed graph");
        return;
    }
    
    var setUpCar = carFactory("meerkat:///kittyvision/car/sweet.dae/optimized/0/sweet.dae", graph, space, controller);
    system.createPresence("meerkat:///kittyvision/car/sweet.dae/optimized/0/sweet.dae", setUpCar);
}