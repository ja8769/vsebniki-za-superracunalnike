#!/bin/bash

#SBATCH --job-name=sysbench	
##SBATCH --reservation=psistemi
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --output=out/out.txt
#SBATCH --time=00:30:00
#SBATCH --mem=16G

IMAGE="${HOME}/apptainer-builds/alma-sysbench+latest.sif"
SYSBENCH_ARGS_SINGLE=${SYSBENCH_ARGS_SINGLE:-"--threads=$(nproc) --cpu-max-prime=10000"}
SYSBENCH_ARGS_MULTI=${SYSBENCH_ARGS_MULTI:-"--threads=$(nproc) --cpu-max-prime=10000"}
SYSBENCH_SKIP_SINGLE=${SYSBENCH_SKIP_SINGLE:-""}
OUTPUT_DIR="${HOME}/bench/sysbench/apptainer/out"

# Eval $(nproc) in SYSBENCH_ARGS_*
SYSBENCH_ARGS_SINGLE=$(eval echo "$SYSBENCH_ARGS_SINGLE")
SYSBENCH_ARGS_MULTI=$(eval echo "$SYSBENCH_ARGS_MULTI")

if [ -z "$SYSBENCH_SKIP_SINGLE" ]; then
    srun --output="${OUTPUT_DIR}/out_single.txt" \
    	apptainer exec \
    		"$IMAGE" \
    		/bin/sysbench cpu run $SYSBENCH_ARGS_SINGLE
fi

srun --output="${OUTPUT_DIR}/out_multi.txt" \
	apptainer exec \
		"$IMAGE" \
		/bin/sysbench cpu run $SYSBENCH_ARGS_MULTI
