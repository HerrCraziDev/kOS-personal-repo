

// Projects 'a' along 'b' as a scalar (ie. how much of 'b' is in 'a')
function vprojs
{
	parameter a.
	parameter b.

	return vdot(a, b) / b:mag.
}

// Projects 'a' along 'b' as a vector
function vproj
{
	parameter a.
	parameter b.

	return (vdot(a, b) / b:mag) * (b / b:mag).
}

// clamps (and truncates) an input in a [min,max] interval
function fit {
    parameter minimum.
    parameter val.
    parameter maximum.

    return max(min(val, maximum), minimum).
}

// Returns the signed magnitude of a vector against the orthogonal plane defined by a second vector
function getSignedMag
{
	parameter vect.
	parameter baseVect.

	local vangle is vang(vect, baseVect).
	if ( vangle > 90 and vangle < 270 )
	{
		return vect:mag.
	} else {
		return -vect:mag.
	}
}