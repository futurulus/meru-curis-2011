var mesh = 'meerkat:///test/multimtl.dae/original/0/multimtl.dae';

system.print('script executed');

system.createPresence(mesh, function(newPres){
	system.print('presence created');
	newPres.position = system.self.position + <0, 1, 0>;
});

