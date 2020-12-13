clearscreen.
print "*****************************".
print "*      FAITO Aerospace      *".
print "* XASR-3.1 Autolander Pilot *".
print "* © Empire of Fegeland, 2055*".
print "*****************************".

set gearDeployTime to 6.

if abs(ship:verticalspeed) < 1
{
	set radarOffset to alt:radar.	 							// The value of alt:radar when landed (on gear)
} else if radarOffset = 0 {
	set radarOffset to 7.
	print "Warning : pilot engaged while in flight, radar offset will be set to 7 (XASR-3).".
}

lock trueRadar to alt:radar - radarOffset.					// Offset radar to get distance from gear to ground
lock g to constant:g * body:mass / body:radius^2.			// Gravity (m/s^2)
lock maxDecel to (ship:availablethrust / ship:mass) - g.	// Maximum deceleration possible (m/s^2)
lock stopDist to ship:verticalspeed^2 / (2 * maxDecel).		// The distance the burn will require
lock idealThrottle to stopDist / trueRadar.					// Throttle required for perfect hoverslam
lock impactTime to trueRadar / abs(ship:verticalspeed).		// Time until impact, used for landing gear

print "Radar offset : " at (0, terminal:width).
print radarOffset at (16, terminal:width).

WAIT UNTIL ship:verticalspeed < -1.
	print "Preparing for autolanding...".

	rcs on.
	sas off.
	brakes on.
	lock steering to srfretrograde.

	when impactTime < gearDeployTime then 
	{
		gear on.
	}

	when ship:groundspeed < 1 or ship:verticalspeed < 5 then
	{
		lock steering to Up.
	}


WAIT UNTIL trueRadar < stopDist.
	print "Performing autolanding".
	lock throttle to idealThrottle.

WAIT UNTIL ship:verticalspeed > -0.01.
	print "Autolanding completed".
	set ship:control:pilotmainthrottle to 0.
	rcs off.