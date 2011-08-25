var cycle;
function onPresenceConnected(presence) {
    cycle = presence;
    onCycleCreated();

    cycle.orientation = new util.Quaternion();
    cycle.modelOrientation = (new util.Quaternion(<0, 1, 0>, Math.PI / 2)).mul(
            new util.Quaternion(<0, 0, 1>, -0.08));
}
system.onPresenceConnected(onPresenceConnected);

function stop() {
    cycle.velocity = <0, 0, 0>;
}
stop << {'action':'stop':};

function start() {
    cycle.velocity = cycle.orientation.mul(<0, 0, -5>);
}
start << {'action':'start':};

var left = new util.Quaternion(<0, 1, 0>, Math.PI / 2);
var right = new util.Quaternion(<0, -1, 0>, Math.PI / 2);

function turnLeft() {
    cycle.orientation = cycle.orientation.mul(left);
    cycle.velocity = left.mul(cycle.velocity);
}
turnLeft << {'action':'left':};

function turnRight() {
    cycle.orientation = cycle.orientation.mul(right);
    cycle.velocity = right.mul(cycle.velocity);
}
turnRight << {'action':'right':};
