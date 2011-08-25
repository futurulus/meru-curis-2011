var collision;

var cue;
var ball;

var ballMesh = 'meerkat:///emily2e/models/earth.dae/optimized/0/earth.dae';

function onBallCreated(pres) {
    ball = pres;
    system.createPresence(ballMesh, onCueCreated);
}

function onCueCreated(pres) {
    cue = pres;
    collision = {
        self: cue,
        other: ball,
        normal: <0, 1, 0>,
        position: cue.position + <1, 0, 1>
    };
}

system.createPresence(ballMesh, onBallCreated);

