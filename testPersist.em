system.import('work/script.em');

var scriptToRun = @
    system.import('work/requirer.em');
    system.self.orientationVel = <0, 1, 0; 1> * Math.PI;
	function(msg, sender) {
		msg.makeReply({printrequest: 'yep'}) >> [];
	} << {'persistence':'works?':};
@;

sendScript(simulator._selected, [
    'work/requirer.em',
    'work/required.em'
], scriptToRun);