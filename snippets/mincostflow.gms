SET nodes /n1*n5/;
ALIAS(nodes,nodefrom,nodeto);
SET midnodes(nodes) /n2*n4/;
SET lastnode(nodes) /n5/;
SET edges(nodes,nodes) / n1 . n2
                         n1 . n3
                         n1 . n4
                         n2 . n5
                         n3 . n5
                         n4 . n5 /;
PARAMETER cost(nodes,nodes) / n1.n2 1
                              n1.n3 2 
                              n1.n4 3 
                              n2.n5 2 
                              n3.n5 2 
                              n4.n5 2 /;
PARAMETER cap(nodes,nodes) /  n1.n2 0.5
                              n1.n3 0.4
                              n1.n4 0.6
                              n2.n5 0.3
                              n3.n5 0.6
                              n4.n5 0.5 /;
VARIABLE flow(nodefrom,nodeto), z;
flow.LO(edges) = 0;
flow.UP(edges) = cap(edges);
EQUATION flowcost;
flowcost.. z =e= sum(edges, cost(edges) * flow(edges));
EQUATION unitflow;
unitflow.. 1 =e= sum((nodefrom,lastnode)$edges(nodefrom,lastnode), flow(nodefrom,lastnode));
EQUATION flowcon(midnodes);
flowcon(midnodes).. sum(nodefrom$edges(nodefrom,midnodes), flow(nodefrom,midnodes)) =e= 
                         sum(nodeto$edges(midnodes,nodeto), flow(midnodes,nodeto));
MODEL mincostflow /all/;
SOLVE mincostflow USING lp MINIMIZING z;

