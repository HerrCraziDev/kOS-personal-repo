//getLandingSite(String siteName)
//	Return the GeoPosition of the site matching siteName, or the current vessel's position if not found
function getLandingSite
{
	parameter name is "auto".

	if name = "auto"
	{
		return ship:geoposition.
	}
	else if name = "LZ-1"
	{
		return Kerbin:GEOPOSITIONLATLNG(-0.117035748380029,-74.5502258887207).
	}
	else if name = "LZ-2"
	{
		return LATLNG(-0.15345044141426, -74.4820354877508).
	}
	else
	{
		return VESSEL(name):geoposition.
	}
}

//launch(Scalar targetOrbit [, Scalar targetHeading])
//	Launch to an orbit which apoapsis is targetOrbit and prograde direction is targetHeading
function fh_launch
{
	parameter targetOrbit is 80000.
	parameter targetHeading is 90.

	sas off.

	//quick and dirty gravity turn
	print "Performing gravity turn...".

	if (targetOrbit < 80000) {
		ABORT ON.
		print "ERROR: Target orbit too low".
	}

	lock steering to heading(targetHeading, 90 - ( (ship:orbit:apoapsis / targetOrbit)*90) ).

	if (stage:resources[lqfResIndex]:amount = 0 and stage:resources[lqfResIndex]:capacity = 0)
	{
		lock liquidFuelAmount to getCurrentLiquidFuelAmount().
		lock liquidFuelCapacity to max(getCurrentLiquidFuelCapacity(), 0.0000001).
		print "Warning: Wrong fuel metric, using fallback".
	} else {
		lock liquidFuelAmount to stage:resources[lqfResIndex]:amount.
		lock liquidFuelCapacity to max(stage:resources[lqfResIndex]:capacity, 0.0000001).
	}

	//when to stop for the boostback (making sure there is enough fuel to perform the boosback)
	when ship:orbit:apoapsis >= targetOrbit or (liquidFuelAmount < liquidFuelCapacity/3 and liquidFuelAmount > 0) then 
	{
		rcs on.

		print ship:orbit:apoapsis + " / " + targetOrbit.
		print liquidFuelAmount + " / " + liquidFuelCapacity.
		
		print "Staging side cores.".
		set ship:control:pilotmainthrottle to 0.
		set throttle to 0.

		STAGE.
		//wait until stage:ready.

		rcs on.
		lock steering to heading(targetHeading, 90 - ( (ship:orbit:apoapsis / targetOrbit)*90) ).

		//Clear the center core
		wait 2.
		from {local i is 0.} until (i >= 1) step {set i to i + 0.01.} do
		{
			set throttle to i.
			wait 0.01.
		}

		print "Final burn to target AP.".
	}

	UNTIL ship:orbit:apoapsis >= targetOrbit
	{
		print "Lq. fuel : " + round(liquidFuelAmount) + " / " + round(liquidFuelCapacity) + "   " at (0, terminal:height-5).

		print "PRCT: " + round( max( ship:orbit:apoapsis*100/targetOrbit, 100 - 100*((liquidFuelAmount - liquidFuelCapacity/3)/(2*liquidFuelCapacity/3)) ) , 1) + "%   " at (0, terminal:height-3).
		print "ALT : " + round(ship:altitude, 3) + "m      " at (0, terminal:height-2).
		print "AP  : " + round(ship:orbit:apoapsis, 3) + "m     " at (0, terminal:height-1).

		wait 0.1.
	}

	set throttle to 0.
	set ship:control:pilotmainthrottle to 0.
	unlock all.

	rcs on.
	sas on.

	print "Launch complete, apoapsis : "+round(ship:apoapsis, 2).
}

//boostback(GeoPosition landingTarget)
//	Do a boostback burn, attempting to bring the impact point as closest as possible from landingTarget
function fh_boostback
{
	parameter landingTarget.

	print "Boostback phase started".

	skid:play( note(880, 0.04) ).
	WAIT 0.02.
	skid:play( note(880, 0.04) ).

	set ship:control:pilotmainthrottle to 0.

	sas off.
	rcs on.

	lock throttle to 0.
	lock burnVect to landingTarget:position - addons:tr:impactpos:position.	//The direction between impact point and landing site
	lock impactDistToTarget to burnVect:mag.								//Distance between impact point and landing site

	//Move slightly backwards to clear from the second stage's engine flame
	//set ship:control:top to 1.
	//wait 3.

	//Point the right direction for boostback
	lock steering to burnVect.

	print "Pointing the right direction".

	//Wait until the vessel is stabilized in the right direction
	from {local i is 3.} until (i = 0) step {set i to i-1.} do
	{
		WAIT UNTIL VANG(ship:facing:vector, burnVect) < 5.
		WAIT 0.5.
	}

	//Execute the boostback burn
	print "Performing boostback burn.".

	lock throttle to min(impactDistToTarget/5000, 1).

	local prevDist is impactDistToTarget +1000.

	UNTIL impactDistToTarget < 10 or ( prevDist < impactDistToTarget and impactDistToTarget < 200 )
	{
		set prevDist to impactDistToTarget.
		print "IMPCT-TRGT DIST. : "+round(impactDistToTarget, 3)+"        " at (0,terminal:height-2).
		WAIT 0.01.
	}

	//Release everything and give the control back
	unlock steering.
	set ship:control:neutralize to true.
	
	unlock throttle.
	set throttle to 0.
	set ship:control:pilotmainthrottle to 0.

	rcs off.
	sas on.

	print "Boostback burn completed.".
}

function fh_glide
{
	parameter landingTarget.

	print "Re-entry gliding".

	lock steering to -ship:velocity:surface - (landingTarget:position - addons:tr:impactpos:position).
}

function LandPID_Init
{
	//global LandPID is 
}

function LandPID_getSteering
{
	parameter t is time:seconds.
}

//getResourceIndex(Strin resourceName)
//	Get the index of the resource named resourceName in the resources list
function getResourceIndex
{
	local parameter resourceName.

	set itResources to stage:resources:iterator.

	UNTIL NOT itResources:next()
	{
		if itResources:value:name = resourceName
		{
			return itResources:index.
		}
	}
}

function getCurrentStageResource
{
	local parameter resourceName.

	if ( defined elapsedTime = true and (time:seconds - elapsedTime) < 1 )
	{
		return cachedAmount.
	}

	//local startTime is time:seconds.

	global stageResAmount is 0.
	global stageResCapacity is 0.

	list resources in reslist.

	for res in reslist
	{
		if res:name = resourceName
		{
			set partsWithRes to res:parts.
		}
	}
	//print partsWithRes.

	for prt in partsWithRes
	{
		//print prt:stage.
		if prt:stage = -1
		{
			for partRes in prt:resources
			{
				if partRes:name = resourceName
				{
					set stageResAmount to stageResAmount + partRes:amount.
					set stageResCapacity to stageResCapacity + partRes:capacity.
				}
			}
		}
	}

	global elapsedTime is time:seconds.
	global cachedAmount is stageResAmount.
	global cachedCapacity is stageResCapacity.

	return stageResAmount.
}

function getCurrentLiquidFuelAmount
{
	return getCurrentStageResource("LIQUIDFUEL").
}

function getCurrentLiquidFuelCapacity
{
	getCurrentStageResource("LIQUIDFUEL").
	return stageResCapacity.
}
