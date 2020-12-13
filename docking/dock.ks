//***********************************/
//*		  Auto-docking system		*/
//*				  -					*/
//* © FAITO Aerospace Inc. - 2059   */
//***********************************/

//	Author : HerrCrazi  -  License : GNU GPL 3.0

// This program is distributed by FAITO Aerospace and the Feguan Open Source Foundation under a GNU GLP 3.0 license,
// as part of the National Open-source Initiative of 2096.
// GNU Fegelnix, DRACO OS and the FRS program belongs to their respective licensers (University of Huturoa, Shur'tugal Ltd. and FAITO Aerospace)

// v1.3.7


parameter debug is false.	//Set this to true to see some vectors on the screen showing the ship's speed & position

runOncePath("libutils.ks").



clearvecdraws().
clearscreen.

print "***********************************".
print "*       Auto-docking system       *".
print "*                -                *".
print "* © FAITO Aerospace Inc. - 2059   *".
print "***********************************".



// PID control loops controlling speed along the three axis
set PID_y to pidloop(10,0,5,-1,1).
set PID_y:setpoint to 0.

set PID_z to pidloop(10,0,5,-1,1).
set PID_z:setpoint to 0.

set PID_x to pidloop(10,0,5,-1,1).
set PID_x:setpoint to 0.

rcs on.
sas off.



if defined target and target:targetable
{
	set trgt to target.
	print "Docking to : " + trgt:name.


	//Lock steering to the same orientation than the target's port, but in the opposite direction (so the ship is facing the target port)
	lock steering to lookdirup(-trgt:portfacing:forevector, trgt:portfacing:upvector).
	wait until vang(ship:facing:forevector, -trgt:portfacing:forevector) < 1 and vang(ship:facing:upvector, trgt:portfacing:upvector) < 5.

	//Target-centered base, with the x axis pointing forward out of the target
	lock vtx to trgt:portfacing:forevector.
	lock vty to trgt:portfacing:upvector.		//y axis is straight up out of the target
	lock vtz to trgt:portfacing:rightvector.	//z axis is starboard out of the target

	//Ship and target position in SHIP-RAW coordinates
	lock spos to ship:position.
	lock tpos to trgt:position.

	lock targetVel to trgt:ship:velocity:orbit - ship:velocity:orbit.	//Target-relative velocity

	//Declared here for the when statement below and for clarification (req. by Spartwo)
	declare trgt_x is 1.	// X component of the ship --> target position vector (distance to the target along X)
	declare trgt_y is 1.	// Y component of the ship --> target position vector (distance to the target along Y)
	declare trgt_z is 1.	// Z component of the ship --> target position vector (distance to the target along Z)
	declare Kx is 0.		// Desired speed along X
	declare Ky is 0.		// Desired speed along Y
	declare Kz is 0.		// Desired speed along Z

	set stop to false.
	set continue to true.

	// Modes:
	// 3 - Plane matching (if we're behind the docking port, move to the other side to avoid docking from BEHIND a docking port which is NOT recommended)
	// 2 - Alignment
	// 1 - Approach (keep alignment and control forward speed)
	set runmode to 3.
	
	// AG1 toggles ALL correction burns
	on AG1
	{
		toggle stop.
	}

	// ABORT terminates the program and releases the controls
	on ABORT
	{
		set continue to false.
		print "Docking aborted, controls released.".
	}

	//At this point we're aligned with the target, it's time to burn forward
	when ( abs(trgt_z) < 0.1 and abs(trgt_y) < 0.1 ) then
	{
		set Kx to 0.4.
		set runmode to 1.
		return false.
	}

	// Once we're ahead of the plane of the target, start to align the two ports
	when ( trgt_x > 2 ) then
	{
		set runmode to 2.
		return false.
	}

	until ( continue = false and trgt:state <> "Ready" and trgt:state <> "PreAttached" )//Press AG1 to stop at any moment
	{
		set v_ShipToTarget to tpos - spos.	//A vector going from the ship to the target

		//Convert the position vector of the ship relative to the target from SHIP-RAW to target-relative coordinates
		set trgt_x to getSignedMag(vtx * vprojs(v_ShipToTarget, vtx), vtx).
		set trgt_y to getSignedMag(vty * vprojs(v_ShipToTarget, vty), vty).
		set trgt_z to getSignedMag(vtz * vprojs(v_ShipToTarget, vtz), vtz).
		//Same for their relative velocity
		set targetVel_x to -getSignedMag(vtx * vprojs(targetVel, vtx), vtx).
		set targetVel_y to -getSignedMag(vty * vprojs(targetVel, vty), vty).
		set targetVel_z to -getSignedMag(vtz * vprojs(targetVel, vtz), vtz).

		//Draw some fancy vectors
		if debug
		{
			SET vdt TO VECDRAW(trgt:position, (-trgt:portfacing:forevector) * 5, yellow, "Trgt", 1, true).
			SET vds TO VECDRAW(V(0,0,0), (ship:facing:forevector) * 5, yellow, "Ship", 1, true).

			set x to VECDRAW( V(0,0,0),-vtx * trgt_x , red, "x", 1, true, 0.1).
			set y to VECDRAW( -vtx * trgt_x, -vty * trgt_y , green, "y", 1, true, 0.1).
			set z to VECDRAW( -vtx * trgt_x - vty * trgt_y,  -vtz * trgt_z , blue, "z", 1, true, 0.1).

			set tx to VECDRAW( V(0,0,0), -vtx * targetVel_x * 10, red, "Tx", 1, true, 0.05).
			set ty to VECDRAW( V(0,0,0), -vty * targetVel_y * 10, green, "Ty", 1, true, 0.05).
			set tz to VECDRAW( V(0,0,0), -vtz * targetVel_z * 10, blue, "Tz", 1, true, 0.05).
		}


		//Apply PID corrections
		if runmode <> 3 {	// Apply corrections
			set Ky to min(max(trgt_y/5,-1),1).
			set Kz to min(max(trgt_z/5,-1),1).
		} else {			// Not yet ahead of the target plane
			set Ky to 0.
			set Kz to 0.
		}

		// Forward (x) speed setpoints for different runmodes
		if runmode = 3 and trgt_x < 2 {
			set Kx to -1.		// We're behind the dp. plane, move backwards
		} else if runmode = 2 {
			set Kx to 0.		// Waiting for alignment with dp., stand still
		} else if runmode = 1 {
			set Kx to 0.3.		// Final approach, slowly moving towards the dp.
		}

		if stop {	// Release controls
			set ship:control:top to 0.
			set ship:control:starboard to 0.
			set ship:control:fore to 0.
			set ship:control:neutralize to true.
		} else {	// Apply PID setpoints, update PID loops and apply corrections to RCS cooked controls
			set PID_y:setpoint to Ky.
			set ship:control:top to -PID_y:update(time:seconds, targetVel_y).

			set PID_z:setpoint to Kz.
			set ship:control:starboard to PID_z:update(time:seconds, targetVel_z).

			set PID_x:setpoint to Kx.
			set ship:control:fore to PID_x:update(time:seconds, targetVel_x).
		}
		


		//Print stuff
		if stop {
			print "Mode     : " + runmode + " [STOP]" at (0, terminal:height - 11).
		} else {
			print "Mode     : " + runmode + "       " at (0, terminal:height - 11).
		}

		print "Corr. X  : " + round(PID_x:output,3) + " (" + round(Kx,2) + ")      " at (0, terminal:height - 9).
		print "Corr. Y  : " + round(PID_y:output,3) + " (" + round(Ky,2) + ")      " at (0, terminal:height - 8).
		print "Corr. Z  : " + round(PID_z:output,3) + " (" + round(Kz,2) + ")      " at (0, terminal:height - 7).
 
		print "Vel. X   : " + round(targetVel_x, 3) + "m/s      " at (terminal:width / 2, terminal:height - 9).
		print "Vel. Y   : " + round(targetVel_y, 3) + "m/s      " at (terminal:width / 2, terminal:height - 8).
		print "Vel. Z   : " + round(targetVel_z, 3) + "m/s      " at (terminal:width / 2, terminal:height - 7).

		print "Dist.    : " + round(trgt_x, 3) + "m      " at (0, terminal:height - 5).
		print "Up       : " + round(trgt_y, 3) + "m      " at (0, terminal:height - 4).
		print "Right    : " + round(trgt_z, 3) + "m      " at (0, terminal:height - 3).

		print "Rel. ang : "+round(vang( (-trgt:portfacing:forevector), ship:facing:forevector ), 2) at (0, terminal:height - 1).
		wait 0.1.
	}

	unlock all.
	set ship:control:neutralize to true.

	sas on.
	clearvecdraws().
} else {
	print "No dockable target selected.".
}