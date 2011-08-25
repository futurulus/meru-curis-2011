var randomPrimitives = [42, 'stringalicious', true, 14.95, {}];
var keys = ['a', 'bb', 'ccc', 'dddd'];
var maxChildren = keys.length;

var randomObject = function(objects)
{
	if(typeof(objects) === 'undefined')
		objects = randomPrimitives;
	
	var newObj = {};
	var numChildren = Math.floor(Math.random() * maxChildren + 1);
	
	for(var i = 0; i < numChildren; i++)
	{
		var childIndex = Math.floor(Math.random() * (objects.length + 1));
		var child;
		if(childIndex == objects.length)
		{
			var newObjects = objects;
			newObjects.push(newObj);
			child = randomObject(newObjects);
		}
		else
		{
			child = objects[childIndex];
		}
		
		newObj[keys[i]] = child;
	}
	
	return newObj;
};

