var table;
var cue;
var balls = [];

var ballMesh = 'meerkat:///emily2e/models/earth.dae/optimized/0/earth.dae';
var tableMesh = 'meerkat:///wmonroe4/billiard_table.dae/optimized/0/billiard_table.dae';

var NUM_ROWS = 4;
var NUM_BILLIARD_BALLS = 10;
var TABLE_SCALE = 8.4;
var BALL_SCALE = 0.16;
var TABLE_OFFSET = TABLE_SCALE * 0.2; 
var CUE_OFFSET = 3;
var CUE_VELOCITY = 3;

function onTableCreated(pres) {
    table = pres;
    table.scale = TABLE_SCALE; 
    table.physics = {
        treatment: 'static',
        bounds: 'triangles'
    };

    var DELTA = 3 * BALL_SCALE;

    for(var row = 0; row < NUM_ROWS; row++) {
        for(var ball = 0; ball < row + 1; ball++) {
            var position = table.position + <-DELTA * row, TABLE_OFFSET,
                    DELTA * (ball - row / 2)>;
            system.createPresence(ballMesh, onBallCreated(position));
        }
    }
}

function onBallCreated(position) {
    return function(pres) {
        balls.push(pres);
        pres.scale = BALL_SCALE;
        pres.position = position;
        if(table && balls.length == NUM_BILLIARD_BALLS)
            system.createPresence(ballMesh, onCueCreated);
    }
}

function onCueCreated(pres) {
    cue = pres;
    balls.push(cue);
    cue.scale = BALL_SCALE;
    cue.position = table.position + <CUE_OFFSET, TABLE_OFFSET, 0>;
    cue.physics = {
        treatment: 'dynamic',
        bounds: 'sphere',
        mass: 1
    };

    for(var i in balls)
        balls[i].physics = cue.physics;
}

function hitCue() {
    cue.physics = {treatment: 'ignore'}; 
    cue.velocity = <-CUE_VELOCITY, 0, 0>;
    cue.physics = {treatment: 'dynamic'}; 
}

system.createPresence(tableMesh, onTableCreated);

