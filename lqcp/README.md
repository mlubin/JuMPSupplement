

We record the time until Gurobi prints out the problem dimensions. See the README for fac for instructions on recording the timings.

## Julia

```
julia lqcp.jl 500 | ts -s "%.s"
```

## C++

```
export LD_LIBRARY_PATH=$GUROBI_HOME/lib/
clang++ -O2 lqcp.cpp -o lqcp -I$GUROBI_HOME/include/ -L$GUROBI_HOME/lib/  -lgurobi_c++ -lgurobi65 -stdlib=libstdc++ -std=c++11
./lqcp 500 | ts -s "%.s"
```

## AMPL

```
ampl lqcp.mod | ts -s "%.s"
```

## GAMS

Must adjust multiple constants (n, n1, n2, m, and m1) within the .gms file.

```
gams lqcp.gms lo=3 | ts -s "%.s"
```

## Pyomo


Model generation times measured by wall clock since with ``ts``, the solver output appears to be buffered.

```
pyomo solve lqcp.py --solver=gurobi --stream-solver
```

## CVX

We do *not* include the MATLAB startup time in our timings.

```
matlab -nosplash -nodisplay -r lqcp_cvx | ts -s "%.s"
```

## YALMIP

We do *not* include the MATLAB startup time in our timings.

```
matlab -nosplash -nodisplay -r lqcp_yalmip | ts -s "%.s"
```
