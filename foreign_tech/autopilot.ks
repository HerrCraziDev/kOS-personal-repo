// A very simple kOS script for hovering.

// Control Flags.
set hovering to false.
set ascending to false.
set descending to false.
set end_program to false.

// Hovering Altitude and Velocity.
set target_alt to 0.
set hover_vel to 0.

// Thrust to Weight Ratios.
set target_twr to 0.
set ascent_twr to 1.5.
set descent_twr to 0.84.
// Couldn't find how to get the gravity from kOS.
set kerbin_g to 9.81.
// Let's just set hovering throttle to max, it's the Kerbal way.
// set hover_twr to 1.8.

lock target_throttle to target_twr*mass*kerbin_g*((kerbin:radius/(kerbin:radius+altitude))*(kerbin:radius/(kerbin:radius+altitude)))/(maxthrust).

print "=== Starting Hover Script ===".
print "===         Usage:        ===".
print "    [3]: Hover,".
print "    [4]: Descend (Cushioned Crash Mode),".
print "    [5]: Ascend,".
print "    [6]: Engines Off (Lithobraking Mode),".
print "    [7]: Exit.".
print "=== Good Luck ===".

// Main Loop.
until end_program = true {
    // "3" to Hover.
    on AG3 {
        if hovering = false {
            set target_alt to apoapsis.
            set hovering to true.
        } else {
            set hovering to false.
        }.               
        print "> Hover Mode Toggle." + "(" + hovering  + ")".
        set ascending to false.
        set descending to false.
        preserve.
    }.
    // "4" to Descend.
    on AG4 {
        if descending = false {
            set descending to true.
        } else {
            set descending to false.
        }.
        print "> Descent Mode Toggle." + "(" + descending  + ")".
        set hovering to false.
        set ascending to false.
        preserve.
    }.
    // "5" to Ascend.
    on AG5 {
        if ascending = false {
            set ascending to true.
        } else {
            set ascending to false.
        }.
        print "> Ascent Mode Toggle." + "(" + ascending  + ")".
        set hovering to false.
        set descending to false.
        preserve.
    }.
    // "6" to Shutdown Engines.
    on AG6 {
        print "> WARNING: ENGINE SHUTDOWN!".
        set ship:control:mainthrottle to 0.
        set hovering to false.
        set ascending to false.
        set descending to false.
    }.
    // "7" to Quit.
    on AG7 {
        set hovering to false.
        set ascending to false.
        set descending to false.
        set end_program to true.
    }.
    // Hover Code.
    until hovering = false {
        // Do you even efficiency?
        // set target_twr to hover_twr.
        set ship:control:mainthrottle to 0.
        wait until ship:verticalspeed <  hover_vel or altitude < target_alt.
        set ship:control:mainthrottle to 1.
        wait until ship:verticalspeed > hover_vel or altitude > target_alt.
    }.
    // Ascent Code.
    until ascending = false {
        set target_twr to ascent_twr.
        set ship:control:mainthrottle to target_throttle.
    }.
    // Descent Code.
    until descending = false {
        set target_twr to descent_twr.
        set ship:control:mainthrottle to target_throttle.
    }.
}.

print "=== Exiting Hover Script (Did you crash yet?) ===".