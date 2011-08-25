var cycles = [];
var cycleMesh = 'meerkat:///wmonroe4/lightcycle.dae/optimized/0/lightcycle.dae';

function entityScript(args) {
    var referee;
    onCycleCreated = function() {
        referee = system.createVisible(args.referee);
        {'tron':'cycleCreated'} >> referee >> [];
    }
    system.import('work/cycle.em');
}

function onCycleCreated(message, sender) {
    system.print('cycle created!\n');
    cycles.push(sender);
    simulator._binding.addAction('tron.left', turnLeft);
    simulator._binding.addAction('tron.right', turnRight);
    simulator._binding.addAction('tron.start', start);
    simulator._binding.addAction('tron.stop', stop);

    simulator._binding.addBindings([
        { key: ['button-pressed', 'j'], action: 'tron.left' },
        { key: ['button-pressed', 'l'], action: 'tron.right' },
        { key: ['button-pressed', 'comma'], action: 'tron.stop' },
        { key: ['button-pressed', 'k'], action: 'tron.start' }
    ]);

    // simulator._camera.follow(cycles[0]);
}
onCycleCreated << {'tron':'cycleCreated':};

system.createEntityScript(system.self.position,
        entityScript, {'referee': system.self.toString()},
        system.self.queryAngle, cycleMesh, 1);

function turnLeft() {
    { action: 'left' } >> cycles[0] >> [];
}

function turnRight() {
    { action: 'right' } >> cycles[0] >> [];
}

function start() {
    { action: 'start' } >> cycles[0] >> [];
}

function stop() {
    { action: 'stop' } >> cycles[0] >> [];
}
