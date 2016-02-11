# Send one unit of flow, from node 1 to node N, through a
# directed graph with edge capacities and costs
using JuMP

N = 5
edges = [(1,2),(1,3),(1,4),(2,5),(3,5),(4,5)]
cost = Dict((1,2) => 1, (1,3) => 2, (1,4) => 3,
            (2,5) => 2, (3,5) => 2, (4,5) => 2)
capacity = Dict((1,2) => 0.5, (1,3) => 0.4, (1,4) => 0.6,
                (2,5) => 0.3, (3,5) => 0.6, (4,5) => 0.5)
mcf = Model()
@defVar(mcf, 0 <= flow[e in edges] <= capacity[e])
@setObjective(mcf, Min, sum{cost[e] * flow[e], e in edges})
@addConstraint(mcf, sum{flow[e], e in edges; e[2]==N} == 1)
for node in 2:N-1
    @addConstraint(mcf, sum{flow[e], e in edges; e[2]==node}
                     == sum{flow[e], e in edges; e[1]==node})
end
solve(mcf)
@show getValue(flow)


# ALTERNATIVELY
immutable Edge
    from; to; cost; capacity
end
edges = [Edge(1,2,1,0.5),Edge(1,3,2,0.4),Edge(1,4,3,0.6),
         Edge(2,5,2,0.3),Edge(3,5,2,0.6),Edge(4,5,2,0.5)]
mcf = Model()
@defVar(mcf, 0 <= flow[e in edges] <= e.capacity)
@setObjective(mcf, Min, sum{e.cost * flow[e], e in edges})
@addConstraint(mcf, sum{flow[e], e in edges; e.to==5} == 1)
for node in 2:4
    @addConstraint(mcf, sum{flow[e], e in edges; e.to  ==node}
                     == sum{flow[e], e in edges; e.from==node})
end
solve(mcf)
@show getValue(flow)
