parameter defaultRadarOffset is 7, gearDeployTime is 3, landingTarget is ship:geoposition, groundMargin is 20.

clearscreen.
print "*****************************".
print "*      FAITO Aerospace      *".
print "* XASR-3.1 Autolander Pilot *".
print "* © Empire of Fegeland, 2055*".
print "*****************************".

if defaultRadarOffset <> 7
{
	set radarOffset to defaultRadarOffset.
}

if ship:status = "PRELAUNCH"
{
	set radarOffset to alt:radar.	 							// The value of alt:radar when landed (on gear)
} else if radarOffset = 0 {
	set radarOffset to defaultRadarOffset.
	print "Warning : pilot engaged while in flight, radar offset is set to "+radarOffset.
}


WAIT UNTIL ship:status <> "PRELAUNCH".
WAIT 1.


set throttle to 0.
set ship:control:pilotmainthrottle to 0.

set ship:name to ship:controlpart:tag.

list ENGINES in engs.
set boostbackEngines to ship:partstagged("boostback").

if boostbackEngines:length > 0
{
	for engine in engs
	{
		engine:shutdown().
	}

	for engine in boostbackEngines
	{
		engine:activate().
	}
}

print "Engines configurated for boostback.".

WAIT 0.5.


//Distance from impact point, else vessel's altitude
if addons:tr:available and addons:tr:hasimpact
{
	lock impactDist to addons:tr:impactpos:distance.
} else {
	lock impactDist to alt:radar - radarOffset - groundMargin.
	print "Warning : impact position not available. You should (re)install Trajectories, or maybe takeoff.".
}

lock g to constant:g * body:mass / body:radius^2.						// Gravity (m/s^2)
lock shipVel to ship:velocity:surface:mag.								// Vessel's total velocity
lock maxDecel to (ship:availablethrust / ship:mass) - g.				// Maximum deceleration possible (m/s^2)
lock stopDist to ship:velocity:surface:sqrmagnitude / (2 * maxDecel).	// The distance the burn will require
lock idealThrottle to stopDist / impactDist.							// Throttle required for perfect hoverslam
lock impactTime to impactDist / abs(shipVel).							// Time until impact, used for landing gear

print "Radar offset : " + radarOffset.


when ship:verticalspeed < -1 then
{

	WAIT UNTIL hasnode = 0.
	
	print "Preparing for autolanding...".

	rcs on.
	sas off.
	brakes on.
	//lock steering to srfretrograde.
	// A vector pointing from the current impact position to the target landing site
	lock targetToImpact to (landingTarget:position - addons:tr:impactpos:position).
	lock steering to -ship:velocity:surface - targetToImpact:normalized * min(targetToImpact:mag, ship:velocity:surface:mag / 3). // Glide towards the target, limiting the max. vessel inclination to 30° off-retrograde
	
	when impactTime < gearDeployTime then
	{
		// Deploy landing gear
		gear on.
	}

	when impactDist < stopDist then
	{
		// It's time to start burning
		print "Performing autolanding".

		lock steering to -ship:velocity:surface + targetToImpact:normalized * min(targetToImpact:mag, ship:velocity:surface:mag / 3). // Same as above, but during the landing burn
		lock throttle to idealThrottle.

		when ship:verticalspeed < 0.1 and alt:radar < radarOffset*2 then
		{
			// Final approach phase, reduce throttle to prevent bouncing
			lock steering to -ship:velocity:surface.
			lock throttle to idealThrottle * 0.8.
			print "Landing...".
		}

		when impactTime < 2 then
		{
			lock impactDist to  alt:radar - radarOffset.
			print "Precision approach phase. Impact in 2s.".
		}

		when ship:status = "LANDED" then
		{
			print "Autolanding completed".
			set ship:control:pilotmainthrottle to 0.
			unlock steering.
			brakes off.
			rcs on.
			sas on.
			set SASMODE to "RADIALOUT".
		}
	}
}

on ship:status
{
	print ship:status.
}

UNTIL ship:status = "LANDED"
{
	print "TGT DIST :   " + round((landingTarget:position - addons:tr:impactpos:position):mag, 2) + " m       " at (0, terminal:height - 14).
	print "ALT      :   " + round(ship:altitude, 4) + " m       " at (0, terminal:height - 13).

	print "SRF VEL  :   " + round(shipVel, 4)			 + " m/s              " at (0, terminal:height - 11).
	print "HOR VEL  :   " + round(ship:groundspeed, 4)	 + " m/s              " at (0, terminal:height - 10).
	print "VERT VEL :   " + round(ship:verticalspeed, 4) + " m/s              " at (0, terminal:height - 9).
	print "DESC RATE:   " + round( abs(ship:verticalspeed/ship:groundspeed), 2) + "              " at (0, terminal:height - 8).

	print "IMPACT           :   T+"	+ round(impactTime, 3)	+ " s              " 	at (0, terminal:height - 6).
	print "IMPACT DIST      :   "	+ round(impactDist, 2)	+ " m              " 	at (0, terminal:height - 5).
	print "MAX DECEL        :   "	+ round(maxDecel, 5)	+ " m/s²              " at (0, terminal:height - 4).
	print "S. BURN DIST     :   "	+ round(stopDist, 2)	+ " m              " 	at (0, terminal:height - 3).

	print "THROTTLE :   " + round(idealThrottle*100,2) + " %              " at (0, terminal:height - 1).

	WAIT 0.01.
}

print "Ended.".