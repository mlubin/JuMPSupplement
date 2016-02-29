# JuMPSupplement
Repository containing supplementary materials and code for "JuMP: A Modeling Language for Mathematical Optimization" by I. Dunning, J. Huchette, and M. Lubin.

Installation instructions:

The benchmarks depend on the following commercial software packages which must be installed separately:
- AMPL 20160207
- GAMS 24.6.1 
- Gurobi 6.5.0
- MATLAB R2015b

Additionally, users should install:
- [CVX 2.1 with Gurobi](http://cvxr.com/cvx/doc/gurobi.html)
- [YALMIP](http://users.isy.liu.se/johanl/yalmip/pmwiki.php?n=Tutorials.Installation) 20150918
- [Pyomo](https://software.sandia.gov/downloads/pub/pyomo/PyomoInstallGuide.html) 4.2.10784 with Python 2.7.11
- [Julia](http://julialang.org/downloads/) 0.4.3
- [Ipopt](https://projects.coin-or.org/Ipopt) 3.12.1

For timing, we use the ``ts`` command-line utility. On Ubuntu Linux, ``ts`` is provided by the ``moreutils`` package.

*Installation instructions for Pyomo:*

A simple way to install Pyomo is through the ``virtualenv`` package:
```
$ virtualenv venv
$ source venv/bin/activate
$ pip install pyomo

(venv)$ pyomo --version
Pyomo 4.2.10784 (CPython 2.7.11 on Linux 4.4.1-2-ARCH)
```

*Installation instructions for Julia:*

We recommend reproducing the experiments with the exact version of Julia used here. If binaries for version 0.4.3 are no longer available, one can build Julia from source as follows:
```
$ git clone git://github.com/JuliaLang/julia.git
$ cd julia
$ git checkout v0.4.3
$ make
```

Unfortunately, the build process relies on many external packages and URLs. It cannot be expected to work indefinitely, even if github.com remains available.

Once Julia is installed, we require the following Julia packages:
- [JuMP](https://github.com/JuliaOpt/JuMP.jl) 0.12.0
- [ReverseDiffSparse](https://github.com/mlubin/ReverseDiffSparse.jl) 0.5.3
- [Gurobi.jl](https://github.com/JuliaOpt/Gurobi.jl) 0.2.1
- [Ipopt.jl](https://github.com/JuliaOpt/Ipopt.jl) 0.2.1

You should force the use of particular versions of these Julia packages with
```
julia> Pkg.pin("JuMP", v"0.12.0")
julia> Pkg.pin("ReverseDiffSparse", v"0.5.3")
julia> Pkg.pin("Gurobi", v"0.2.1")
julia> Pkg.pin("Ipopt", v"0.2.1")
```

For the nonlinear tests, you should add ``ipopt`` compiled with ASL to your path.
On Linux, you can just use the Ipopt binary from Julia:

```
export PATH=$PATH:$HOME/.julia/v0.4/Ipopt/deps/usr/bin
```

See the individual directories for further instructions.

Change log:

    Feburary 2016: Update for first paper revision. Newer versions of all packages.
    April 2015: Initial version
