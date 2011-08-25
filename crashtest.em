var rainMesh = 'meerkat:///wmonroe4/rain_large.dae/optimized/0/rain_large.dae';

function create() {
	system.createPresence(rainMesh, function() {
		system.timeout(.001, function() {
			create();
		});
	});
}

create();
