using JuMP, Gurobi

function solve_facility(G, F)
    fl = Model(solver=GurobiSolver(TimeLimit=0,Presolve=0))

    # The minimum customer-facility distance
    @defVar(fl, d)
    @setObjective(fl, Min, d)

    # The location of the facilities
    @defVar(fl, 0 <= y[1:F,1:2] <= 1)

    # Each customer is assigned to a facility
    @defVar(fl, z[0:G, 0:G, 1:F], Bin)
    for i in 0:G, j in 0:G
        @addConstraint(fl, sum{z[i,j,f], f in 1:F} == 1)
    end

    # d is the maximum of distances between customers
    # and their facilities. The original constraint is
    # d >= ||x - y|| - M(1-z)
    # where M = 1 for our data. Because Gurobi/CPLEX
    # can't take SOCPs directly, we need to rewite as
    # a set of constraints and auxiliary variables:
    # s = d + M(1 - z) >= 0
    # r = x - y
    # r'r <= s^2
    M = 2*sqrt(2)
    @defVar(fl, s[0:G, 0:G, 1:F] >= 0)
    @defVar(fl, r[0:G, 0:G, 1:F, 1:2])
    for i in 0:G, j in 0:G, f in 1:F
        @addConstraint(fl, s[i,j,f] == d + M*(1 - z[i,j,f]))
        @addConstraint(fl, r[i,j,f,1] == i/G - y[f,1])
        @addConstraint(fl, r[i,j,f,2] == j/G - y[f,2])
        @addConstraint(fl, sum{r[i,j,f,k]^2,k=1:2} <= s[i,j,f]^2)
    end

    solve(fl)
end

# Customers lie in the unit square on a G by G grid
G = parse(Int,ARGS[1])
@show G

# Number of facilities
F = parse(Int,ARGS[2])
@show F

solve_facility(G, F)
