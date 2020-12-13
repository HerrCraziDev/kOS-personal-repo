//***********************************/
//*		Falcon Core Test Script		*/
//*				  -					*/
//*	Falcon Reusability System v2.3	*/
//* © FAITO Aerospace Inc. - 	2059*/
//***********************************/

//	Author : HerrCrazi

	
//This document is open-source, you can redistribute and modify it as you want,
//but don't forget to mention the author.

parameter targetOrbit is 100000.
parameter targetHeading is 90.

switch to 0.
run "boot/faito_init.ks".
runoncepath("libfalcon.ks").



//Some initialization
set radarOffset to alt:radar.
set landingTarget to getLandingSite("LZ-1").


clearscreen.
print "FAITO FRS v0.5.8".

print "LAT : "+landingTarget:lat.
print "LONG: "+landingTarget:lng.



//Wait until launch
print "Waiting for launch. Press [SPACE] to start.".
WAIT UNTIL ship:status <> "PRELAUNCH".
print "System engaged.".

if (core:tag = "main" or core:tag="grasshopper")
{
	gear off.
	panels off.

	lock throttle to 1.
	lock steering to Up.
	WAIT 1.

	//Find the index of the Liquid Fuel in the AggregateResources resources list
	set lqfResIndex to getResourceIndex("LIQUIDFUEL").
	print "Liquid fuel : "+lqfResIndex.

	//Launch to a 100km orbit
	fh_launch(targetOrbit, targetHeading).
} 

if (core:tag = "r" or core:tag = "c" or core:tag = "l" or core:tag="grasshopper")
{
	// if (core:tag <> "grasshopper")
	// {
	// 	print "Waiting for Stage 2...".
	// 	//Wait until the core have been staged
		WAIT UNTIL stage:number <= 1.
		WAIT UNTIL stage:ready.
		print stage:number.

	// 	if stage:number > 0
	// 	{
	// 		STAGE.
	// 		WAIT UNTIL stage:ready.
	// 	}
	// }

	WAIT 5.

	//Do the boostback and bring that impact point closer to home
	fh_boostback(landingTarget).

	lock steering to srfretrograde.
	rcs on.

	wait until alt:radar <= 50000.

	//Land the core (hopefully) (warranty void in case of RUD)
	run hoverslam.ks(radarOffset, 5, landingTarget).
}