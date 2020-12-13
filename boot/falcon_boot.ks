
run "0:boot/faito_init.ks".

clearscreen.

print "Falcon Launch System" at (terminal:width / 2 - 10, terminal:height / 2 - 1).
print "FAITO Aerospace Inc." at (terminal:width / 2 - 10, terminal:height / 2 ).
print ship:name at (terminal:width - ship:name:length, terminal:height).
