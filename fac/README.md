
We test with F = G = 25, 50, 75, 100. Some files require manual editing to adjust the parameters, while other scripts take these as command-line arguments.

We record the time until Gurobi prints out the problem dimensions. For example, given the output:

    24.315851 Optimize a model with 51376 rows, 67651 columns and 135200 nonzeros

We would record the model generation time as 24 seconds. Note that the ts utility produces the time stamps in the first column of the output.

## Julia

```
julia facility.jl 25 25 | ts -s "%.s"
```

## C++

```
export LD_LIBRARY_PATH=$GUROBI_HOME/lib/
clang++ -O2 facility.cpp -o facility -I$GUROBI_HOME/include/ -L$GUROBI_HOME/lib/  -lgurobi_c++ -lgurobi65 -stdlib=libstdc++ -std=c++11
./facility 25 25 | ts -s "%.s"
```

## AMPL

```
ampl facility.mod | ts -s "%.s"
```

## GAMS

```
gams facility.gms lo=3 | ts -s "%.s"
```

## Pyomo

Model generation times measured by wall clock since with ``ts``, the solver output appears to be buffered.


```
pyomo solve facility.py --solver=gurobi --stream-solver
```

With the above command, Pyomo communicates with Gurobi by writing out LP files. Pyomo also supports communication with Gurobi through its native python interface (command below), although in our tests this method did not perform as well as the file-based communication. In our benchmarks we report the performance using the file-based interface.

```
pyomo solve facility.py --solver=gurobi --solver-io=python --solver-options OutputFlag=1 | ts -s "%.s"
```

## CVX

We do *not* include the MATLAB startup time in our timings.

```
matlab -nosplash -nodisplay -r facility_cvx | ts -s "%.s"
```

## YALMIP

We do *not* include the MATLAB startup time in our timings.

Follow the standard instructions to set up YALMIP and the gurobi interface to matlab.
These commands may be useful:

```
cd([getenv('GUROBI_HOME') '/matlab'])
gurobi_setup
addpath(genpath('/path/to/yalmip'))
```

```
matlab -nosplash -nodisplay -r facility_yalmip | ts -s "%.s"
```
