//Tesla wall connector plug thing
//by Jake Poznanski

//Changelog
//v2 - More resolution on the mounting holes
//   - Made the holding notch a bit smaller

module charger_end(h)
{
  scale([25.4/90, -25.4/90, 1]) union()
  { 
    linear_extrude(height=h)
      polygon([[-3.005779,62.149426],[-16.569022,60.425044],[-29.740098,56.758094],[-42.263469,51.264495],[-53.883598,44.060166],[-59.296113,36.626611],[-63.442667,28.424632],[-69.673609,11.070035],[-72.251218,-0.964639],[-73.128456,-13.334130],[-71.639202,-25.505939],[-69.798978,-31.351306],[-67.117335,-36.947566],[-62.956603,-42.264580],[-58.099931,-46.820177],[-52.664468,-50.661352],[-46.767364,-53.835098],[-34.056822,-58.368283],[-20.905493,-60.795689],[-0.413813,-62.289752],[20.169805,-61.215776],[30.303091,-59.524302],[40.227761,-56.961055],[49.866616,-53.449446],[59.142456,-48.912886],[62.850149,-46.178097],[65.994342,-42.902744],[70.599546,-35.106548],[72.972705,-26.276698],[73.128456,-17.165592],[72.312159,-2.690240],[69.749052,11.631724],[65.145865,25.368845],[58.209326,38.089666],[51.282034,44.690079],[43.262963,49.880688],[25.929636,58.127046],[18.896972,60.277821],[11.675306,61.665637],[4.346951,62.289752],[-3.005779,62.149426]]);
  }
}

//Measured dims are 11x6.4 with 4.5mm depth
module charger_notch(){
    translate([0,-16.5,0])
        cube([9.5, 4.5, 5.0], center=true);
            round(10,10);
}

module screw_hole(){
    translate([0,0,-1]) {
        cylinder(r=2.5, h = height*2, $fn=100);
        translate([0,0,12]) 
            cylinder(r=4.5, 30, $fn=100);
    }
}
module screw_hole2(){
    translate([0,0,-1]) {
        cylinder(r=2.5, h = height*.3, $fn=100);
        translate([0,0,3]) 
            cylinder(r=4.5, 10, $fn=100);
    }
}
width = 75;
height = 75;
depth = 35;

tilt = 50;

difference(){
    cube([width, height+10, depth]);

    rotate([tilt,0,0])
        translate([width/2, height/2+sin(tilt)*35/2,-depth*1.4])       
            scale(1.1)
                charger_end(depth * 3);

    translate([37.5,25,0])
        screw_hole();    
    translate([37.5,70,0])
        screw_hole2();   
    //translate([10,height-10,0])
     //   screw_hole();
    
   // translate([width-10,height-10,0])
     //   screw_hole();
    
  // translate([10,10,0])
    //    screw_hole();
    
   // translate([width-10,10,0])
    //    screw_hole();
        //cube([width, height+25, depth]);
}

rotate([tilt,0,0])
    translate([width/2, height/2+sin(tilt)*35/2-1.1,-16]) 
        scale(1)
            charger_notch();