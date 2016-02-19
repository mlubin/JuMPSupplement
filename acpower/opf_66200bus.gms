* *******************
* *** CONSTANTS
* *******************

SCALAR branch_tap_min /0.85/;
SCALAR branch_tap_max /1.15/;

SCALAR p_gen_upper /1.10/;
SCALAR p_gen_lower /0.90/;


* *******************
* *** BUS
* *******************

$offlisting
$include IEEE66200.bus.gms
$onlisting

PARAMETER bus_voltage_min(bus_ind);
bus_voltage_min(bus_ind)$(bus_type(bus_ind) eq 0) = 0.85;
bus_voltage_min(bus_ind)$(bus_type(bus_ind) eq 1) = 0.85;
bus_voltage_min(bus_ind)$(bus_type(bus_ind) eq 2) = 0.92;
bus_voltage_min(bus_ind)$(bus_type(bus_ind) eq 3) = 0.99;

PARAMETER bus_voltage_max(bus_ind);
bus_voltage_max(bus_ind)$(bus_type(bus_ind) eq 0) = 1.15;
bus_voltage_max(bus_ind)$(bus_type(bus_ind) eq 1) = 1.15;
bus_voltage_max(bus_ind)$(bus_type(bus_ind) eq 2) = 1.08;
bus_voltage_max(bus_ind)$(bus_type(bus_ind) eq 3) = 1.01;

* RESCALE
bus_p_gen(bus_ind)  = bus_p_gen(bus_ind)/100;
bus_q_gen(bus_ind)  = bus_q_gen(bus_ind)/100;
bus_q_min(bus_ind)  = bus_q_min(bus_ind)/100;
bus_q_max(bus_ind)  = bus_q_max(bus_ind)/100;
bus_p_load(bus_ind) = bus_p_load(bus_ind)/100;
bus_q_load(bus_ind) = bus_q_load(bus_ind)/100;


* *******************
* *** BRANCH
* *******************

$offlisting
$include IEEE66200.branch.gms
$onlisting

* Defines
* branch_ind: indices BR1 to BR1071 for all the branches
* branch_orig(branch_ind,bus_ind): exists only if that branch goes from that bus
* branch_dest(branch_ind,bus_ind): ditto, for destination
* branch_*(branch_ind): rest of parameters

ALIAS(branch_ind,br);
ALIAS(bus_ind,bus_i,bus_j,bus_k,bus_m);

PARAMETER branch_g(br);
branch_g(br) =  branch_r(br) / ( power(branch_r(br),2) + power(branch_x(br),2) );
PARAMETER branch_b(br);
branch_b(br) = -branch_x(br) / ( power(branch_r(br),2) + power(branch_x(br),2) );


* *******************
* *** VARIABLES
* *******************
VARIABLE bus_voltage(bus_ind);
bus_voltage.LO(bus_ind)  =  bus_voltage_min(bus_ind);
bus_voltage.UP(bus_ind)  =  bus_voltage_max(bus_ind);
bus_voltage.l(bus_ind)   =  1;

VARIABLE bus_b_shunt(bus_ind);
bus_b_shunt.LO(bus_ind)  =  bus_b_shunt_min(bus_ind);
bus_b_shunt.UP(bus_ind)  =  bus_b_shunt_max(bus_ind);
bus_b_shunt.l(bus_ind)   =  bus_b_shunt0(bus_ind);

VARIABLE bus_angle(bus_ind);
bus_angle.l(bus_ind)     =  0;

VARIABLE branch_tap(br);
branch_tap.LO(br)  =  branch_tap_min;
branch_tap.UP(br)  =  branch_tap_max;
branch_tap.l(br)   =  1;

VARIABLE branch_def(br);
branch_def.LO(br)  =  branch_def_min(br) * 3.14159/180;
branch_def.UP(br)  =  branch_def_max(br) * 3.14159/180;
branch_def.l(br)   = -branch_def0(br) * 3.14159/180;


* *******************
* *** G and B
* *******************
* In JuMP, these are NLExpr
* In AMPL, these are variables that are fixed to expressions.
* Here we use macro expansion, which seems to work similarly.

$MACRO Gself(bus_k) (( bus_g_shunt(bus_k) + sum( br$branch_orig(br,bus_k), branch_g(br) * sqr(branch_tap(br)) ) + sum( br$branch_dest(br,bus_k), branch_g(br) ) ))

$MACRO Gout(br) (( (-branch_g(br) * cos(branch_def(br)) + branch_b(br) * sin(branch_def(br))) * branch_tap(br) ))

$MACRO Gin(br)  (( (-branch_g(br) * cos(branch_def(br)) - branch_b(br) * sin(branch_def(br))) * branch_tap(br) ))

$MACRO Bself(bus_k) (( bus_b_shunt(bus_k) + sum( br$branch_orig(br,bus_k), branch_b(br) * sqr(branch_tap(br)) + branch_c(br)/2) + sum( br$branch_dest(br,bus_k), branch_b(br) + branch_c(br)/2) ))

$MACRO Bin(br)  (( ( branch_g(br) * sin(branch_def(br)) - branch_b(br) * cos(branch_def(br))) * branch_tap(br) ))

$MACRO Bout(br) (( ( branch_g(br) * sin(branch_def(br)) - branch_b(br) * cos(branch_def(br))) * branch_tap(br) ))


* *******************
* *** CONSTRAINTS
* *******************

EQUATION p_load(bus_k);
p_load(bus_k)$(bus_type(bus_k) eq 0)..
  bus_p_gen(bus_k) - bus_p_load(bus_k) -
    sum((br,bus_i)$(branch_dest(br,bus_k) and branch_orig(br,bus_i)),
        bus_voltage(bus_k) * bus_voltage(bus_i) *
            (Gin(br) * cos(bus_angle(bus_k) - bus_angle(bus_i)) +
             Bin(br) * sin(bus_angle(bus_k) - bus_angle(bus_i))
            )
        ) -
    sum((br,bus_j)$(branch_orig(br,bus_k) and branch_dest(br,bus_j)),
        bus_voltage(bus_k) * bus_voltage(bus_j) *
            (Gout(br) * cos(bus_angle(bus_k) - bus_angle(bus_j)) +
             Bout(br) * sin(bus_angle(bus_k) - bus_angle(bus_j))
            )
        ) -
    sqr(bus_voltage(bus_k)) * Gself(bus_k) =e= 0;

EQUATION q_load(bus_k);
q_load(bus_k)$(bus_type(bus_k) eq 0)..
  bus_q_gen(bus_k) - bus_q_load(bus_k) -
    sum((br,bus_i)$(branch_dest(br,bus_k) and branch_orig(br,bus_i)),
        bus_voltage(bus_k) * bus_voltage(bus_i) *
            (Gin(br) * sin(bus_angle(bus_k) - bus_angle(bus_i)) -
             Bin(br) * cos(bus_angle(bus_k) - bus_angle(bus_i))
            )
        ) -
    sum((br,bus_j)$(branch_orig(br,bus_k) and branch_dest(br,bus_j)),
        bus_voltage(bus_k) * bus_voltage(bus_j) *
            (Gout(br) * sin(bus_angle(bus_k) - bus_angle(bus_j)) -
             Bout(br) * cos(bus_angle(bus_k) - bus_angle(bus_j))
            )
        ) +
    sqr(bus_voltage(bus_k)) * Bself(bus_k) =e= 0;

VARIABLE q_inj_val(bus_k);
q_inj_val.LO(bus_k)$(bus_type(bus_k) ne 0) = bus_q_min(bus_k);
q_inj_val.UP(bus_k)$(bus_type(bus_k) ne 0) = bus_q_max(bus_k);
EQUATION q_inj(bus_k);
q_inj(bus_k)$(bus_type(bus_k) ne 0)..
  q_inj_val(bus_k) =e=
    bus_q_load(bus_k) +
    sum((br,bus_i)$(branch_dest(br,bus_k) and branch_orig(br,bus_i)),
        bus_voltage(bus_k) * bus_voltage(bus_i) *
            (Gin(br) * sin(bus_angle(bus_k) - bus_angle(bus_i)) -
             Bin(br) * cos(bus_angle(bus_k) - bus_angle(bus_i))
            )
        ) +
    sum((br,bus_j)$(branch_orig(br,bus_k) and branch_dest(br,bus_j)),
        bus_voltage(bus_k) * bus_voltage(bus_j) *
            (Gout(br) * sin(bus_angle(bus_k) - bus_angle(bus_j)) -
             Bout(br) * cos(bus_angle(bus_k) - bus_angle(bus_j))
            )
        ) -
    sqr(bus_voltage(bus_k)) * Bself(bus_k);

VARIABLE p_inj_val(bus_k);
p_inj_val.LO(bus_k)$(bus_type(bus_k) ne 0) = 0;
p_inj_val.UP(bus_k)$(bus_type(bus_k) ne 0) = p_gen_upper*bus_p_gen(bus_k);
EQUATION p_inj(bus_k);
p_inj(bus_k)$(bus_type(bus_k) ne 0)..
  p_inj_val(bus_k) =e=
    bus_p_load(bus_k) +
    sum((br,bus_i)$(branch_dest(br,bus_k) and branch_orig(br,bus_i)),
        bus_voltage(bus_k) * bus_voltage(bus_i) *
            (Gin(br) * cos(bus_angle(bus_k) - bus_angle(bus_i)) +
             Bin(br) * sin(bus_angle(bus_k) - bus_angle(bus_i))
            )
        ) +
    sum((br,bus_j)$(branch_orig(br,bus_k) and branch_dest(br,bus_j)),
        bus_voltage(bus_k) * bus_voltage(bus_j) *
            (Gout(br) * cos(bus_angle(bus_k) - bus_angle(bus_j)) +
             Bout(br) * sin(bus_angle(bus_k) - bus_angle(bus_j))
            )
        ) +
    sqr(bus_voltage(bus_k)) * Gself(bus_k);


* *******************
* *** FIXED VARIABLES
* *******************

* FREEZE THE REFERENCE BUS ANGLE TO ZERO.
bus_angle.FX(bus_i)$(bus_type(bus_i) eq 3) = 0;
* FREEZE ANY DISPATCHABLE SHUNTS.
bus_b_shunt.FX(bus_i)$(bus_b_dispatch(bus_i) eq 0) = bus_b_shunt0(bus_i);

* FREEZE ANY BRANCH TAPS.
branch_tap.FX(br)$(branch_type(br) eq 0) = 1;
branch_tap.FX(br)$(branch_type(br) eq 3) = 1;
* FREEZE CERTAIN PHASE SHIFTERS.
* In AMPL/JuMP, we set initial value then fix it to that
* The initial value is
* AMPL:  -branch_def0[l,k,m] * 3.14159/180
branch_def.FX(br)$(branch_type(br) ne 4) = -branch_def0(br) * 3.14159/180;


* *******************
* *** OBJECTIVE
* *******************

VARIABLE obj;
EQUATION obj_def;
obj_def.. obj =e= sum(bus_k$(bus_type(bus_k) ne 0), sqr(bus_p_load(bus_k) + 
    sum((br,bus_i)$(branch_dest(br,bus_k) and branch_orig(br,bus_i)),
        bus_voltage(bus_k) * bus_voltage(bus_i) *
            (Gin(br) * cos(bus_angle(bus_k) - bus_angle(bus_i)) +
             Bin(br) * sin(bus_angle(bus_k) - bus_angle(bus_i))
            )
        ) +
    sum((br,bus_j)$(branch_orig(br,bus_k) and branch_dest(br,bus_j)),
        bus_voltage(bus_k) * bus_voltage(bus_j) *
            (Gout(br) * cos(bus_angle(bus_k) - bus_angle(bus_j)) +
             Bout(br) * sin(bus_angle(bus_k) - bus_angle(bus_j))
            )
        ) +
    sqr(bus_voltage(bus_k)) * Gself(bus_k))
    );


MODEL acpower /all/;
acpower.holdfixed = 1;
OPTION nlp=ipopt;
OPTION iterlim=3;
OPTION solvelink=5;
SOLVE acpower USING nlp MINIMIZING obj;
