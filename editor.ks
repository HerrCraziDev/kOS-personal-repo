
parameter filepath is "script.ks", exitchar is "²".

set char to "".
set text to list("").
set currentcol to 0.
set currentline to 0.
set topline to 0.
set oldtopline to 0.

lock bottomline to topline + terminal:height - 5.

clearscreen.
print "Loading...".

set hyphens to "-".
set spaces to " ".
from {local i is 0.} until (i >= terminal:width - 1) step {set i to i+1.} do
{
    set hyphens to hyphens + "-".
    set spaces to spaces + " ".
}

if exists(filepath)
{
    set file to open(filepath).
    if file:isfile
    {
        set it_file to file:readall:iterator.

        until not it_file:next
        {
            text:add(it_file:value).
        }
    }
}

//print "KerboScript Editor".
print filepath at (terminal:width - filepath:length, 0).
print hyphens at (0,1).
print hyphens at (0, terminal:height - 2).

function redraw
{
    //clearscreen.
    print "KerboScript Editor" at (0,0).
    print filepath at (terminal:width - filepath:length, 0).
    print hyphens at (0,1).

    local i is topline.
    until i > bottomline or i >= text:length
    {
        print i + "  " at (0, i - topline + 2).
        print text[i]:substring(0, min(text[i]:length, terminal:width - 4)) + spaces:substring(0,terminal:width - 4 - min(text[i]:length, terminal:width - 4)) at (4, i - topline + 2).

        set i to i+1.
    }

    print hyphens at (0, terminal:height - 2).
    print "Line "+currentline+", col. "+currentcol+"      " at (0, terminal:height - 1).
}

function redrawline
{
    parameter line.

    //print line at (0, line - topline + 2).
    print text[line]:substring(0, min(text[line]:length, terminal:width - 4)) + spaces:substring(0,terminal:width - 4 - min(text[line]:length, terminal:width - 4)) at (4, line - topline + 2).

    //print hyphens at (0, terminal:height - 2).
    print "Line "+currentline+", col. "+currentcol+"      " at (0, terminal:height - 1).
}

redraw().

until char = "²"
{
    if terminal:input:haschar
    {
        set char to terminal:input:getchar.

        if char = terminal:input:enter
        {
            if currentline + 2 > text:length
            {
                text:add("").
            } else {
                text:insert(currentline + 1, "").
            }
            set currentcol to 0.
            set currentline to currentline + 1.

            redraw().
        } else if char = terminal:input:upcursorone and currentline > 0 {
            redrawline(currentline).
            set currentline to currentline - 1.
            set currentcol to min(currentcol, text[currentline]:length).
        } else if char = terminal:input:downcursorone and currentline + 1 < text:length {
            redrawline(currentline).
            set currentline to currentline + 1.
            set currentcol to min(currentcol, text[currentline]:length).
        } else if char = terminal:input:leftcursorone {
            if currentcol <= 0 and currentline > 0 {
                redrawline(currentline).
                set currentline to currentline - 1.
                set currentcol to text[currentline]:length.
            } else if currentcol > 0 {
                set currentcol to currentcol - 1.
            }
        } else if char = terminal:input:rightcursorone {
            if currentcol >= text[currentline]:length and currentline + 1 < text:length {
                redrawline(currentline).
                set currentline to currentline + 1.
                set currentcol to 0.
            } else if currentcol < text[currentline]:length {
                set currentcol to currentcol + 1.
            }
        } else if char = terminal:input:backspace {
            if text[currentline]:length > 0 and currentline > 0{
                set currentcol to currentcol - 1.
                set text[currentline] to text[currentline]:substring(0,text[currentline]:length - 1).
            } else {
                set currentline to currentline - 1.
                set currentcol to text[currentline]:length.
                text:remove(currentline + 1).

                redraw().
            }
        } else if char = exitchar {
            //Do nothing but this will prevent the exit char to be added in the editor
        } else {
            set text[currentline] to text[currentline]:substring(0,currentcol) + char .
            set currentcol to currentcol + 1.
        }

        if currentline > bottomline
        {
            set topline to topline + 1.
        } else if currentline < topline {
            set topline to topline - 1.
        }

        //Redraw only if the top line have changed (ie. the editor needs to scroll up or down)
        if oldtopline <> topline
        {
            redraw().
        } else {
            redrawline(currentline).
        }

        set oldtopline to topline.
    }

    if mod( round(time:seconds,1)*10, 2)
    {
        print "█" at (currentcol + 4, currentline - topline + 2).
    } else {
        print " " at (currentcol + 4, currentline - topline + 2).
    }

    WAIT 0.01.
}

clearscreen.
print "File " + filepath + " edited and saved.".
