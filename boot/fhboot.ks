switch to 0.
run "boot/faito_init.ks".

WAIT UNTIL ship:verticalspeed < 0.1.

set radarOffset to alt:radar.
set targetOrbit to 100000.

rcs on.
sas off.

lock steering to heading(90, 90 - ( (ship:orbit:apoapsis / targetOrbit)*90) ).

WAIT 1.

RUN hoverslam.ks(alt:radar, 8).