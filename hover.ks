
parameter p is 1, i is 1, d is 1, targetAlt is -1, targetVSpeed is -2.

// Values for a Grasshopper or Falcon 1 : 35, 0, 2000
//			  a Jet Quadcopter : 
 
local oY is 10.	// Vertical offset for flight display

clearscreen.
print "*****************************".
print "*      FAITO Aerospace      *".
print "*  XASR-3.1 Hovering Pilot  *".
print "*      -- HerrCrazi --      *".
print "*****************************".
print "".
print "[AG1] Nullify Speed".
print "[AG2] Target Set Alt. (" + targetAlt +")".
print "".
print "[ABORT] Land".
print "".


if ship:status = "PRELAUNCH"
{
	set radarOffset to alt:radar.	 							// The value of alt:radar when landed (on gear)
} else {
	set radarOffset to 7.35.
	print "Warning : pilot engaged while in flight, radar offset will be set to 7 (XASR-3).".
}


set old_err to 0.
set err to 0.
set int_err to 0.
set d_err to 0.

set runmode to 0.

lock trueRadar to alt:radar - radarOffset.					// Offset radar to get distance from gear to ground
lock g to constant:g * body:mass / body:radius^2.			// Gravity (m/s^2)
lock hoverThrottle to ((ship:mass * g) - (err * p + int_err * i + d_err * d)) / ship:availablethrust.


sas on.
rcs on.

ON ABORT
{
	unlock THROTTLE.
	set ship:control:pilotmainthrottle to 0. 
	
	set runmode to 10.
}

ON AG1
{
	set runmode to 1.
}

ON AG2
{
	if targetAlt = -1 {
		set targetAlt to trueRadar.
		print "/!\ Target alt. was default, set to current ship alt.".
	}
	set runmode to 2.
}

UNTIL runmode = -1
{
	if runmode = 1
	{
		lock THROTTLE to hoverThrottle.

		set err to (targetVSpeed - ship:verticalspeed).
		set int_err to int_err + err.
		set d_err to err - old_err.

		set old_err to err.

		print "Tgt. Vrt: " + round(targetVSpeed) + " ms   "	at (0, oy - 1).

		print "P err   : "+ round(err, 5) + "     " 		at (0, oY + 1).
		print "I err   : "+ round(int_err, 5) + "     " 	at (0, oY + 2).
		print "D err   : "+ round(d_err, 5) + "     " 		at (0, oY + 3).

		print "P corr  : "+ round(p*err, 5) + "     " 		at (0, oY + 5).
		print "I corr  : "+ round(i*int_err, 5) + "     " 	at (0, oY + 6).
		print "D corr  : "+ round(d*d_err, 5) + "     " 	at (0, oY + 7).

		print "Throttle:" + round(THROTTLE, 5) 				at (0, oY + 9).
	}
	else if runmode = 2
	{
		lock THROTTLE to hoverThrottle.

		set err to (trueRadar - targetAlt).
		set int_err to int_err + err.
		set d_err to err - old_err.

		set old_err to err.

		print "Tgt. Alt: " + round(targetAlt) + " m   "		at (0, oy - 1).

		print "P err   : "+ round(err, 5) + "     " 		at (0, oY + 1).
		print "I err   : "+ round(int_err, 5) + "     " 	at (0, oY + 2).
		print "D err   : "+ round(d_err, 5) + "     " 		at (0, oY + 3).

		print "P corr  : "+ round(p*err, 5) + "     " 		at (0, oY + 4).
		print "I corr  : "+ round(i*int_err, 5) + "     " 	at (0, oY + 5).
		print "D corr  : "+ round(d*d_err, 5) + "     " 	at (0, oY + 6).

		print "Throttle:" + round(THROTTLE, 5) 				at (0, oY + 9).
	}
	else if runmode = 10
	{
		run hoverslam.ks(radarOffset,4, landingTarget).

		print "[hover.ks] Landing completed. Exiting.".
		set runmode to -1.
	}


	WAIT 0.001.
}
