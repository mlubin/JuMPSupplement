from pyomo.environ import *
edges    = [(1,2),    (1,3),    (1,4),    (2,5),    (3,5),    (4,5)    ]
cost     = {(1,2):1,  (1,3):2,  (1,4):3,  (2,5):2,  (3,5):2,  (4,5):2  }
capacity = {(1,2):0.5,(1,3):0.4,(1,4):0.6,(2,5):0.3,(3,5):0.6,(4,5):0.5}
model = ConcreteModel()
model.flow = Var(edges, bounds=lambda m,i,j: (0,capacity[(i,j)]))
model.flowcost = Objective( expr=sum(cost[e]*model.flow[e] for e in edges))
model.unitflow = Constraint(expr=sum(model.flow[e] for e in edges if e[1]==5) == 1)
def flowcon_rule(model,n): return sum(model.flow[e] for e in edges if e[1]==n) == \
           sum(model.flow[e] for e in edges if e[0]==n)
model.flowcon = Constraint([2,3,4],rule=flowcon_rule)
