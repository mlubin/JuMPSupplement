######################################################################
# Optimal Power Flow test problem to demonstrate KNITRO.
#   Todd Plantenga, Ziena Optimization, Inc.
#   October 2006
#   Adapted from Robert Vanderbei
#     http://www.sor.princeton.edu/~rvdb/ampl/nlmodels/
#
# This AMPL model defines nonlinear AC power balance equations, and
# an objective function that minimizes active power generation.
# Data is read from a file following IEEE Common Format.  The AMPL
# model works with any data set in Common Format.
# Data is supplied for networks with 14 and 662 buses.
#
#   min:  Active Power Generation
#   subject to: nonlinear AC power flow balance equations at each bus
#               upper and lower bounds on voltages
#               upper and lower bounds on Pgen
#               upper and lower bounds on Qgen
#
# IEEE Common Format codes:
#   bus_type = 0  PQ load bus
#   bus_type = 2  PV generation bus
#   bus_type = 3  slack/reference bus
######################################################################

######################################################################
#  DEFINE THE AMPL MODEL FOR OPF
######################################################################

reset;

#---- DECLARE SPACE FOR UP TO 120000 BRANCHES.
set BUS;
set BRANCH within {1..120000} cross BUS cross BUS;

#---- DECLARE ITEMS TO BE READ FROM THE .bus DATA FILE.
param bus_type       {BUS};
param bus_name       {BUS} symbolic;
param bus_voltage0   {BUS};
param bus_angle0     {BUS};
param bus_p_gen      {BUS};
param bus_q_gen      {BUS};
param bus_q_min      {BUS};
param bus_q_max      {BUS};
param bus_p_load     {BUS};
param bus_q_load     {BUS};
param bus_g_shunt    {BUS};
param bus_b_shunt0   {BUS};
param bus_b_shunt_min{BUS};
param bus_b_shunt_max{BUS};
param bus_b_dispatch {BUS};
param bus_area       {BUS};

#---- DECLARE ITEMS TO BE READ FROM THE .branch DATA FILE.
param branch_type    {BRANCH};
param branch_r       {BRANCH};
param branch_x       {BRANCH};
param branch_c       {BRANCH};
param branch_tap0    {BRANCH};
param branch_tap_min0{BRANCH};
param branch_tap_max0{BRANCH};
param branch_def0    {BRANCH};
param branch_def_min {BRANCH};
param branch_def_max {BRANCH};

#---- THESE ARE COMPUTED FROM BRANCH DATA.
param branch_g {(l,k,m) in BRANCH}
    :=  branch_r[l,k,m] / (branch_r[l,k,m]^2 + branch_x[l,k,m]^2);
param branch_b {(l,k,m) in BRANCH}
    := -branch_x[l,k,m] / (branch_r[l,k,m]^2 + branch_x[l,k,m]^2);

#---- DEFINE PARAMETER LIMITS ON VOLTAGES, TAPS, AND POWER GENERATION.
#---- LIMIT VALUES ARE SET LATER IN THE "data" SECTION.
param bus_voltage_min{0..3};
param bus_voltage_max{0..3};
param branch_tap_min;
param branch_tap_max;
param p_gen_upper;
param p_gen_lower;


#---- DECLARE VARIABLES, WITH UPPER AND LOWER BOUNDS.
var bus_voltage {i in BUS} >= bus_voltage_min[bus_type[i]],
                           <= bus_voltage_max[bus_type[i]]; 
var bus_b_shunt {i in BUS} >= bus_b_shunt_min[i],
                           <= bus_b_shunt_max[i];
var bus_angle   {i in BUS};
var branch_tap  {(l,k,m) in BRANCH} >= branch_tap_min,
                                    <= branch_tap_max; 
var branch_def  {(l,k,m) in BRANCH} >= branch_def_min[l,k,m],
                                    <= branch_def_max[l,k,m];

#---- DEFINE A SET FOR THE BUS ADMITTANCE MATRIX (YBUS).
set YBUS := setof{i in BUS} (i,i) union 
              setof {(l,k,m) in BRANCH} (k,m) union
                setof {(l,k,m) in BRANCH} (m,k);

#---- COMPUTE ADMITTANCE VALUES FROM IEEE COMMON FORMAT DATA.
var G{(k,m) in YBUS} =
  if(k == m) then
    (bus_g_shunt[k]
     + sum{(l,k,i) in BRANCH} branch_g[l,k,i] * branch_tap[l,k,i]^2
     + sum{(l,i,k) in BRANCH} branch_g[l,i,k])
  else if(k != m) then
    (sum{(l,k,m) in BRANCH}
       (- branch_g[l,k,m] * cos(branch_def[l,k,m])
        - branch_b[l,k,m] * sin(branch_def[l,k,m])) * branch_tap[l,k,m]
       + sum{(l,m,k) in BRANCH} (- branch_g[l,m,k] * cos(branch_def[l,m,k])
                                 + branch_b[l,m,k] * sin(branch_def[l,m,k]))
                                * branch_tap[l,m,k]);
var B{(k,m) in YBUS} =
  if(k == m) then
    (bus_b_shunt[k]
     + sum{(l,k,i) in BRANCH} (  branch_b[l,k,i] * branch_tap[l,k,i]^2
                               + branch_c[l,k,i]/2)
     + sum{(l,i,k) in BRANCH} (branch_b[l,i,k] + branch_c[l,i,k]/2))
  else if(k != m) then
    (sum{(l,k,m) in BRANCH}
       (  branch_g[l,k,m] * sin(branch_def[l,k,m])
        - branch_b[l,k,m] * cos(branch_def[l,k,m])) * branch_tap[l,k,m]
       + sum{(l,m,k) in BRANCH} (- branch_g[l,m,k] * sin(branch_def[l,m,k])
                                 - branch_b[l,m,k] * cos(branch_def[l,m,k]))
                                * branch_tap[l,m,k]);

#---- OBJECTIVE FUNCTION.
minimize active_power :
  sum{k in BUS : bus_type[k] == 2 || bus_type[k] == 3} 
   (bus_p_load[k]
    + sum{(k,m) in YBUS}
        (bus_voltage[k] * bus_voltage[m]
         * (  G[k,m] * cos(bus_angle[k] - bus_angle[m])
            + B[k,m] * sin(bus_angle[k] - bus_angle[m]))))^2;

#---- AC POWER FLOW BALANCE EQUATIONS (NONLINEAR CONSTRAINTS).

subject to p_load {k in BUS : bus_type[k] == 0}:
  bus_p_gen[k] - bus_p_load[k]
  - sum{(k,m) in YBUS} (bus_voltage[k] * bus_voltage[m]
                        * (  G[k,m] * cos(bus_angle[k] - bus_angle[m])
                           + B[k,m] * sin(bus_angle[k] - bus_angle[m]))) = 0;

subject to q_load {k in BUS : bus_type[k] == 0}:
  bus_q_gen[k] - bus_q_load[k]
  - sum{(k,m) in YBUS} (bus_voltage[k] * bus_voltage[m]
                        * (  G[k,m] * sin(bus_angle[k] - bus_angle[m])
                           - B[k,m] * cos(bus_angle[k] - bus_angle[m]))) = 0;

subject to q_inj {k in BUS : bus_type[k] == 2 || bus_type[k] == 3}:
  bus_q_min[k]
  <= bus_q_load[k]
     + sum{(k,m) in YBUS} (bus_voltage[k] * bus_voltage[m]
                           * (  G[k,m] * sin(bus_angle[k] - bus_angle[m])
                              - B[k,m] * cos(bus_angle[k] - bus_angle[m])))
  <= bus_q_max[k];


subject to p_inj {k in BUS : bus_type[k] == 2 || bus_type[k] == 3}:
  0 <= bus_p_load[k]
       + sum{(k,m) in YBUS} (bus_voltage[k] * bus_voltage[m]
                             * (  G[k,m] * cos(bus_angle[k] - bus_angle[m])
                                + B[k,m] * sin(bus_angle[k] - bus_angle[m])))
  <= p_gen_upper * bus_p_gen[k];


######################################################################
#  SET THE PARAMETRIC DATA
######################################################################
data;

param: BUS: bus_type bus_name bus_voltage0 bus_angle0 bus_p_gen bus_q_gen
            bus_q_min bus_q_max bus_p_load bus_q_load bus_g_shunt bus_b_shunt0
            bus_b_shunt_min bus_b_shunt_max bus_b_dispatch bus_area := 
include  IEEE66200.bus;

param: BRANCH: branch_type branch_r branch_x branch_c
               branch_tap0 branch_tap_min0 branch_tap_max0 branch_def0 
               branch_def_min branch_def_max :=
include  IEEE66200.branch;

#---- VOLTAGES LIMITS:     TYPE0   TYPE1   TYPE2   TYPE3
param bus_voltage_min :=  0 0.85  1 0.85  2 0.92  3 0.99;
param bus_voltage_max :=  0 1.15  1 1.15  2 1.08  3 1.01;

param branch_tap_min = 0.85;
param branch_tap_max = 1.15;

param p_gen_upper := 1.10;
param p_gen_lower := 0.90;

#----SCALE AND INITIALIZE THE DATA.
for{i in BUS}
{
   let bus_voltage[i] := 1;
   let bus_angle[i] := 0;
   let bus_b_shunt[i] := bus_b_shunt0[i];
   let bus_p_gen[i] := bus_p_gen[i]/100;
   let bus_q_gen[i] := bus_q_gen[i]/100;
   let bus_q_min[i] := bus_q_min[i]/100;
   let bus_q_max[i] := bus_q_max[i]/100;
   let bus_p_load[i] := bus_p_load[i]/100;
   let bus_q_load[i] := bus_q_load[i]/100;
};
for{(l,k,m) in BRANCH}
{
   let branch_def[l,k,m] := -branch_def0[l,k,m] * 3.14159/180; 
   let branch_def_min[l,k,m] := branch_def_min[l,k,m] * 3.14159/180;
   let branch_def_max[l,k,m] := branch_def_max[l,k,m] * 3.14159/180;
   let branch_tap[l,k,m] := 1;
};

#---- FREEZE THE REFERENCE BUS ANGLE TO ZERO.
fix {i in BUS : bus_type[i] == 3}
  bus_angle[i];

#---- FREEZE ANY DISPATCHABLE SHUNTS.
fix {i in BUS : bus_b_dispatch[i] == 0}
  bus_b_shunt[i];

#---- FREEZE ANY BRANCH TAPS.
fix {(l,k,m) in BRANCH : branch_type[l,k,m] == 0 || branch_type[l,k,m] == 3}
  branch_tap[l,k,m];

#---- FREEZE CERTAIN PHASE SHIFTERS.
fix {(l,k,m) in BRANCH : branch_type[l,k,m] != 4}
  branch_def[l,k,m];


######################################################################
#  SOLVE THE PROBLEM AND PRINT RESULTS
######################################################################

option solver ipopt;
options ipopt_options "max_iter=3";
solve;
