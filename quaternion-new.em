util.QuaternionFromMatrix = function(m) {
    /* Shoemake SIGGRAPH 1987 algorithm */
    var fTrace = m[0][0]+m[1][1]+m[2][2];
    if (fTrace == 3.0 ) 
    {
        return new util.Quaternion();//optional: identify identity as a common case
    }
    if ( fTrace > 0.0 )
    {
        // |w| > 1/2, may as well choose w > 1/2
        var fRoot = util.sqrt(fTrace + 1.0);  // 2w
        var ifRoot=0.5/fRoot;// 1/(4w)
        return new util.Quaternion((m[2][1]-m[1][2])*ifRoot,
                (m[0][2]-m[2][0])*ifRoot,
                (m[1][0]-m[0][1])*ifRoot,
                0.5*fRoot);
    }
    else
    {
        // |w| <= 1/2
        var s_iNext=[ 1, 2, 0 ];
        var i = 0;
        if ( m[1][1] > m[0][0] )
            i = 1;
        if ( m[2][2] > m[i][i] )
            i = 2;
        var j = s_iNext[i];
        var k = s_iNext[j];
        var fRoot = util.sqrt(m[i][i]-m[j][j]-m[k][k] + 1.0);
        var ifRoot=0.5/fRoot;
        var q=[0,0,0,(m[k][j]-m[j][k])*ifRoot];
        q[i] = 0.5*fRoot;
        q[j] = (m[j][i]+m[i][j])*ifRoot;
        q[k] = (m[k][i]+m[i][k])*ifRoot;
        return new util.Quaternion(q[1], q[2], q[3], q[0]);
    }
};

util.Quaternion.prototype.matrix = function() {
  var qWqW = q.w * q.w;
  var qWqX = q.w * q.x;
  var qWqY = q.w * q.y;
  var qWqZ = q.w * q.z;
  var qXqW = q.x * q.w;
  var qXqX = q.x * q.x;
  var qXqY = q.x * q.y;
  var qXqZ = q.x * q.z;
  var qYqW = q.y * q.w;
  var qYqX = q.y * q.x;
  var qYqY = q.y * q.y;
  var qYqZ = q.y * q.z;
  var qZqW = q.z * q.w;
  var qZqX = q.z * q.x;
  var qZqY = q.z * q.y;
  var qZqZ = q.z * q.z;

  var d = qWqW + qXqX + qYqY + qZqZ;

  return [
    [(qWqW + qXqX - qYqY - qZqZ) / d, 2 * (qWqZ + qXqY) / d, 2 * (qXqZ - qWqY) / d, 0],
    [2 * (qXqY - qWqZ) / d, (qWqW - qXqX + qYqY - qZqZ) / d, 2 * (qWqX + qYqZ) / d, 0],
    [2 * (qWqY + qXqZ) / d, 2 * (qYqZ - qWqX) / d, (qWqW - qXqX - qYqY + qZqZ) / d, 0],
    [0, 0, 0, 1]
  ];
};

