system.require('work/motion.em');

motion.Bounce = motion.Motion.extend({
	init: function(presence, y, elast, period) {
		var callback = function() {
			if(presence.position.y - presence.scale <= y && presence.velocity.y < 0)
				presence.velocity = <presence.velocity.x, -elast * presence.velocity.y, presence.velocity.z>;
		};
		
		this._super(presence, callback, period);
	}
});
