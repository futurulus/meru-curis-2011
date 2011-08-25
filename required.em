testRequired = function() {
	system.self.scale = 15;
	function(msg, sender) {
		msg.makeReply({printrequest: 'yep'}) >> [];
	} << {'fileDB':'works?':};
};