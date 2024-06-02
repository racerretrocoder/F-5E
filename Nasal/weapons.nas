props.globals.initNode("sim/F-5E/armament/guntype", 0, "INT");
var dt = 0;
var isFiring = 0;
var splashdt = 0;
var MPMessaging = props.globals.getNode("/payload/armament/msg", 1);



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


# This is to detect collision when balistic are shooted.
# The goal is to put an automatic message for gun splash
var Mp = props.globals.getNode("ai/models");
var Impact = func() {
    var splashOn = "Nothing";
    var numberOfSplash = 0;
    var raw_list = Mp.getChildren();
    # Running threw ballistic list
    foreach(var c ; raw_list)
    {
        # FIXED, with janitor. 5H1N0B1
        var type = c.getName();
        if(! c.getNode("valid", 1).getValue())
        {
            continue;
        }
        var HaveImpactNode = c.getNode("impact", 1);
        # If there is an impact and the impact is terrain then
        if(type == "ballistic" and HaveImpactNode != nil)
        {
            var type = HaveImpactNode.getNode("type", 1);
            if(type != "terrain")
            {
                var elev = HaveImpactNode.getNode("elevation-m", 1).getValue();
                var lat = HaveImpactNode.getNode("latitude-deg", 1).getValue();
                var lon = HaveImpactNode.getNode("longitude-deg", 1).getValue();
                if(lat != nil and lon != nil and elev != nil)
                {
                    #print("lat"~ lat~" lon:"~ lon~ "elev:"~ elev);
                    ballCoord = geo.Coord.new();
                    ballCoord.set_latlon(lat, lon, elev);
                    var tempo = findmultiplayer(ballCoord);
                    if(tempo != "Nothing")
                    {
                        splashOn = tempo;
                        numberOfSplash += 1;
                    }
                }
            }
        }
    }
    var time = getprop("/sim/time/elapsed-sec");
    if(splashOn != "Nothing")
    {
        if(time - splashdt < 0.1){
            settimer(Impact,0.1);
            return;
        }
        #var phrase = "M61A1 shell hit: " ~ splashOn~". "~ numberOfSplash ~" hits";
        #if(MPMessaging.getValue() == 1)
        #{
        #    setprop("/sim/multiplay/chat", phrase);
        #}
        #else
        #{
        #    setprop("/sim/messages/atc", phrase);
        #}
        #splashdt = time;
        var phrase = "M61A1 shell" ~ " hit: " ~ splashOn ~ ": " ~ numberOfSplash ~ " hits";
        if (getprop("/payload/armament/msg")) {
            #armament.defeatSpamFilter(phrase);
            var msg = notifications.ArmamentNotification.new("mhit", 4, -1*(damage.shells["M61A1 shell"][0]+1));
                    msg.RelativeAltitude = 0;
                    msg.Bearing = 0;
                    msg.Distance = numberOfSplash;
                    msg.RemoteCallsign = splashOn;
            notifications.hitBridgedTransmitter.NotifyAll(msg);
            damage.damageLog.push("You hit "~splashOn~" with "~"M61A1 shells"~", "~numberOfSplash~" times.");
        } else {
            setprop("/sim/messages/atc", phrase);
        }
        splashdt=time;
    }
}

# Nb of impacts
var Nb_Impact = func() {
    var mynumber = 0;
    var raw_list = Mp.getChildren();
    foreach(var c ; raw_list)
    {
        # FIXED, with janitor. 5H1N0B1
        var type = c.getName();
        if(! c.getNode("valid", 1).getValue())
        {
            continue;
        }
        var HaveImpactNode = c.getNode("impact", 1);
        if(type == "ballistic")
        {
            mynumber +=1;
        }
    }
    return mynumber;
}

# We mesure the minimum distance to all contact. This allow us to deduce who is the MP
var findmultiplayer = func(targetCoord) {
    var raw_list = Mp.getChildren();
    var dist  = 80;
    var SelectedMP = "Nothing";
    foreach(var c ; raw_list)
    {
        # FIXED, with janitor. 5H1N0B1
        var type = c.getName();
        if(! c.getNode("valid", 1).getValue())
        {
            continue;
        }
        var HavePosition = c.getNode("position", 1);
        var name = c.getNode("callsign", 1);
        
        if(type == "multiplayer" and HavePosition != nil and targetCoord != nil and name != nil)
        {
            var elev = HavePosition.getNode("altitude-m", 1).getValue();
            var lat = HavePosition.getNode("latitude-deg", 1).getValue();
            var lon = HavePosition.getNode("longitude-deg", 1).getValue();
            
            elev = (elev == nil) ? HavePosition.getNode("altitude-ft", 1).getValue() * FT2M : elev;
            
            #print("name:"~name.getValue());
            #print("lat"~ lat.getValue()~" lon:"~ lon.getValue()~ "elev:"~ elev.getValue());
            
            MpCoord = geo.Coord.new();
            MpCoord.set_latlon(lat, lon, elev);
            var tempoDist = MpCoord.direct_distance_to(targetCoord);
            #print("TempoDist:"~tempoDist);
            if(dist > tempoDist)
            {
                dist = tempoDist;
                SelectedMP = name.getValue();
                #print("That worked");
            }
        }
    }
    print("Splash on : Callsign:"~SelectedMP);
    return SelectedMP;
}
setlistener("ai/models/model-impact",Impact,0,0);