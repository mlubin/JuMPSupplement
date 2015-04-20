
$Set  G  100
$Set  F  100
Set    f    facilities    /f1*f%F%/;
Set    i    gridx         /i0*i%G%/;
Set    j    gridy         /j0*j%G%/;
Set    k    dims          /1,2/;
Display f;

          variable  d;
positive  variable  y(f,k);
y.up(f,k)  =  1;
  binary  variable  z(i,j,f);
positive  variable  s(i,j,f);
          variable  r(i,j,f,k);


equations  assign(i,j);
assign(i,j) ..  sum(f, z(i,j,f))  =e=  1;


equations  stod(i,j,f);
stod(i,j,f) ..  s(i,j,f)  =e=  d  +  2.8*(1 - z(i,j,f));

equations  rig(i,j,f);
rig(i,j,f) ..   r(i,j,f,'1')  =e=  ord(i)  -  y(f,'1');

equations  rjg(i,j,f);
rjg(i,j,f) ..   r(i,j,f,'2')  =e=  ord(j)  -  y(f,'2');

equations  rtos(i,j,f);
rtos(i,j,f) ..  sum(k, r(i,j,f,k)*r(i,j,f,k))  =l=  s(i,j,f)*s(i,j,f);

model  facility  /all/;

option MIQCP = Gurobi;
option solvelink = 5;

option ResLim = 0;

solve  facility  using  miqcp  minimizing  d;
