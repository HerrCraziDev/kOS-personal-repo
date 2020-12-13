SET V0 TO GetVoice(0).
V0:PLAY( NOTE( 440, 1) ).  // Play one note at 440 Hz for 1 second.

// Play a 'song' consisting of note, note, rest, sliding note, rest:
V0:PLAY(
    LIST(
        NOTE("A#4", 0.2,  0.25), // quarter note, of which the last 0.05s is 'release'.
        NOTE("A4",  0.2,  0.25), // quarter note, of which the last 0.05s is 'release'.
        NOTE("R",   0.2,  0.25), // rest
        SLIDENOTE("C5", "F5", 0.45, 0.5), // half note that slides from C5 to F5 as it goes.
        NOTE("R",   0.2,  0.25)  // rest.
    )
).