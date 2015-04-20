bus = readdlm("IEEE$(ARGS[1]).bus",ASCIIString)
header = [
    "bus_ind",
    "bus_type",
    "bus_name",
    "bus_voltage0",
    "bus_angle0",
    "bus_p_gen",
    "bus_q_gen",
    "bus_q_min",
    "bus_q_max",
    "bus_p_load",
    "bus_q_load",
    "bus_g_shunt",
    "bus_b_shunt0",
    "bus_b_shunt_min",
    "bus_b_shunt_max",
    "bus_b_dispatch",
    "bus_area"]
bus[:,1] = map(x->"BUS$x",bus[:,1])

fp = open("IEEE$(ARGS[1]).bus.gms","w")
println(fp, "SET bus_ind /")
for i in 1:size(bus,1)
    println(fp, bus[i,1])
end
println(fp, "/;\n")
for j in 2:size(bus,2) # skip ind, names
    j == 3 && continue 
    println(fp, "PARAMETER $(header[j])(bus_ind) /")
    for i in 1:size(bus,1)
        println(fp, bus[i,1], "   ", bus[i,j])
    end
    println(fp, "/;")
end
close(fp)



branch = readdlm("IEEE$(ARGS[1]).branch",ASCIIString)
header = [
    "branch_ind",
    "branch_orig",
    "branch_dest",
    "branch_type",
    "branch_r",
    "branch_x",
    "branch_c",
    "branch_tap0",
    "branch_tap_min0",
    "branch_tap_max0",
    "branch_def0",
    "branch_def_min",
    "branch_def_max"
]
branch[:,1] = map(x->"BR$x",branch[:,1])
branch[:,2] = map(x->"BUS$x",branch[:,2])
branch[:,3] = map(x->"BUS$x",branch[:,3])

fp = open("IEEE$(ARGS[1]).branch.gms","w")

println(fp, "SET branch_ind /")
for i in 1:size(branch,1)
    println(fp, branch[i,1])
end
println(fp, "/;\n")

println(fp, "SET branch_orig(branch_ind,bus_ind) /")
for i in 1:size(branch,1)
    println(fp, branch[i,1], " . ", branch[i,2])
end
println(fp, "/;\n")

println(fp, "SET branch_dest(branch_ind,bus_ind) /")
for i in 1:size(branch,1)
    println(fp, branch[i,1], " . ", branch[i,3])
end
println(fp, "/;\n")

for j in 4:size(branch,2)
    println(fp, "PARAMETER $(header[j])(branch_ind) /")
    for i in 1:size(branch,1)
        println(fp, branch[i,1], "  ", branch[i,j])
    end
    println(fp, "/;\n")
end
close(fp)
