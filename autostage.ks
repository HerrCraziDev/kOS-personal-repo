LIST ENGINES IN elist.

UNTIL false {
    PRINT "Stage: " + STAGE:NUMBER AT (0,0).
    FOR e IN elist {
        IF e:FLAMEOUT {
            STAGE.
            PRINT "STAGING!" AT (0,0).

            UNTIL STAGE:READY {
                WAIT 0.
            }

            LIST ENGINES IN elist.
            CLEARSCREEN.
            BREAK.
        }
    }
}