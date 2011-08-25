system.import('work/state.em');
system.self.mesh = 'meerkat:///emily2e/models/godzilla.dae/optimized/0/godzilla.dae';

var bank = simulator._selected;
var conn = new state.Connection(bank);
conn.create('alex', 'hi');

var success = 'none';

function get() {
	conn.get({type: 'money'}, function(val) {system.print(val.toString() + '\n');});
}

function trade() {
	conn.trade({type: 'money', value: 20},
			{type: 'money', value: 10}, 'will',
			function() { success = true; },
			function() { success = false; });
}
