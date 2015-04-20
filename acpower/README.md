We test on a network of 662 nodes and 1017 edges. This leads to 1489 decision variables, 1324 constraints, and a Hessian (of the Lagrangian) with 8121 nonzero entries. We run three versions of this benchmark, with 1, 10, and 100 copies of this network.

To generate input data for larger models, run:
```
$ julia gen_6620.jl
$ julia gen_66200.jl
```

We measure the time until Ipopt reports the total number of variables as the model generation time. For derivative evaluations, we measure the "Total CPU secs in NLP function evaluations". Some sample output is:

    10.795596 Total number of variables............................:   149999
    12.876986 Total CPU secs in NLP function evaluations           =      0.363

In this case we record 10.79 seconds as the model generation time and 0.363 as the derivative evaluation time. Note that the ``ts`` utility produces the time stamps in the first column of the output.

## Julia
```
$ julia opf.jl 662 | ts -s "%.s"

$ julia opf.jl 6620 | ts -s "%.s"

$ julia opf.jl 66200 | ts -s "%.s"
```

## AMPL
```
$ ampl opf_662bus.mod | ts -s "%.s"

$ ampl opf_6620bus.mod | ts -s "%.s"

$ ampl opf_66200bus.mod | ts -s "%.s"
```

## Pyomo


The solver output appears to be buffered when using ``ts``, so the model generation time includes the three iterations. This does not have a significant effect on the qualitative results. Note that post-solve, Pyomo spends a significant amount of time retrieving the solution from the solver, which we do not record.

```
$ pyomo solve --solver=asl:ipopt --stream-output --solver-options="max_iter=3" opf_662bus.py | ts -s "%.s"

$ pyomo solve --solver=asl:ipopt --stream-output --solver-options="max_iter=3" opf_6620bus.py | ts -s "%.s"

$ pyomo solve --solver=asl:ipopt --stream-output --solver-options="max_iter=3" opf_66200bus.py | ts -s "%.s"
```

## GAMS
To generate input for GAMS:
```
$ julia create_gams_inp.jl 662
$ julia create_gams_inp.jl 6620
$ julia create_gams_inp.jl 66200
```
To run benchmarks:
```
$ gams opf_662bus.gms lo=3 | ts -s "%.s"

$ gams opf_6620bus.gms lo=3 | ts -s "%.s"

$ gams opf_66200bus.gms lo=3 | ts -s "%.s"
```
