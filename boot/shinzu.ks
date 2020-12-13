
// Shinzu OS splashscreen/bootloader

run "0:boot/faito_init.ks".

local initialBrightness is terminal:brightness.
local offset is 0.1.

clearScreen.
set terminal:brightness to 0.
wait 1.

print "             #          #   " at (terminal:width/2 - 14, offset + 3).
print "          ###        ###    " at (terminal:width/2 - 14, offset + 4).
print "        ####       ####     " at (terminal:width/2 - 14, offset + 5).
print "       ####       ####      " at (terminal:width/2 - 14, offset + 6).
print "      ####       ####       " at (terminal:width/2 - 14, offset + 7).
print "     ####                   " at (terminal:width/2 - 14, offset + 8).
print "    ###############   ##### " at (terminal:width/2 - 14, offset + 9).
print "   ###############   ####   " at (terminal:width/2 - 14, offset + 10).
print "         ####               " at (terminal:width/2 - 14, offset + 11).
print "        ####    #####       " at (terminal:width/2 - 14, offset + 12).
print "       ####      #####      " at (terminal:width/2 - 14, offset + 13).
print "      ####         #####    " at (terminal:width/2 - 14, offset + 14).
print "     ####            ####   " at (terminal:width/2 - 14, offset + 15).
print "    ###                ##   " at (terminal:width/2 - 14, offset + 16).
print "   #                        " at (terminal:width/2 - 14, offset + 17).
print "                            " at (terminal:width/2 - 14, offset + 18).
print "                            " at (terminal:width/2 - 14, offset + 19).
print "        脛ズキ—宇宙船         " at (terminal:width/2 - 14, offset + 20).
print "  Shinzuki Spacecrafts Ltd. " at (terminal:width/2 - 14, offset + 21).
print "    - Shinzu OS v4.23 -     " at (terminal:width/2 - 14, offset + 22).

print "Welcome aboard your " + ship:name at (terminal:width/2 - 10-ship:name:length/2, offset + 24).

from {local i is 0.} until i > initialBrightness step {set i to i+0.01.} do {
    set terminal:brightness to i.
    wait 0.01.
}

print " Press any key to continue  " at (terminal:width/2 - 14, offset + 27).


FROM { local i is 1. } UNTIL ( i >= terminal:height - 1 ) STEP { set i to i+1. } DO
{
	print " ".
}

WAIT UNTIL terminal:input:haschar.