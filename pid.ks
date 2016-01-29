#Based on http://ksp-kos.github.io/KOS_DOC/tutorials/pidloops.html
clearscreen.

//GO
lock throttle to 1.0.
lock steering to up.
stage.

//Start crude auto-staging
when maxthrust = 0 and stage:number > 0 then {
  stage.
  preserve.
}

//Get above target height
set warpmode to "PHYSICS".
set warp to 3.
wait until altitude > 800.
lock throttle to 0.

//Going down?
lock upness to vdot(ship:velocity:surface, up:forevector).
lock direction to upness / abs(upness).
wait until upness < -1. // and vectorangle((-1)*velocity:surface,ship:facing:forevector) < 5.
print "GOING DOWN".
set warp to 0.

//PID loop setup
set thrott to 0.
lock throttle to thrott.
set setpoint to 0.
//lock vel_scalar to (velocity:surface:mag / (velocity:surface:mag+1) ). //Gives a scalar that aymptotes to 1, hitting 0.97 around 32

//Tuning trident
set Kp to 0.006.
set Ki to 0.0015.
set Kd to 0.0018.

//PID
lock P to direction * (setpoint - velocity:surface:mag). //Proportional (Process)
set I to 0.
set D TO 0.

//Wire the throttle modulator to the PID loop
lock dthrott TO (Kp * P + Ki * I + Kd * D).

set t0 to time:seconds.
set P0 TO P.
until false {

  //Status screen
  print "P: " + P + "      " at (0,6).
  print "I: " + I + "      " at (0,7).
  print "D: " + D + "        " at (0,8).
  print "dthrott: " + dthrott + "      " at (0,9).
  print "thrott: " + thrott + "        " at (0,10).
  
  //Calculate terms 
  set dt to time:seconds - t0.
  if dt > 0 {
    set I to I + P * dt. //Integral
    set D to (P - P0) / dt. //Derivitive
    set t0 to time:seconds.

    //Supress Integral Wind-up
    if Ki > 0 {
        set I to min(1.0/Ki, max(-1.0/Ki, I)).
    }

    //Check toggle
    if not AG1 {

      //Apply modulator
      set thrott to thrott + dthrott.
      print "           " AT (0,11).

    } else {
      print "SUSPENDED" AT (0,11).
    }
  }

  //Clamp throttle
  if thrott > 1 { set thrott to 1. }
  if thrott < 0 { set thrott to 0. }

  wait 0.01.
}

