#!/bin/bash
# Simple relax script for airss -> lammps

module purge
module load GCC/10.2.0 OpenBLAS/0.3.12

MPI_ARGS="-np 4"

Help()
{
	echo "pipe .cell file names into program"
	echo "-p sets the pressure"
	echo "-i sets the input file name"
	echo "-n sets the number of iterations"
	echo "-L sets the lammps input script location"
	echo "-l sets the program to output to relax.log"
	echo "-h outputs this script"
}

do_press()
{
	echo $(echo "$1 / 6.241509125883258^-07" | bc -l)
}

Main()
{
	ROOT=$(pwd)
	pressure=${pressure:-1}
	if [ -z $num ]; then
		num=1
	fi
	name=$(basename ${1%.*})
	if ! [ -d ${DIR:-$ROOT}/$name ]; then
		mkdir ${DIR:-$ROOT}/$name
	fi
	cd ${DIR:-$ROOT}/$name
	for (( n=1; n<=num; n++))
	do
		if [ -z $1 ]; then
			echo "No input into main()"
			exit
		else
			if [ ${1##*.} == "cell" ]; then
				i=0
				while [[ -e built_$name-$i.cell || -L built_$name-$i.cell ]] ; do
					let i++
				done
				file_name=$name-$i
				buildcell < $ROOT/$1 > built_${file_name}.cell
				cell2lammps built_${file_name}.cell > lammps_${file_name}.in
				echo "Executing lammps script with pressure = $pressure"
				lmp_mpi -log log.log -var press $pressure -var file lammps_${file_name} -var DIR ${LAMMPS_IN:-$ROOT} < ${LAMMPS_IN:-$ROOT}/airss_lammps.in
			else 
				echo "error filetype not .cell"
				exit
			fi
		fi
	done
} 

while getopts hli:p:n:L:d: flag
do
	case "${flag}" in
		i) I_FLAG=1; file=${OPTARG};;
		p) pressure=$(do_press $OPTARG);;
		h) Help exit;;
		n) num=${OPTARG};;
		l) exec 1>./relax.log 2>./relax.log;;
		L) LAMMPS_IN=${OPTARG};;
		d) DIR=${OPTARG};;
		*) Help exit;;
	esac
done

if [ -z $file ]; then
	Help
	echo "Enter File Name: "
	while read line
	do	
		Main $line &
	done
else
	Main $file
fi
	
