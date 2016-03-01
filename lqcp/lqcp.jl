using JuMP, Gurobi

function test_cont5(n)
    @show n
    m  = n
    n1 = n-1
    m1 = m-1
    dx = 1/n
    T  = 1.58
    dt = T/m
    h2 = dx^2
    a  = 0.001
    yt = [0.5*(1 - (j*dx)^2) for j=0:n]
    
    mod = Model(solver=GurobiSolver(TimeLimit=0))
    @defVar(mod,  0 <= y[0:m,0:n] <= 1)
    @defVar(mod, -1 <= u[1:m] <= 1)

    @setObjective(mod, Min, 
        1/4*dx*(      (y[m,0] - yt[0+1])^2  +
                2*sum{(y[m,j] - yt[j+1])^2,j=1:n1} +
                      (y[m,n] - yt[n+1])^2) +
        1/4*a*dt*(2*sum{u[i]^2,i=1:m1} + u[m]^2)
    )
    
    # PDE
    for i = 0:m1, j = 1:n1
        @addConstraint(mod, h2*(y[i+1,j] - y[i,j]) == 0.5*dt*(y[i,j-1] - 2*y[i,j] + y[i,j+1] + y[i+1,j-1] - 2*y[i+1,j] + y[i+1,j+1]) )
    end

    # IC
    for j = 0:n
        @addConstraint(mod, y[0,j] == 0)
    end

    # BC
    for i = 1:m
        @addConstraint(mod, y[i,  2] - 4*y[i, 1] + 3*y[i,0] == 0)
        @addConstraint(mod, y[i,n-2] - 4*y[i,n1] + 3*y[i,n] == (2*dx)*(u[i] - y[i,n]))
    end

    solve(mod)
end

test_cont5(parse(Int,ARGS[1]))
