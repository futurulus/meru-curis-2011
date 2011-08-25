system.import("test/islandGenerator.em");
system.require("std/shim/bbox.em");
system.require("std/shim/raytrace.em");
system.import("test/carGenerator-bound2.em");
system.import("test/streetGenerator-standalone.em");
system.import("test/facilityGenerator.em");

function createVertexGrid(controller, cols, rows, space, callback) {
    function constructVertexGrid() {
        system.__debugPrint("\nislandPos: <"+islandPos.x+", "+islandPos.y+", "+islandPos.z+">");
        system.__debugPrint("\nislandBB: <"+islandBB.x+", "+islandBB.y+", "+islandBB.z+">\n");
    
        var offset = space*cols*multiplier/4;
        var x = islandPos.x - islandBB.x/2 + offset;
        var y = islandPos.y + islandBB.y/2;
        var z = islandPos.z - islandBB.z/2 + multiplier*offset;
        var anchor = <x,y,z>;
        
        var vertexGrid = [];
        for(var i = 0; i < cols; i++) {
            var col = [];
            for(var j = 0; j < rows; j++) {
                var pos = <anchor.x+space*i,anchor.y,anchor.z+space*j>;
                col.push(pos);
            }
            vertexGrid.push(col);
        }
        callback(controller, vertexGrid, space);
    }

    var multiplier = 4/3;
    var islandPos = <0,0,0>;
    var islandBB = <0,0,0>;
    createIsland(space*cols*multiplier, islandPos, islandBB, constructVertexGrid);
}

createVertexGrid(system.self, 4,4,10,function(controller, vertexGrid, space) {
    system.__debugPrint("\nIn callback for createVertexGrid:");
    var street = createStreet(vertexGrid);
    placeStreet(street, space);
    
    createFacility("firestation","north", vertexGrid[0][0] + <space/10, 0, space/10>, space*0.8);
    createFacility("school","north", vertexGrid[0][1] + <space/10, 0, space/10>, space*0.8);
    createFacility("house","north", vertexGrid[1][0] + <space/10, 0, space/10>, space*0.8);
    createFacility("house","north", vertexGrid[0][2] + <space/10, 0, space/10>, space*0.8);
    createFacility("house","west", vertexGrid[1][2] + <space/10, 0, space/10>, space*0.8);
    createFacility("zombies","east", vertexGrid[2][1] + <space/10, 0, space/10>, space*0.8);
    createFacility("zombies","north", vertexGrid[1][1] + <space/10, 0, space/10>, space*0.8);
    createFacility("zombies","west", vertexGrid[2][2] + <space/10, 0, space/10>, space*0.8);
    
    createCar(street, space, controller);
});
