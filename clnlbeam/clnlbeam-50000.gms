* Cute AMPL model  (translation to GAMS)
*
* AMPL Model by Hande Y. Benson
*
* Copyright (C) 2001 Princeton University
* All Rights Reserved
*
* Permission to use, copy, modify, and distribute this software and
* its documentation for any purpose and without fee is hereby
* granted, provided that the above copyright notice appear in all
* copies and that the copyright notice and this
* permission notice appear in all supporting documentation.

*   Source:
*   H. Maurer and H.D. Mittelman,
*   "The non-linear beam via optimal control with bound state variables",
*   Optimal Control Applications and Methods 12, pp. 19-31, 1991.

*   SIF input: Ph. Toint, Nov 1993.

*   classification  OOR2-MN-V-V

$Set N 50000
$Set M 49999
Set i /i0*i%N%/;
Set left(i) /i0*i%M%/;
parameter alpha;  alpha = 350.0  ;
parameter     h;      h = 1/%n%  ;


Variable      x[i],t[i],u[i], f    ;

Equation  Eq_1[i], Eq_2[i], Def_obj ;


Def_obj..  f =e= sum{i$left(i),(0.5*h*(sqr(u[i+1])+sqr(u[i]))+
                                0.5*alpha*h*(cos(t[i+1])+cos(t[i]))) };
Eq_1[i]$left(i).. x[i+1]-x[i]-0.5*h*(sin(t[i+1])+     sin(t[i])) =e= 0;
Eq_2[i]$left(i).. t[i+1]-t[i]-0.5*h* u[i+1]     - 0.5*h*u[i]     =e= 0;

t.lo[i] = -1.0 ;
x.lo[i] = -0.05;
t.up[i] =  1.0 ;
x.up[i] =  0.05;
t.l[i]  = 0.05*cos((ord(i)-1)*h);
x.l[i]  = 0.05*cos((ord(i)-1)*h);
u.l[i]  = 0.01;

x.fx['i0']   = 0.0;
x.fx['i%n%'] = 0.0;
t.fx['i0']   = 0.0;
t.fx['i%n%'] = 0.0;

Model clnbeam /all/;

option nlp=ipopt;
option iterlim=3;
option solvelink=5;
Solve clnbeam using nlp minimize f;

display x.l;
display f.l;
