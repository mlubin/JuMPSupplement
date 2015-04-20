$Set  n   2000
$Set  n1  1999
$Set  n2  1998
$Set  m   2000
$Set  m1  1999
$Set  dx  1/1000
$Set  T   1.58
$Set  dt  1.58/1000
$Set  h2  1/1000000
$Set  a   0.001

Set  gx          "gridx"           /i0*i%m%/;
Set  gxzmo(gx)   "gridx 0 to m-1"  /i0*i%m1%/;
Set  gxom(gx)    "gridx 1 to m"    /i1*i%m%/;
Set  gxomo(gxom) "gridx 1 to m-1"  /i1*i%m1%/;

Set  gy         "gridy"           /j0*j%n%/;
Set  gyono(gy)  "gridy 1 to n-1"  /j1*j%n1%/;



variable y(gx,gy);
y.lo(gx,gy)  =  0;
y.up(gx,gy)  =  1;

variable  u(gxom);
u.lo(gxom)  = -1;
u.up(gxom)  =  1;

variable z;


* NOTE THAT CONTANTS ARE WRONG, like yt, dx, dt
* STRUCTURE SHOULD BE FINE THOUGH

equations  obj;
obj ..  z =e= 0.25 * %dx% * ((y('i%m%','j0') - 1)*(y('i%m%','j0') - 1) +
2*sum(gyono, (y('i%m%',gyono) - 1)*(y('i%m%',gyono) - 1)) +
(y('i%m%','j%n%') - 1)*(y('i%m%','j%n%') - 1)) +
0.25 * %a% * %dt% * ( 2*sum(gxomo, u(gxomo)*u(gxomo)) + u('i%m%')*u('i%m%'));

equations  pde(gxzmo,gyono);
pde(gxzmo,gyono) ..  (y(gxzmo+1,gyono) - y(gxzmo,gyono))/%dt% =e= 
0.5*(y(gxzmo,gyono-1) - 2*y(gxzmo,gyono) + y(gxzmo,gyono+1) +
     y(gxzmo+1,gyono-1) - 2*y(gxzmo+1,gyono) + y(gxzmo+1,gyono+1))/%h2%;

equations  ic(gy);
ic(gy) ..  y('i0',gy) =e= 0;

equations  bc1(gxom);
bc1(gxom) ..  y(gxom,'j2') - 4*y(gxom,'j1') + 3*y(gxom,'j0') =e= 0;

equations  bc2(gxom);
bc2(gxom) ..  (y(gxom,'j%n2%') - 4*y(gxom,'j%n1%') + 3*y(gxom,'j%n%'))/(2*%dx%) =e= u(gxom)-y(gxom,'j%n%');



model  cont5  /all/;

option MIQCP = Gurobi;
option solvelink = 5;

option ResLim = 0;

solve  cont5  using  miqcp  minimizing  z;
