(function() {
    system.require('std/core/bind.em');

    // this function is serialized and executed on the scriptable entity
    function receiveFiles(){
        filesMap = {};
        required = {};
        system.print('In receiveFiles.\n');
        var origImport = system.import;
        var origRequire = system.require;
        system.import = function(filename) {
            if(filename in filesMap) {
                system.print('monkey importing ' + filename);
                system.__evalInGlobal(filesMap[filename]);
            } else {
                system.print('original-importing ' + filename);
                origImport.apply(system, arguments);
            }
        };
        system.require = function(filename) {
            if(filename in filesMap) {
                if(!(filename in required)) {
                    system.print('monkey requiring ' + filename);
                    system.__evalInGlobal(filesMap[filename]);
                    required[filename] = true;
                } else {
                    system.print('already monkey loaded: ' + filename);
                }
            } else {
                system.print('original-requiring ' + filename);
                origRequire.apply(system, arguments);
            }
        };
        scripter = system.createVisible(scripter);

        function readFN(sender,success) {
            if (success)
                std.simpleStorage.readField('FDB',std.core.bind(readyFN, this, sender), {});
        }

        function readyFN(sender, readvalue) {
              filesMap = readvalue;
              {'FDBread':'success'} >> system.createVisible(sender) >> [];
              persistScript << [{'request':'script':},{'persist':true:}]<< system.createVisible(sender);
        }

        function readFDB() {
            system.require('std/shim/restore/simpleStorage.em');
            system.require('std/default.em');
            function readScript(FDB) {
                filesMap = FDB;
                std.simpleStorage.readField('persistScript',runScript, '');
            }

            function runScript(scriptObj) {
                required = {};
                system.print('In receiveFiles.\n');
                var origImport = system.import;
                var origRequire = system.require;
                system.import = function(filename) {
                    if(filename in filesMap) {
                        system.print('monkey importing ' + filename);
                        eval(filesMap[filename]);
                    } else {
                        system.print('original-importing ' + filename);
                        origImport.apply(system, arguments);
                    }
                };
                system.require = function(filename) {
                    if(filename in filesMap) {
                        if(!(filename in required)) {
                            system.print('monkey requiring ' + filename);
                            eval(filesMap[filename]);
                            required[filename] = true;
                        } else {
                            system.print('already monkey loaded: ' + filename);
                        }
                    } else {
                        system.print('original-requiring ' + filename);
                        origRequire.apply(system, arguments);
                    }
                };
                eval(scriptObj.script);
            }

            std.simpleStorage.readField('FDB',readScript,{});
        }

        function persistScript(msg, sender) {
            system.print('\nPersisting script. \n');
            std.simpleStorage.setScript(readFDB,false);
            std.simpleStorage.setField('persistScript', {script: msg.script}, function() {
                system.print('successfully persisted');
            });
        }

        function setupDB(msg, sender) {
            system.require('std/shim/restore/simpleStorage.em');
            system.require('std/core/bind.em');

            std.simpleStorage.setField('FDB',msg.FDB, std.core.bind(readFN,this,sender.toString()));
        }

        {'request':'FDB'} >> scripter >> [setupDB, 30, function() {}];
    }

    // this stuff is executed on the requesting entity
    function createFileDB(fnames) {
        var FDB = {};
        for (var i=0; i<fnames.length; i++) {
            var fstring = system.__debugFileRead('../share/js/scripts/'+fnames[i]);
            system.print('\n\nRead file: '+fnames[i]+' = ' + fstring+'\n\n');
            FDB[fnames[i]]=fstring;
        }
        return FDB;
    }
    //Function executed first to set up everything on the client.
    sendScript = function(target, fnames,script) {
        ///////////WHAT HAPPENING//////////////
        system.print('sendScript called. \n');
        var scriptString = @
            (function () {
                var scripter = '@ + system.self.toString() + @';
                @ + receiveFiles.toString() + @
                receiveFiles();
            })();
        @;
        ///////////////////////////////////////
        var request = {
            request : 'script',
            script: scriptString
        };
        var FDB = createFileDB(fnames);
        function(msg, sender) { sendFDB(FDB, script, msg, sender); } <<
            {'request':'FDB':} << target;
        request >> target >> [];
        system.print('Sent first script request\n');
    }
    function sendFDB(FDB, script, msg, target) {
            system.print('Got request for FDB\n');
            msg.makeReply({'FDB':FDB})>>[];
           //{'FDB':FDB}>>system.createVisible(target)>>[];
           std.core.bind(sendFinalScript,this,script)<<{'FDBread':'success':}<<target;
    }
    function sendFinalScript(fscript, msg, target) {
        system.print('Got request for final script request\n');
        system.print('Sending script:\n ' +fscript + '\n to: '+target.toString()+'\n');

        var request = {
            request: 'script',
            script: fscript,
            persist: true
        };
        request >> target >> [];
    }

})();


/*
How you would use the library:

var scriptToRun = @
    system.import('std/myGame.em');
    runMyGame();
@;

sendScript(simulator._selected, [
    'std/myGame.em',
    'std/myGame/uberCollision.em',
    'std/myGame/specialGUI.em'
], scriptToRun);

// @@@ requirer.em @@@
system.require('work/required.em');

system.print('It might work!');
testRequired();

// @@@ required.em @@@
testRequired = function() {
    system.self.scale = 7;
};

// @@@ input @@@
system.import('work/script.em');

var scriptToRun = @
    system.import('work/requirer.em');
    system.self.orientationVel = <0, 1, 0; 1> * Math.PI;
@;

sendScript(simulator._selected, [
    'work/requirer.em',
    'work/required.em'
], scriptToRun);
*/