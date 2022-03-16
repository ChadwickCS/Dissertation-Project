# Test of RS potential 

units		metal
#lattice         sc 10.0
boundary	p p p

atom_style	atomic

region mybox 	block 0 10.91 0 10.91 0 10.91
create_box 	1 mybox
create_atoms 	1 random 500 ${rand} mybox

mass 1 1.0

pair_style	quip
pair_coeff	* * ip_attr.parms.RS.xml "IP RS" 1

neighbor	0.3 bin
#neigh_modify	delay 10
#neigh_modify  	one 3200

minimize 	1.0e-4 1.0e-6 100 10000

run		1

velocity	all create ${temp} ${rand} rot no dist gaussian

fix		1 all npt temp ${temp} ${temp} 1e-2.0 iso ${pressure} ${pressure} 1e-1.0
thermo		10
timestep	5e-6

dump		1 all cfg 100 ${file}_*.cfg mass type xs ys zs vx vy vz
dump_modify   	1 element H
dump_modify   	1 pad 8
dump_modify	1 sort id

run		400000
