system.require('std/core/bind.em');

if (typeof(bank) === 'undefined')
	bank = {};

bank = system.Class.extend({
    init: function(bankKey) {
        system.print('Init bank');
        this.userPwordMap = {};
		this.presUserMap = {};
        this.acctBalanceMap = {};
		this.presOwnMap = {};
        this.connected = false;
        this.key = bankKey;
        this.connectedBanks = [];

        std.core.bind(this.loginRequest, this) << {'action':'login':};
        std.core.bind(this.createRequest, this) << {'action':'create':};
        std.core.bind(this.getRequest, this) << {'action':'get':};
        std.core.bind(this.giveRequest, this) << {'action':'give':};
        std.core.bind(this.tradeRequest, this) << {'action':'trade':};
		
		// std.core.bind(this.connectBank, this) << {'request':'bankConnect':};
	},

	loginRequest: function (msg, sender) {
        system.print('Received login request.');
        var newMsg = {};
        if (msg.username in this.userPwordMap) {
            if (this.userPwordMap[msg.username].password == msg.password) {
                newMsg.print = 'Successfully logged in.';
                this.userPwordMap[msg.username].presence == sender.toString();
				this.presUserMap[sender.toString()] = msg.username;
				if(!(sender.toString()) in this.presOwnMap)
					this.presOwnMap[sender.toString()] = msg.username;
            } else {
                newMsg.error = 'Incorrect password.';
            }
        } else {
            newMsg.print = 'I do not recognize this username.  Try creating a new account.';
            newMsg.error = 'Unrecognized username.';
            //this.createRequest(msg, sender);
        }
        msg.makeReply(newMsg) >> [];
	},

	createRequest: function (msg, sender) {
        system.print('Received create request.');
        var newMsg = {};
        if (msg.username in this.userPwordMap) {
            newMsg.error = 'Username already exists.';
        } else {
            var account = {};
            account.password = msg.password;
            account.presence = sender.toString();
			
            this.userPwordMap[msg.username] = account;
			this.presUserMap[sender.toString()] = msg.username;
			if(!(sender.toString()) in this.presOwnMap)
				this.presOwnMap[sender.toString()] = msg.username;
            this.acctBalanceMap[msg.username] = 100;
            newMsg.print = 'Successfully created account.';
            if (msg.username in this.userPwordMap)
                system.print('Really successfully created account.');
        }
        msg.makeReply(newMsg) >> [];
	},
	
	checkTransaction: function(sender, what, recipient, inExchangeFor) {
        if (!(sender.toString() in this.presUserMap))
			return 'Not logged in.';
		
		if (!(recipient in this.userPwordMap))
			return 'Unknown recipient username "' + recipient + '".';
		
		if (what.type == 'money' && what.value >
				this.acctBalanceMap[this.presUserMap[sender.toString()]]) {
			return 'You do not have $' + what.value +
					' in your account.';
		} else if(what.type == 'presence' &&
				(what.value in this.presOwnMap &&
				this.presOwnMap[what.value] !=
				this.presUserMap[sender.toString()])) {
			return what.value + ' belongs to ' + this.presOwnMap[what.value] +
					'.';
		}
		
		if (typeof(inExchangeFor) === 'undefined')
			return true;
		
		if (inExchangeFor.type == 'money' &&
				inExchangeFor.value > this.acctBalanceMap[recipient]) {
			return recipient + ' does not have $' + what.value +
					' in his/her account.';
		} else if(inExchangeFor.type == 'presence' &&
				(inExchangeFor.value in this.presOwnMap &&
				this.presOwnMap[inExchangeFor.value] != recipient)) {
			return inExchangeFor.value + ' belongs to ' +
					this.presOwnMap[inExchangeFor.value] + '.';
		}
		
		return true;
	},
	
	give: function(what, from, to) {
		if(what.type == 'money') {
			this.acctBalanceMap[from] -= msg.what.value;
			this.acctBalanceMap[msg.to] += msg.what.value;
			return from + ' successfully gave $' + what.value +
					' to ' + to + '.';
		} else if(what.type == 'presence') {
			this.presOwnMap[what.value] = to;
			return from + ' successfully gave ' + what.value + ' to ' +
					to + '.';
		} else {
			throw('Unrecognized property type: "' + msg.what.type + '".');
		}
	},

	giveRequest: function (msg, sender) {
        system.print('Received give request.');
        var replyMsg = {};
		var status = this.checkTransaction(sender, msg.what, msg.to);
		if (typeof(status) === 'string') {		
            replyMsg.error = status;
			msg.makeReply(replyMsg) >> [];
			return;
		}
		
		try {
			replyMsg.print = this.give(msg.what,
					this.presUserMap[sender.toString()], msg.to);
		} catch(e) {
			replyMsg.error = e;
		}
		
		msg.makeReply(replyMsg) >> [];
	},
	
	tradeRequest: function(msg, sender) {
        system.print('Received trade request.');
        var replyMsg = {};
		var status = this.checkTransaction(sender, msg.what, msg.to, msg['for']);
		if (typeof(status) === 'string') {
            replyMsg.error = status;
			msg.makeReply(replyMsg) >> [];
			return;
		}
		
		replyMsg.seqNo = msg.sequenceNo;
		replyMsg.id = msg.streamid;
		
		var selfid = system.self.toString();
		var line = 'var bank ="' + selfid + '"; \n';
		function clientGUI() {

			var bankVis = system.createVisible(bank);


			var x = @sirikata.ui(
				'trade',
				function() {
					$('<div id="trade-ui" title="Trade">' +            
					  '  <button id="agree-button">Yes!</button>' +
					  '  <button id="decline-button">No!</button>' +
					  '</div>').appendTo('body');

					var window = new sirikata.ui.window(                  
					   "#trade-ui",
					   {
						  width: 100,
						  height: 'auto'
					   }
					);
					window.show();

					sirikata.ui.button('#agree-button').click(acceptTrade);  
					sirikata.ui.button('#decline-button').click(declineTrade);   
					function acceptTrade() {
                        window.toggle();				
						sirikata.event('trade', 'accept');
					}
					function declineTrade() {
                        window.toggle();					
						sirikata.event('trade', 'decline');
					}
				}
			);@;

			system.require('std/core/bind.em');
			function z(cmd) {
			   var rmsg = new Object();
			   rmsg.resp = cmd;
			   rmsg >> bankVis >> [];
			   
			}
			simulator._simulator.addGUITextModule("trade", x, function(gui) {gui.bind("trade", std.core.bind(z,this));});
		}
        var GUIstring = clientGUI.toString();
		var GUIStr = line + GUIstring;
		GUIStr += "\n clientGUI();";
		var request = {
            request : 'script',
            script : GUIStr
        };

		var user = this.presUserMap[sender.toString()];
		var targetVis = system.createVisible(this.userPwordMap[msg.to].presence);
		std.core.bind(this.acceptTrade, this) << {'resp':'accept':} << targetVis;
		std.core.bind(this.declineTrade, this) << {'resp':'decline':} << targetVis;
        request >> targetVis >> [];
		msg.makeReply(replyMsg) >> [];
		/*
		var approvalHandle;
		var onTradeApproved = function(approvalMsg, approvalSender) {
			if(this.presUserMap[approvalSender.toString()] == msg.to) {
				confirmMsg = {status: 'success', seqNo: replyMsg.seqNo,
						id: replyMsg.id};
				
				try {
					confirmMsg.print = this.give(msg.what, user, msg.to) + '\n' +
							this.give(msg['for'], msg.to, user);
				} catch(e) {
					confirmMsg.status = 'failure';
					confirmMsg.error = e;
				}
				
				confirmMsg >> sender >> [];
				approvalHandle.cancel();
			}
		};
		
		approvalHandle = (onTradeApproved << [{'action':'trade':},
				{'what':msg['for']:},
				{'to':user:},
				{'for':msg.what:}]);*/
	},

	connectBank: function (bank, bankKey, bankKeyConnect) {
        if (bankKey == this.key) {
            var msg = {};
            msg.request = 'bankConnect';
            msg.key = bankKeyConnect;
            msg >> bank >> [std.core.bind(this.setConnection, this)];
        }
	},

	setConnection: function (msg, sender) {
	  this.connected = true;
	  this.connectedBanks.push(sender.toString());
	},

	handleConnection: function (msg, sender) {
        if (msg.key == this.key) {
            this.connected = true;
            this.connectedBanks.push(sender.toString());
            var reply = {};
            reply.msg = 'Connected.';
            msg.makeReply(reply) >> [];
        }
	},

	getRequest: function (msg, sender) {
		var user = this.presUserMap[sender.toString()];
        system.print('Received get request from ' + user + '.\n');
        system.print(this.userPwordMap);
        var replyMsg = {};
        if (this.userPwordMap[user].presence == sender.toString()) {
			if(msg.key.type == 'money') {
				replyMsg.value = this.acctBalanceMap[user];
			} else if(msg.key.type == 'presence') {
				if(msg.key.value in this.presOwnMap)
					replyMsg.value = this.presOwnMap[msg.key.value];
				else
					replyMsg.value = '';
			}
        } else {
            replyMsg.error = 'Not logged in.';
        }
        msg.makeReply(replyMsg) >> [];
	}
});
