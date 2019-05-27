props.globals.initNode("sim/F-5E/armament/guntype", 0, "INT");

fire_MG = func {
	setprop("/controls/armament/trigger", 1);
}

stop_MG = func {
	setprop("/controls/armament/trigger", 0); 
}


fire_Hellfire = func {
	setprop("/controls/armament/trigger2", 1);
}

stop_Hellfire = func {
	setprop("/controls/armament/trigger2", 0); 
}

fire_gun = func {
	var guntype = getprop("sim/F-5E/armament/guntype");
	if (guntype == 0) {
		fire_MG();
	}else{
		fire_Hellfire();
	}
}
stop_gun = func {
	var guntype = getprop("sim/F-5E/armament/guntype");
	if (guntype == 0) {
		stop_MG();
	}else{
		stop_Hellfire();
	}
}

change_gun = func (t) {
	setprop("sim/F-5E/armament/guntype", t);
	if(t == 0){
		setprop("sim/messages/pilot", "MG Selected");
	}else{
		setprop("sim/messages/pilot", "MISSILES Selected");
	}
}