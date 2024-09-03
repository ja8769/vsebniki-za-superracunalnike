#!/bin/bash

#SBATCH --job-name=hpcg
##SBATCH --reservation=psistemi
#SBATCH --output=out/out.txt
#SBATCH --time=00:30:00
#SBATCH --mem=16G

HPCG_EXEC_PATH="${HOME}/bench/hpcg/native"
OUTPUT_DIR="${HOME}/bench/hpcg/native/out"
HPCG_ARGS="${HPCG_ARGS:-"--nx=16 --ny=16 --nz=16 --rt=10"}"
OMP_NUM_THREADS="${HPCG_THREADS_PER_PROC:-1}"
export OMP_NUM_THREADS

module is-loaded OpenMPI/4.1.2 || \
	module load OpenMPI/4.1.2

mpirun sh -c "echo hostname: \$(hostname)"

mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

export LD_LIBRARY_PATH="${HPCG_EXEC_PATH}/libs:${LD_LIBRARY_PATH}"

mpirun \
	"${HPCG_EXEC_PATH}/xhpcg" $HPCG_ARGS

cat "$OUTPUT_DIR"/HPCG-Benchmark*.txt
rm "$OUTPUT_DIR"/hpcg*.txt
rm "$OUTPUT_DIR"/HPCG-Benchmark*.txt

