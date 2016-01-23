//Status Display
clearscreen .
when true then {
  print "Mun: " + round(mun:distance / 1000) + "Km                    " AT (0, 5).
  print "ETA Transition: " + round(eta:transition) + "s                    " AT (0,6).
  preserve.
}

print "[ Waiting for Mun to get close ( <11,678 Km ) ]                    " AT (0,4).
set warp to 5.
set lastd to round(mun:distance).
until mun:distance < 11678000 {
  if abs(mun:distance - lastd) > 100 {
    set lastd to round(mun:distance).
    print "Mun: " + lastd + "m                    " AT (0, 5).
  }
}
set warp to 0.

print "[ Counting down ]                    " AT (0,4).
lock throttle to 1.0.
lock steering to up.
from {local countdown is 3.} until countdown = 0 step {set countdown to countdown - 1.} do {
  print "..." + countdown.
  wait 1.
}
stage.

//Start crude auto-staging
when maxthrust = 0 and stage:number > 0 then {
  stage.
  preserve.
}

print "[ Flying straight up until 75000 ]                    " AT (0,4).
set warpmode to "PHYSICS".
set warp to 3.
wait until altitude > 75000.
set warp to 0.
lock throttle to 0.
wait 1.
lock steering to heading(90.0,0).
wait 2.
stage.

print "[ Praying for encounter ]                    " AT (0,4).
lock throttle to 1.0.
wait 5.
set warpmode to "PHYSICS".
set warp to 3.
wait until apoapsis > 11000000.
set warp to 0.
wait until orbit:transition = "ENCOUNTER".
lock throttle to 0.
wait 5.

print "[ Waiting for SOI transition ]                    " AT (0,4).
set warpmode to "RAILS".
warpto(time:seconds + eta:transition + 60).
lock steering to retrograde.
lock throttle to 1.0.
wait until periapsis < 0.
lock throttle to 0.

print "[ Hello Mun! ]                    " AT (0,4).
set warp to 0.
wait 5.
set warpmode to "RAILS".
set warp to 5.
wait until alt:radar < 50000.
set warp to 3.
wait until alt:radar < 20000.
set warp to 0.

print "[ Dropping surface velocity for landing ]" AT (0,4).
lock steering to (-1)*velocity:surface.
lock throttle to 1.
wait until velocity:surface:mag < 5.
lock throttle to 0.

print "[ Descending ]                    " AT (0,4).
wait 5.
set warpmode to "RAILS".
set warp to 4.
wait until altitude < 100000.
set warp to 0.
wait 5.
set warpmode to "PHYSICS".
set warp to 3.
wait until alt:radar < 800.

when velocity:surface:mag > 5 then {
  set t to throttle.
  lock throttle to t + 0.01.
  preserve.
}

when velocity:surface:mag < 4 then {
  lock throttle to 0.
  preserve.
}

wait until alt:radar < 100.
set warp to 0.

wait until altitude < 0.
