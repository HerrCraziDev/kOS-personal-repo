

runOncePath("libutils.ks").

set thrustVectors to lexicon().
set tacPID to pidLoop().
set debugTAC to false.


// Returns the current torque applied on the ship by all the engines' thrusts
function getThrustTorque {

    // Draw thrust vectors for engines assigned to TAC
    if debugTAC {
        clearVecDraws().
        for engine in ship:partsTagged("fore"){
            set engineTorque to vcrs(engine:position, engine:facing:forevector * engine:thrust).
            set thrustVectors[engine:cid] to vecDraw(engine:position, engine:facing:forevector * (engine:thrust/20), green, "fore", 2, true).
        }

        for engine in ship:partsTagged("aft"){
            set engineTorque to vcrs(engine:position, engine:facing:forevector * engine:thrust).
            set thrustVectors[engine:cid] to vecDraw(engine:position, engine:facing:forevector * (engine:thrust/20), blue, "aft", 2, true).
        }
    }

    // Sum the torque of all active thrusting engines
    set totalTorque to v(0,0,0).
    list engines in engines.
    for engine in engines {
        set totalTorque to totalTorque + vcrs(engine:position, engine:facing:forevector * engine:thrust).
    }

    // Draw a torque vector for the total thrust torque
    if debugTAC {
        set torqueVector to vecDraw(v(0,0,0), vproj(totalTorque, ship:facing:rightvector)/2, red, "Torque", 2, true).
    }

    return totalTorque.
}


// ******************************************
// *             TAC functions              *
// *        (Thrust Attitude Control)       *
// * Allows balancing or steering a ship    *
// * only by controlling the thrust of it's *
// * engines.                               *
// ******************************************

// Initializes TAC
function setThrustAttitudeController {
    parameter p is 0.1.
    parameter i is 0.
    parameter d is 0.
    parameter foreTag is "fore".
    parameter aftTag is "aft".

    set tacPID to pidLoop(p, i, d).
    set tacPID:setpoint to 0.
}

// Updates and applies TAC corrections to the engines used for TAC
function updateThrustAttitudeController {
    parameter timestamp is time:seconds.

    // Get the current maximum limit which is set across all our engines
    set maxCurrentLimit to 0.
    for engine in ship:partstagged("fore") {
        set maxCurrentLimit to max(maxCurrentLimit, engine:thrustlimit).
    }
    for engine in ship:partstagged("aft") {
        set maxCurrentLimit to max(maxCurrentLimit, engine:thrustlimit).
    }

    // Factor used to multiply the subsequent limits so the engines which are thrusting the more are clamped at 100%
    // Engines tagged "fore" and "aft" should always be thrusting as much as they can while keeping the torque at 0.
    set maxThrOffsetFactor to 100/maxCurrentLimit.

    set torqueErr to vprojs(getThrustTorque(), ship:facing:rightvector).
    set corr to tacPID:update(timestamp, torqueErr).

    for engine in ship:partstagged("fore") {
        set engine:thrustlimit to fit(0, engine:thrustlimit - corr, 100) * maxThrOffsetFactor.
    }
    for engine in ship:partstagged("aft") {
        set engine:thrustlimit to fit(0, engine:thrustlimit + corr, 100) * maxThrOffsetFactor.
    }

    print "Torque corr.  : " + round(corr, 2) + "%      " at (0, terminal:height - 2).
    print "Torque error  : " + round(torqueErr, 2) + "kNm      " at (0, terminal:height - 1).
}

// Stops TAC and restore engines to their max thrust limits
function stopThrustAttitudeController {
    for engine in ship:partstagged("fore") {
        set engine:thrustlimit to 100.
    }
    for engine in ship:partstagged("aft") {
        set engine:thrustlimit to 100.
    }
}