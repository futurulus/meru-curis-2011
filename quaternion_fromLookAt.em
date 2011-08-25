/**
  @function
  @param direction Vector that represents direction to look at.
  @param up Up direction of the quaternion.
  @return A quaternion constructed so that the -z axis (lookat direction) points
          in the same direction as the direction vector, with the up vector
          as close as possible to the given up vector.
*/
util.Quaternion.fromLookAt = function(direction, up) {
    up = up || <0, 1, 0>;
    if (direction.length() < 1e-08)
        return new util.Quaternion(0, 0, 0, 1);

    direction = direction.normal();

    // Orient the -z axis to be along direction.
    var firstQuat;
    if ((direction - <0, 0, -1>).lengthSquared() < 1e-08) {
        firstQuat = new util.Quaternion(0, 0, 0, 1);
    } else if ((direction - <0, 0, 1>).lengthSquared() < 1e-08) {
        firstQuat = new util.Quaternion(0, 1, 0, 0);
    } else {
        var quatAxis = <0, 0, -1>.cross(direction);
        var angle = util.acos(<0, 0, -1>.dot(direction));
        quatAxis = quatAxis.normal();
        firstQuat = new util.Quaternion(quatAxis, angle);
    }

    // Compute new up vector and orient the y axis to be along that direction.
    var secondQuat;
    var left = direction.cross(up);
    var newUp = left.cross(direction);
    if (newUp.lengthSquared()>1e-08) {
        newUp = newUp.normal();
		var firstUp = firstQuat.mul(<0, 1, 0>);
        var angle = util.acos(firstUp.dot(newUp));
		if(firstUp.cross(newUp).dot(direction) < 0)
			angle = -angle;
        secondQuat = new util.Quaternion(direction, angle);
    } else {
        secondQuat = new util.Quaternion(0, 0, 0, 1);
    }

    return secondQuat.mul(firstQuat);
}
