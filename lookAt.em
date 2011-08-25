var defaultUp = <0, 1, 0>;

system.require('work/quaternion-new.em');

function lookAt(presence, target, up)
{
	if(typeof(up) == "undefined")
		up = defaultUp;
	
	var backward = (presence.position - target).normal();
	var right = up.cross(backward).normal();
	var orthoUp = backward.cross(right);
	var matrix = [[right.x, orthoUp.x, backward.x],
	              [right.y, orthoUp.y, backward.y],
	              [right.z, orthoUp.z, backward.z]];
	
	presence.orientation = util.QuaternionFromMatrix(matrix);
};

function look(presence, direction, up)
{
	lookAt(presence, presence.position + direction, up);
};

util.QuaternionFromForward = function(forward) {
    var z = forward.normal();
    var x = new util.Vec3(1, 0, 0);
    if (forward.y==0&&forward.z==0) {
        x = new util.Vec3(0, 1, 0);
    }
    var y = x.cross(z);
    x = z.cross(y);
    return util.QuaternionFromMatrix([[x.x, x.y, x.z],
									   [y.x, y.y, y.z],
									   [z.x, z.y, z.z]]);//fixme: is this x,y,z or is this transpose of that [[x[0],y[0],z[0]][x[1],y[1],z[1]],[x[2],y[2],z[2]]]
};

