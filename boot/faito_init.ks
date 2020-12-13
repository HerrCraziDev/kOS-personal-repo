
if not (defined FAITO_INIT_BOOTLOADER) {

	print "Starting...".

	print "GNU/Fegelnix 47.08".
	print "(c) University of Huturoa, Fegeland".

	set terminal:width to 70.
	set terminal:height to 30.

	set skid to GetVoice(0).
	set skid:wave to "square".

	skid:play(
		list(
			note("E4", 0.07, 0.07, 0.35),
			note("F4", 0.07, 0.07, 0.35),
			note("G4", 0.07, 0.07, 0.35),
			note("A4", 0.07, 0.07, 0.35)
		)
	).

	WAIT 2.

	set skid:wave to "sine".
	skid:play( note("A7", 0.05, 0.04) ).

	print "Radar alt. offset measured.".
	set radarOffset to alt:radar.
	sas on.

	WAIT 0.2.


	set lz1 to Kerbin:GEOPOSITIONLATLNG(-0.117035748380029,-74.5502258887207).
	set landingTarget to ship:GEOPOSITION.
	print "Ship position calibrated.".
	skid:play( note("A7", 0.05, 0.04) ).

	switch to 0.


	global FAITO_INIT_BOOTLOADER is true.
} else {
	print "Skipped FAITO Boot initialization".
}

print "FAITO Aerospace - kOS started".