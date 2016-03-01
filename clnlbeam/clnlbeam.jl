using JuMP
import MathProgBase
using Ipopt

function clnlbeam(N, solver)
    ni    = N
    alpha = 350
    h     = 1/ni

    m = Model(solver=solver)

    @defVar(m, -1 <= t[i=1:(ni+1)] <= 1, start = 0.05*cos((i-1)*h))
    @defVar(m, -0.05 <= x[i=1:(ni+1)] <= 0.05, start = 0.05*cos((i-1)*h))
    @defVar(m, u[1:(ni+1)], start = 0.01)

    @setNLObjective(m, Min, sum{ 0.5*h*(u[i+1]^2+u[i]^2) + 0.5*alpha*h*(cos(t[i+1]) + cos(t[i])),
        i=1:ni})

    # boundary conditions
    setLower(x[1], 0.0)
    setUpper(x[1], 0.0)
    setLower(x[ni+1], 0.0)
    setUpper(x[ni+1], 0.0)

    setLower(t[1], 0.0)
    setUpper(t[1], 0.0)
    setLower(t[ni+1], 0.0)
    setUpper(t[ni+1], 0.0)

    # cons1
    for i in 1:ni
        @addNLConstraint(m, x[i+1] - x[i] - 0.5*h*(sin(t[i+1])+sin(t[i])) == 0)
    end
    # cons2
    for i in 1:ni
        @addConstraint(m, t[i+1] - t[i] - (0.5h)*u[i+1] - (0.5h)*u[i] == 0)
    end

    solve(m)

end

clnlbeam(parse(Int,ARGS[1]),IpoptSolver(max_iter=3))
