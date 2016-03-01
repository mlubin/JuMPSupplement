We test on the nonlinear beam control problem from Hans Mittelmann's [AMPL-NLP benchmark set](http://plato.asu.edu/ftp/ampl-nlp.html). We test with ``n = 5000, 50000, 500000``. The model has ``3n`` variables, ``2n`` constraints, and a diagonal Hessian.

See the README for acpower for instructions on recording the timings.

## Julia
```
$ julia clnlbeam.jl 5000 | ts -s "%.s"

$ julia clnlbeam.jl 50000 | ts -s "%.s"

$ julia clnlbeam.jl 500000 | ts -s "%.s"
```

## AMPL
```
$ ampl clnlbeam-5000.mod | ts -s "%.s"

$ ampl clnlbeam-50000.mod | ts -s "%.s"

$ ampl clnlbeam-500000.mod | ts -s "%.s"
```

## Pyomo
```
$ pyomo solve --solver=asl:ipopt --stream-output --solver-options="max_iter=3" clnlbeam.py clnlbeam-5000.dat | ts -s "%.s"

$ pyomo solve --solver=asl:ipopt --stream-output --solver-options="max_iter=3" clnlbeam.py clnlbeam-50000.dat | ts -s "%.s"

$ pyomo solve --solver=asl:ipopt --stream-output --solver-options="max_iter=3" clnlbeam.py clnlbeam-500000.dat | ts -s "%.s"
```

## GAMS
```
$ gams clnlbeam-5000.gms lo=3 | ts -s "%.s"

$ gams clnlbeam-50000.gms lo=3 | ts -s "%.s"

$ gams clnlbeam-500000.gms lo=3 | ts -s "%.s"
```

## YALMIP
To generate the YALMIP nonlinear model, start MATLAB and run the ``doyalmip`` script. Ensure that YALMIP can be found in the current MATLAB session (e.g. run ``addpath(genpath('/home/mlubin/yalmip'))``). The timing results will print to screen.

```
$ matlab -nodisplay

                                < M A T L A B (R) >
                      Copyright 1984-2015 The MathWorks, Inc.
                       R2015b (8.6.0.267246) 64-bit (glnxa64)
                                  August 20, 2015

>> doyalmip
```
