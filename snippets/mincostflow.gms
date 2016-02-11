set NODES /n1*n5/;
set EDGES(NODES,NODES) / n1 . n2
                         n1 . n3
                         n1 . n4
                         n2 . n5
                         n3 . n5
                         n4 . n5 /;
paramater COST(EDGES) / n1.n2 1
                        n1.n3 2 
                        n1.n4 3 
                        n2.n5 2 
                        n3.n5 2 
                        n4.n5 2 /;
paramater CAP(EDGES) /  n1.n2 0.5
                        n1.n3 0.4
                        n1.n4 0.6
                        n2.n5 0.3
                        n3.n5 0.6
                        n4.n5 0.5 /;
Variable flow[EDGES], z;
flow.lo[EDGES] = 0.0;
flow.up[EDGES] = CAP[EDGES];
Def_obj.. f =e= sum{EDGES,COST[EDGES] * flow[EDGES]};
