system.require('std/core/bind.em');

if(typeof(state) === 'undefined')
	state = {};

state.defaultTimeout = 5 /* * u.s */;

state.Connection = system.Class.extend({
	init: function(service) {
		this.timeout = state.defaultTimeout;
		
		this.service = service;
		
		this.transaction = 1;
	},
	
	login: function(username, password, create) {
		if(typeof(create) === 'undefined')
			create = false;
		
		this.username = username;
		this.password = password;
		
		var errorResponse = function(message, sender) {
			throw('Error response "' + message.error +
					'" received from state service ' + sender.toString());
		};
		
		var printResponse = function(message, sender) {
			system.print(message.print);
		};
		
		var loginConfirm = function(message, sender) {};
		var loginFailed = function() {
			throw('Login for user ' + username +
					' failed: message timed out');
		};
		
		var action = (create ? 'create' : 'login');
		{action: action, username: this.username, password: this.password} >>
				this.service >> [loginConfirm, this.timeout, loginFailed];
		system.print(action);
		system.print(username);
		system.print(password);
	
		errorResponse << [{'error'::}] << this.service;
		printResponse << [{'print'::}] << this.service;
	},
	
	create: function(username, password) {
		this.login(username, password, true);
	},
	
	logout: function() {
		{action: 'logout', username: this.username} >> this.service >> [];
	},
	
	get: function(key, callback) {
		this.callback = callback;
		
		var onResponse = function(message, sender) {
			if('error' in message)
				return;
			
			if(!('value' in message))
				throw('Bad mesage: response for value "' + key +
						'" did not have a value field');
			
			callback(message.value);
		};
		
		var onNoResponse = function() {
			throw('Could not get value "' + key + '": message timed out');
		};
		
		{action: 'get', key: key} >> this.service >>
				[onResponse, this.timeout, onNoResponse];
	},
	
	give: function(mine, recipient, callback) {
		var onResponse = function(message, sender) {
			if(!('error' in message) && typeof(callback) !== 'undefined')
				callback();
		};
		
		var onNoResponse = function() {
			throw('Could not give "' + std.core.pretty(mine) + '" to ' +
					std.core.pretty(recipient) + ': message timed out');
		};
		
		{action: 'give', what: mine, to: recipient} >> this.service >>
				[onResponse, this.timeout, onNoResponse];
	},
	
	trade: function(mine, yours, you, onSuccess, onFailure) {
		var onSuccessMessage = function(message, sender) {
			if(typeof(onSuccess) !== 'undefined')
				onSuccess();
		};
		
		var onFailureMessage = function(message, sender) {
			if(typeof(onFailure) !== 'undefined')
				onFailure();
		};
		
		var onResponse = function(message, sender) {
			if(!('seqNo' in message) || !('id' in message))
				throw('Response "' + std.core.pretty(message) + 'to trade "' +
						std.core.pretty(mine) + '" to ' + you + ' for "' +
						std.core.pretty(yours) + '" is incorrectly formatted -- '+
						'must contain seqNo and id.');
			
			onSuccessMessage << [{seqNo:message.seqNo:}, {id:message.id:},
					{status:'success':}] << this.service;
			onFailureMessage << [{seqNo:message.seqNo:}, {id:message.id:},
					{status:'failure':}] << this.service;
		};
		
		var onNoResponse = function() {
			throw('Could not give "' + std.core.pretty(mine) + '" to ' +
					std.core.pretty(recipient) + ': message timed out');
		};
		
		{action: 'trade', what: mine, to: you, 'for': yours} >>
				this.service >> [onResponse, this.timeout, onNoResponse];
	}
});
