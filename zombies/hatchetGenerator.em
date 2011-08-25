system.require("std/shim/quaternion.em");
system.require("std/movement/motion.em");

var N_HATCHETS = 4;
var HATCHET_GROUND_SPEED = 7;
var hatchets = [];

function pickHatchet() {
    system.__debugPrint("\nPicking a hatchet...");
    for(var i = 0; i < N_HATCHETS; i++) {
        system.__debugPrint("\n >> Looking at hatchets["+i+"]");
        if(hatchets[i].scale == 0) {
            system.__debugPrint("\n >> Has picked hatchets["+i+"]");
            return hatchets[i];
        }
    }
    system.__debugPrint("\n >> No hatchets availble!");
    return null;
}

function loadHatchet(ipos, dir) {
    system.__debugPrint("\nLoading hatchet..");
    var hatchet = pickHatchet();
    if(hatchet == null) return null;
    hatchet.scale = 0.5;
    hatchet.velocity = <0,0,0>;
    hatchet.position = ipos;
    hatchet.orientation = util.Quaternion.fromLookAt(dir);
    return hatchet;
}

function throwHatchet(carPos, zombiePos) {
    system.__debugPrint("\nThrowing hatchet...");
    var diff = zombiePos - carPos;
    var hatchet = loadHatchet(carPos, diff);
    if(hatchet == null) return;
    
    var vel = diff.scale(HATCHET_GROUND_SPEED/diff.length());
    vel.y += 0.5*motion.defaultGravity*diff.length()/vel.length();
    hatchet.velocity = vel;
    hatchet.controller.reset();
    
    system.timeout(diff.length()/HATCHET_GROUND_SPEED, function() {
        hatchet.velocity = <0,0,0>;
        hatchet.scale = 0;
        hatchet.controller.suspend();
    });
}

function initHatchets() {
    system.__debugPrint("\nInitializing hatchets...\n");
    for(var i = 0; i < N_HATCHETS; i++) {
        system.createPresence("meerkat:///kittyvision/axe.dae/optimized/axe.dae", function(presence) {
            function killZombie(hit) {
                system.__debugPrint("\nHatchet hit something!");
                if(hit.mesh.indexOf("zombie") != -1) {
                    system.__debugPrint("\nHas killed zombie!");
                    hit.scale = 0;
                }
            }
            presence.scale = 0;
            hatchets.push(presence);
            presence.controller = new motion.Gravity(presence);
            presence.controller.suspend();
            
            presence.onProxAdded(killZombie, true);
            presence.setQueryAngle(1);
            var proxSet = system.getProxSet(presence);
            for(var i = 0; i < proxSet.length; i++) {
                system.__debugPrint("\n"+proxSet[i].mesh+" is already in proxSet");
            }
        });
    }
}

initHatchets();