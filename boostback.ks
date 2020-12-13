
parameter target is ship:geoposition.


runoncepath("libfalcon.ks").

fh_boostback(target).

set throttle to 0.
set ship:control:pilotmainthrottle to 0.
set ship:control:neutralize to true.