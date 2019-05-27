# Northrop F-5E NASAL Settings
# Isaias V. Prestes - PRESTES Hangar - 2009

setprop("/canopy/position-norm", 1);

 setprop("/controls/lighting/landing-lights", "false");
 setprop("/controls/lighting/beacon", "false");
 setprop("/controls/lighting/strobe", "false");
 setprop("/controls/lighting/nav-lights", "false");
 setprop("/controls/lighting/cabin-lights", "false");
 setprop("/controls/lighting/wing-lights", "false");
 setprop("/controls/lighting/taxi-light", "false");
 setprop("/controls/switches/landing-light", "false");
 setprop("/controls/switches/beacon", "false");
 setprop("/controls/switches/strobe", "false");
 setprop("/controls/switches/nav-lights", "false");
 setprop("/controls/switches/taxi-lights", "false");

setlistener("/sim/current-view/view-number", func(n) setprop("/sim/hud/visibility[1]", !n.getValue()), 1);



## Smoke ##

SmokeToggle = func
{
  var smoke=props.globals.getNode("/smoke");
  smoke.getChild("active").setValue(!smoke.getChild("active").getValue());
}

SmokeColor = func
{
  var smoke=props.globals.getNode("/smoke");
  #form white to red
  if(smoke.getChild("color").getValue()=="white") {
    smoke.getChild("color").setValue("red");
    smoke.getChild("red").setValue(0.867);
    smoke.getChild("green").setValue(0.133);
    smoke.getChild("blue").setValue(0.133);
  }
  #from red to green
  else if(smoke.getChild("color").getValue()=="red") {
    smoke.getChild("color").setValue("green");
    smoke.getChild("red").setValue(0.0);
    smoke.getChild("green").setValue(0.533);
    smoke.getChild("blue").setValue(0.267);
  }
  #from green to white
  else if(smoke.getChild("color").getValue()=="green") {
    smoke.getChild("color").setValue("blue");
    smoke.getChild("red").setValue(0.0);
    smoke.getChild("green").setValue(0.0);
    smoke.getChild("blue").setValue(1.0);
  }
  #from blue to white
  else if(smoke.getChild("color").getValue()=="blue") {
    smoke.getChild("color").setValue("white");
    smoke.getChild("red").setValue(1.0);
    smoke.getChild("green").setValue(1.0);
    smoke.getChild("blue").setValue(1.0);
  }
  #from otherwise to white
  else {
    smoke.getChild("color").setValue("white");
    smoke.getChild("red").setValue(1.0);
    smoke.getChild("green").setValue(1.0);
    smoke.getChild("blue").setValue(1.0);
  }
}

SmokeCounter = func(step)
{
  var smoke=props.globals.getNode("/smoke");
  smoke.getChild("particlepersec").setValue(smoke.getChild("particlepersec").getValue()+step);
  if(smoke.getChild("particlepersec").getValue()<0) {
    smoke.getChild("particlepersec").setValue(0);
  }
  i=0;
  var smokeai=props.globals.getNode("/ai/models/multiplayer[0]");
  while(smokeai!=nil) {
    if(smokeai.getNode("sim/model/path").getValue()=="Aircraft/F-5E/Models/F-5Emin.xml") {
      smokeai.getNode("smoke/particlepersec").setValue(smoke.getChild("particlepersec").getValue());
    }
    i=i+1;
    smokeai=props.globals.getNode("/ai/models/multiplayer["~i~"]");
  }
  print("Smoke particle per second: ",smoke.getChild("particlepersec").getValue());
}


setlistener("controls/switches/switch",
  func {
    if(!getprop("controls/switches/switch")) return;
    settimer(
      func {
          props.globals.getNode("controls/switches/switch").setBoolValue(0);
      }
    , 0.1);
  }
 );
