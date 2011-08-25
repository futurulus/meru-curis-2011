// QueryDistance
// by Elliot Conte

Distance = 0;
var AddFunction;
var RemoveFunction;
FoundObjects = new Array();
var TimerName;
TimerLength = 2;


function QueryDistance(distance, CallbackFunctionAdd, CallbackFunctionRemove)
{
  system.import('std/core/repeatingTimer.em');
  Distance = distance;
  AddFunction = CallbackFunctionAdd;
  RemoveFunction = CallbackFunctionRemove;
  system.presences[0].onProxAdded( userAddedCallback);
  system.presences[0].setQueryAngle(.01);
  var repTimer = new std.core.RepeatingTimer(TimerLength, DistancePoll);
  TimerName = repTimer;
}


function userAddedCallback (nowImportantPresence)
{
  var visibleobject = new Object();
  visibleobject.presence = nowImportantPresence;
  visibleobject.distance = nowImportantPresence.dist(system.presences[0].getPosition());
  for(var i=0; i<FoundObjects.length; i++) {
    if (FoundObjects[i].presence.toString() == nowImportantPresence.toString()) return;
    
  }
  if (visibleobject.distance <= Distance) {
    AddFunction(nowImportantPresence);
  }
  FoundObjects.push(visibleobject);
}


//Is called every TimerLength seconds and polls and updates distance of all objects.
function DistancePoll()
{
  for (visibleobject in FoundObjects)
  {
    //If the object used to be > Distance but is now within it. 
    
    if (FoundObjects[visibleobject].distance > Distance && 
           FoundObjects[visibleobject].presence.dist(system.presences[0].getPosition()) <= Distance)
    {
      AddFunction(FoundObjects[visibleobject].presence);
    
    //If the object used to be <= Distance but is now outside it.

    } else if (FoundObjects[visibleobject].distance <= Distance &&
         FoundObjects[visibleobject].presence.dist(system.presences[0].getPosition()) > Distance)
    {
      RemoveFunction(FoundObjects[visibleobject].presence);  
    }
    FoundObjects[visibleobject].distance = FoundObjects[visibleobject].presence.dist(system.presences[0].getPosition());
  }
}


//Call to stop the query.
function StopQueryDistance()
{
  TimerName.suspend();
}

function SetQueryDRate(time)
{
  TimerName.suspend();
  var repeTimer = new std.core.RepeatingTimer(time, DistancePoll);
  TimerName = repeTimer;
}
