#!/bin/bash
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=28
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=4571

module purge
module load GCC/10.2.0 OpenMPI/4.0.5 OpenBLAS/0.3.12 parallel

do_temp() {
        echo $(echo "$1 / 0.00008617330337217213" | bc -l)
}

do_press() {
        echo $(echo "$1 / 0.0000006241509125883258" | bc -l)
}

export -f do_temp
export -f do_press

OUT_ROOT=${SLURM_JOBID} 
root_file=$(pwd)
IN_FILE="$root_file/in_random.rs"
MY_PARALLEL_OPTS="--delay .2 -j 14 --joblog parallel-${SLURM_JOBID}.log"
MPI_OPTS="-n 4"

if [ ! -d "$OUT_ROOT" ]; then
	mkdir $OUT_ROOT
fi
main() {
	temp=$1
	press=$2
	in_file=$3
	fileName="$in_file/${press/./}_${temp/./}"
	if [ ! -d "$fileName" ]; then
		mkdir $fileName
	fi	
	rand=$(od -vAn -N4 -td4 < /dev/urandom | sed "s/-//")
	lammp_opts="-var rand $rand -var file ./${fileName}/cfg -var pressure $(do_press $press) -var temp $(do_temp $temp)"
	srun -n 4 ~/lmp_mpi-QUIP -i ~/pressSims/in_random.rs ${lammp_opts} > ./$in_file/${press/./}_${temp/./}.slurm
}

export -f main

parallel $MY_PARALLEL_OPTS main {1} {2} $OUT_ROOT :::: $root_file/temperature $root_file/pressure


