set EDGES := {(1,2),(1,3),(1,4),(2,5),(3,5),(4,5)};
param COST{EDGES};
param CAPACITY{EDGES};
data;
param COST :=
  1 2  1
  1 3  2
  1 4  3
  2 5  2
  3 5  2
  4 5  2;
param CAPACITY :=
  1 2  0.5
  1 3  0.4
  1 4  0.6
  2 5  0.3
  3 5  0.6
  4 5  0.5;
model;
var flow{(i,j) in EDGES} >= 0.0, <= CAPACITY[i,j];
minimize flowcost:    sum {(i,j) in EDGES} COST[i,j] * flow[i,j];
subject to unitflow:  sum {(i,5) in EDGES} flow[i,5] == 1;
subject to flowconserve {n in 2..4}:
  sum {(i,n) in EDGES} flow[i,n] == sum{(n,j) in EDGES} flow[n,j];
solve;
display flow;

