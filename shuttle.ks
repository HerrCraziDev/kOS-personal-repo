switch to 0.
run "boot/faito_init.ks".
runoncepath("libfalcon.ks").

set targetOrbit to 80000.
set targetHeading to 90.

//Find the index of the Liquid Fuel and solid fuel in the AggregateResources resources list
set ID_LiquidFuel to getResourceIndex("LIQUIDFUEL").
set ID_SolidFuel to getResourceIndex("SOLIDFUEL").

//Wait until launch
print "Waiting for launch. Press [SPACE] to start.".
WAIT UNTIL ship:status <> "PRELAUNCH".

on ABORT {
    set throttle to 0.
    unlock steering.
    unlock throttle.
    set ship:control:pilotmainthrottle to 0.
}

sas off.
// set throttle to 1.

//quick and dirty gravity turn
print "Performing gravity turn...".
lock steering to heading(targetHeading, 90 - ( (ship:orbit:apoapsis / targetOrbit)*90) ).

wait until ship:apoapsis > targetOrbit or stage:resources[ID_SolidFuel]:amount < stage:resources[ID_SolidFuel]:capacity/100.
STAGE.

wait until stage:ready.
wait until ship:apoapsis > targetOrbit or  (stage:resources[ID_LiquidFuel]:amount / stage:resources[ID_LiquidFuel]:capacity) * 100 < 4.8.

// set throttle to 0.
// set ship:control:pilotmainthrottle to 0.
wait 0.5.

STAGE.
wait until stage:ready.

print "Done.".