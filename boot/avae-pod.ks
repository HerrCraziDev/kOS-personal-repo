
run "boot/faito_init.ks".

print "Starting Avaemanu Subsystem...".

cd("0:").
LIST FILES in files.

for file in files
{
	copypath("0:"+file:name, "1:").
	print "Copying file "+file:name+"...".
}

on ABORT {
	print "ABORTING !".
	sas off.

	lock steering to HEADING(180, 70).
	lock throttle to 1.
	
	when alt:radar > 500 then
	{
		print "Starting descent mode".
		set ship:control:pilotmainthrottle to 0.
		unlock throttle.
		set throttle to 0.

		lock steering to srfretrograde.
		rcs on.

		run "hoverslam.ks"(2,4).
	}
}

print "Avaemanu Subsystem v1.1 started.".

skid:play( note("A7", 0.05, 0.04) ).
WAIT 0.5.

clearscreen.

print "FAITO Aerospace Inc. - Empire of Fegeland".
print "AVAEMANU PROGRAM" at (terminal:width / 2 - 8, terminal:height / 2).
print "MTP Avae Nui 1 Pod" at (terminal:width / 2 - 9, terminal:height / 2 +1).

FROM { local i is 1. } UNTIL ( i >= terminal:height ) STEP { set i to i+1. } DO
{
	print " " at (0, i).
}

WAIT UNTIL terminal:input:haschar.

clearscreen.
print "MTP Avae Nui 1 Pod - FAITO Aerospace".
print "Use Kerboscript commands only, refer to the Documentation FEG-D2-KOS. This device is the property of the Empire of Fegeland. Authorized Kerbals only.".