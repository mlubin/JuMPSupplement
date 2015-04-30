# JuMPSupplement
## Jupyter/IJulia Notebooks

This folder contains the two notebooks referred to in Section 7:

* **portfolio.ipynb** contains the Portfolio Optimization example (7.1)
* **rocket.ipynb** contains the Rocket Control example (7.2). This problem is drawn from the [JuliaOpt Notebook Collection](https://github.com/JuliaOpt/juliaopt-notebooks).

To run, simply open the notebooks from within an Jupyter/IJulia environment. You will need the following Julia packages, all available from the Julia package manager:
* Gadfly.jl
* Interact.jl
* Distributions.jl (for generating data for the portfolio problem)
* Any QP solver interface, e.g. Gurobi.jl
* Ipopt.jl

Static versions (i.e. no executable code) of the [portfolio](http://nbviewer.ipython.org/github/mlubin/JuMPSupplement/blob/master/notebooks/portfolio.ipynb) and [rocket](http://nbviewer.ipython.org/github/mlubin/JuMPSupplement/blob/master/notebooks/rocket.ipynb) notebooks can be viewed online via the nbviewer service.
