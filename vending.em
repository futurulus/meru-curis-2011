(function() {

vendingTruckScript = @

    function gimme(msg, sender) {
        var numEntities = 1;
        if('gimme' in msg)
            numEntities = msg.gimme;

        function script(args) {
            system.onPresenceConnected(function(pres) {
                if('orientation' in args)
                    pres.orientation = args.orientation;
                else
                    pres.orientation = new util.Quaternion();

                system.import('std/default.em');

                {action: 'created'} >> system.createVisible(args.id) >> [];
            });
        }

        var scale = 1;
        if('scale' in msg)
            scale = msg.scale;

        for(var i = 0; i < numEntities; i++) {
            var mesh = 'meerkat:///wmonroe4/icecream.dae/optimized/icecream.dae';
            if('mesh' in msg)
                mesh = msg.mesh;

            var position;
            if('position' in msg)
                position = msg.position;
            else
                position = <system.self.position.x - 10 + Math.random() * 5,
                            system.self.position.y + Math.random() * 5,
                            system.self.position.z + Math.random() * 5>;

            system.createEntityScript(position, script,
                                      {id: sender.toString(),
                                       orientation: msg.orientation},
                                      system.self.getQueryAngle(), mesh,
                                      scale);
        }
    }

    gimme << {'action':'touch':};
    gimme << {'gimme'::};

@;

if(simulator._selected)
    {request: 'script', script: vendingTruckScript} >> simulator._selected >> [];
else
    system.print('No presence selected!\n');

})();
