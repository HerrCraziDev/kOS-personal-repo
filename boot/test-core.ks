// **************************************
// *		Falcon Core Test Script		*
// *				  -					*
// *	Falcon Reusability System v2.3	*
// *  © FAITO Aerospace Inc. - 	2059    *
// **************************************

// Author : HerrCrazi <herrcrazi@gmail.com>
// License : CC BY-NC-SA
	
// This program is open-source, you can redistribute and modify it as you want,
// but don't forget to mention the author.



switch to 0.
run "boot/faito_init.ks".
runoncepath("libfalcon.ks").

//Some initialization
set radarOffset to alt:radar.
set targetOrbit to 100000.
set landingTarget to getLandingSite("auto").

print "LAT : "+landingTarget:lat.
print "LONG: "+landingTarget:lng.

//Find the index of the Liquid Fuel in the AggregateResources resources list
set lqfResIndex to getResourceIndex("LIQUIDFUEL").


//Wait until launch
print "Waiting for launch. Press [SPACE] to start.".
WAIT UNTIL ship:status <> "PRELAUNCH".

//Launch to a 100km orbit
fh_launch(100).

//Do the boostback and bring that impact point closer to home
fh_boostback(landingTarget).

lock steering to srfretrograde.

//Land the core (hopefully) (warranty void in case of RUD)
run hoverslam.ks(radarOffset, 8).