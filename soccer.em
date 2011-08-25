soccer = {};

(function() {
    system.require('std/default.em');
    system.require('std/movement/units.em');
    system.require('std/movement/motion.em');
    system.require('std/movement/collision.em');

    system.import('work/pilot.em');

    var BALL_MESH = 'meerkat:///emily2e/models/soccerBall.dae/optimized/soccerBall.dae';
    var BALL_SCALE = 0.5;
    var BALL_POS = new util.Vec3(0, 0, 0);
    var CATCH_RADIUS = 4 * u.m; // maximum distance between spaceship and ball for a catch
    var SHIP_RADIUS = 2 * u.m; // radius used to detect collisions between spaceships
    var THROW_SPEED = 10 * u.m / u.s; // initial speed of ball when thrown
    var ball = null;
    var players = {};
    var holdingBall = '';

    var handlers = [];

    function onBallCreated(pres) {
        ball = pres;
        ball.scale = BALL_SCALE;

        handlers.push(onTouch << {'action':'touch':});
        handlers.push(onJoinMessage << {'soccer':'join':});
        handlers.push(onQuitMessage << {'soccer':'quit':});
        handlers.push(onCatchMessage << {'soccer':'catch':});
        handlers.push(onThrowMessage << [{'soccer':'throw':}, {'direction'::}]);
    };

    system.createPresence(BALL_MESH, onBallCreated, system.self.position + BALL_POS);

    function onTouch(msg, sender) {
        var script = '(' + pilotAvatar.toString() + ')();';
        script = script.replace('###', system.self.toString());
        {
            request: 'script',
            script: script
        } >> sender >> [];
    };

    function onJoinMessage(msg, sender) {
        var id = sender.toString();
        system.print('received join message from ' + id.substring(0, 4) + '\n');
        players[sender.toString()] = true;
        msg.makeReply({
            ball: ball.toString(),
            players: players
        }) >> [];
    };

    function onQuitMessage(msg, sender) {
        var id = sender.toString();
        system.__debugPrint('received quit message from ' + id.substring(0, 4) + '\n');
        delete players[sender.toString()];
    };

    function onCatchMessage(msg, sender) {
        var id = sender.toString();
        system.__debugPrint('received catch message from ' + id.substring(0, 4) + '\n');
        if((ball.position - sender.position).lengthSquared() <
                CATCH_RADIUS * CATCH_RADIUS && holdingBall == '') {
            catchBall(sender);
            msg.makeReply({}) >> [];
        }
    };

    function catchBall(player) {
        var id = player.toString();
        system.print(id.substring(0, 4) + ' caught the ball\n');
        holdingBall = id;
        ball.mesh = '';
    };

    function onThrowMessage(msg, sender) {
        var id = sender.toString();
        system.print('received throw message from ' + id.substring(0, 4) + '\n');
        if(holdingBall == sender.toString()) {
            throwBall(sender, msg.direction);
            msg.makeReply({}) >> [];
        }
    };

    function throwBall(player, direction) {
        var id = player.toString();
        system.print(id.substring(0, 4) + ' threw the ball\n');
        holdingBall = '';
        ball.position = player.position;
        ball.velocity = direction.normal() * THROW_SPEED;
        ball.mesh = BALL_MESH;
    };

    system.self.mesh = 'meerkat:///wmonroe4/stadium.dae/optimized/stadium.dae';
    system.self.setQueryAngle(0.0001);

    soccer.reset = function() {
        for(var i in handlers)
            handlers[i].clear();

        if(ball)
            ball.disconnect();

        delete soccer;
    };
})();