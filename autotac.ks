
runOncePath("libpilot.ks").
clearScreen.

set stop to false.

on AG9 {
    set stop to true.
}

setThrustAttitudeController().

until stop {
    updateThrustAttitudeController().
    WAIT 0.01.
}

clearVecDraws().
stopThrustAttitudeController().