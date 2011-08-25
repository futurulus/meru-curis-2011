system.import("test/treemeshes.em");
system.import("test/flowermeshes.em");
system.import("test/rockmeshes.em");

var zombielib = [];
zombielib.push("meerkat:///kittyvision/zombie4.dae/optimized/0/zombie4.dae");
zombielib.push("meerkat:///kittyvision/zombie3.dae/optimized/0/zombie3.dae");
zombielib.push("meerkat:///kittyvision/zombie2.dae/optimized/0/zombie2.dae");
zombielib.push("meerkat:///kittyvision/zombie1.dae/optimized/0/zombie1.dae");
zombielib.push("meerkat:///kittyvision/blood.dae/optimized/0/blood.dae");

var houselib = [];
houselib.push({mesh:"meerkat:///emily2e/models/SabbathDayHouse.dae/optimized/0/SabbathDayHouse.dae",
               modelOrientation: 0.5*Math.PI});
houselib.push({mesh:"meerkat:///emily2e/models/esteramoise.dae/optimized/0/esteramoise.dae",
               modelOrientation: -Math.PI});
houselib.push({mesh:"meerkat:///emily2e/models/redhouse.dae/optimized/0/redhouse.dae",
               modelOrientation: -Math.PI});
houselib.push({mesh:"meerkat:///kittyvision/house1.dae/optimized/0/house1.dae",
               modelOrientation: 0.5*Math.PI});
houselib.push({mesh:"meerkat:///kittyvision/house2.dae/optimized/0/house2.dae",
               modelOrientation: 0.5*Math.PI});
houselib.push({mesh:"meerkat:///kittyvision/house4.dae/optimized/0/house4.dae",
               modelOrientation: 0.5*Math.PI});

var facilitymeshes = [];

var schoolmeshes = [];
schoolmeshes.push({mesh:"meerkat:///kittyvision/schoolbuilding.dae/optimized/0/schoolbuilding.dae",
                   offset:<0.2,0,-0.2>, scale:0.5, rotation: 0.1*Math.PI, modelOrientation:-Math.PI});
schoolmeshes.push({mesh:"meerkat:///kittyvision/playground.dae/optimized/0/playground.dae",
                   offset:<-0.2,0,0.3>, scale:0.3, rotation: 0.5*Math.PI, modelOrientation:0});
schoolmeshes.push({mesh:"meerkat:///kittyvision/schoolbus2.dae/original/0/schoolbus2.dae",
                   offset:<0.3,0,0.3>, scale:0.2, rotation: 0.5*Math.PI, modelOrientation:Math.PI});
                   
var firestationmeshes = [];
firestationmeshes.push({mesh:"meerkat:///kittyvision/firestation.dae/optimized/0/firestation.dae",
                   offset:<0,0,-0.2>, scale:0.6, rotation: 0, modelOrientation: -Math.PI/3});
firestationmeshes.push({mesh:"meerkat:///kittyvision/firetruck2.dae/original/0/firetruck2.dae",
                   offset:<-0.2,0,0.35>, scale:0.25, rotation: 0.5*Math.PI, modelOrientation:0.5*Math.PI});


var zombiemeshes = [];
zombiemeshes.push({mesh:zombielib[Math.floor(Math.random()*zombielib.length)],
                   offset:<0.25,0,0>, scale:0.1, rotation: 0, modelOrientation: Math.random()*2*Math.PI});
zombiemeshes.push({mesh:zombielib[Math.floor(Math.random()*zombielib.length)],
                   offset:<0.4,0,-0.4>, scale:0.1, rotation: 0, modelOrientation: Math.random()*2*Math.PI});
zombiemeshes.push({mesh:zombielib[Math.floor(Math.random()*zombielib.length)],
                   offset:<0.35,0,-0.25>, scale:0.1, rotation: 0, modelOrientation: Math.random()*2*Math.PI});
zombiemeshes.push({mesh:zombielib[Math.floor(Math.random()*zombielib.length)],
                   offset:<0.35,0,0>, scale:0.1, rotation: 0, modelOrientation: Math.random()*2*Math.PI});
zombiemeshes.push({mesh:zombielib[Math.floor(Math.random()*zombielib.length)],
                   offset:<0.45,0,-0.6>, scale:0.1, rotation: 0, modelOrientation: Math.random()*2*Math.PI});
zombiemeshes.push({mesh:zombielib[Math.floor(Math.random()*zombielib.length)],
                   offset:<-0.65,0,-0.1>, scale:0.1, rotation: 0, modelOrientation: Math.random()*2*Math.PI});
zombiemeshes.push({mesh:zombielib[Math.floor(Math.random()*zombielib.length)],
                   offset:<0.5,0,0.6>, scale:0.1, rotation: 0, modelOrientation: Math.random()*2*Math.PI});

var housemeshes = [];
var index = Math.floor(Math.random()*houselib.length);
housemeshes.push({mesh: houselib[index].mesh, offset:<0.2,0,0.2>, scale:0.24,
                   rotation: 0, modelOrientation: houselib[index].modelOrientation});
index = Math.floor(Math.random()*houselib.length);
housemeshes.push({mesh: houselib[index].mesh, offset:<-0.2,0,0.2>, scale:0.24,
                   rotation:0, modelOrientation: houselib[index].modelOrientation});
index = Math.floor(Math.random()*houselib.length);
housemeshes.push({mesh: houselib[index].mesh, offset:<-0.2,0,-0.2>, scale:0.24,
                   rotation: Math.PI, modelOrientation: houselib[index].modelOrientation});
index = Math.floor(Math.random()*houselib.length);
housemeshes.push({mesh: houselib[index].mesh, offset:<0.2,0,-0.2>, scale:0.24,
                   rotation: Math.PI, modelOrientation: houselib[index].modelOrientation});

var parkmeshes = [];
// rocks for path
var index = Math.floor(Math.random()*rockmeshes.length);
parkmeshes.push({mesh: rockmeshes[index], offset:<-0.4,0,0.35>, scale: 0.05,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*rockmeshes.length);
parkmeshes.push({mesh: rockmeshes[index], offset:<-0.3,0,0.25>, scale: 0.05,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*rockmeshes.length);
parkmeshes.push({mesh: rockmeshes[index], offset:<-0.2,0,0.2>, scale: 0.05,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*rockmeshes.length);
parkmeshes.push({mesh: rockmeshes[index], offset:<-0.1,0,0.1>, scale: 0.05,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*rockmeshes.length);
parkmeshes.push({mesh: rockmeshes[index], offset:<0,0,0>, scale: 0.05,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*rockmeshes.length);
parkmeshes.push({mesh: rockmeshes[index], offset:<0.1,0,-0.15>, scale: 0.05,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*rockmeshes.length);
parkmeshes.push({mesh: rockmeshes[index], offset:<0.2,0,-0.3>, scale: 0.05,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*rockmeshes.length);
parkmeshes.push({mesh: rockmeshes[index], offset:<0.3,0,-0.4>, scale: 0.05,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
// trees
index = Math.floor(Math.random()*treemeshes.length);
parkmeshes.push({mesh: treemeshes[index], offset:<0.1,0,0.4>, scale: 0.17,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*treemeshes.length);
parkmeshes.push({mesh: treemeshes[index], offset:<0.2,0,0.15>, scale: 0.17,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*treemeshes.length);
parkmeshes.push({mesh: treemeshes[index], offset:<0.35,0,0.38>, scale: 0.17,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*treemeshes.length);
parkmeshes.push({mesh: treemeshes[index], offset:<0.4,0,-0.2>, scale: 0.17,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*treemeshes.length);
parkmeshes.push({mesh: treemeshes[index], offset:<0.35,0,-0.32>, scale: 0.17,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*treemeshes.length);
parkmeshes.push({mesh: treemeshes[index], offset:<-0.25,0,0.04>, scale: 0.17,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*treemeshes.length);
parkmeshes.push({mesh: treemeshes[index], offset:<-0.35,0,0.15>, scale: 0.17,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*treemeshes.length);
parkmeshes.push({mesh: treemeshes[index], offset:<-0.3,0,-0.2>, scale: 0.17,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*treemeshes.length);
parkmeshes.push({mesh: treemeshes[index], offset:<-0.32,0,-0.3>, scale: 0.17,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});

// flowers
index = Math.floor(Math.random()*flowermeshes.length);
parkmeshes.push({mesh: flowermeshes[index], offset:<0.1,0,0.27>, scale: 0.08,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*flowermeshes.length);
parkmeshes.push({mesh: flowermeshes[index], offset:<0.35,0,0.06>, scale: 0.08,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*flowermeshes.length);
parkmeshes.push({mesh: flowermeshes[index], offset:<-0.3,0,-0.2>, scale: 0.08,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*flowermeshes.length);
parkmeshes.push({mesh: flowermeshes[index], offset:<-0.4,0,-0.3>, scale: 0.08,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*flowermeshes.length);
parkmeshes.push({mesh: flowermeshes[index], offset:<-0.2,0,-0.3>, scale: 0.08,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*flowermeshes.length);
parkmeshes.push({mesh: flowermeshes[index], offset:<-0.1,0,-0.4>, scale: 0.08,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*flowermeshes.length);
parkmeshes.push({mesh: flowermeshes[index], offset:<-0.15,0,-0.37>, scale: 0.08,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*flowermeshes.length);
parkmeshes.push({mesh: flowermeshes[index], offset:<-0.25,0,-0.32>, scale: 0.08,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*flowermeshes.length);
parkmeshes.push({mesh: flowermeshes[index], offset:<0.16,0,0.14>, scale: 0.08,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
index = Math.floor(Math.random()*flowermeshes.length);
parkmeshes.push({mesh: flowermeshes[index], offset:<0.2,0,0.17>, scale: 0.08,
                 rotation: Math.random()*2*Math.PI, modelOrientation: 0});
// sign
parkmeshes.push({mesh: "meerkat:///kittyvision/southparksign.dae/optimized/0/southparksign.dae",
                 offset:<-0.4,0,0.4>, scale: 0.11, rotation: 0, modelOrientation: 0});

// little market
parkmeshes.push({mesh: "meerkat:///danielrh/market.dae/optimized/0/market.dae",
                 offset:<-0.05,0,-0.3>, scale: 0.115, rotation: -1.13*Math.PI, modelOrientation: Math.PI});

facilitymeshes["school"] = schoolmeshes;
facilitymeshes["firestation"] = firestationmeshes;
facilitymeshes["zombies"] = zombiemeshes;
facilitymeshes["house"] = housemeshes;
facilitymeshes["park"] = parkmeshes;