#!/bin/bash

#SBATCH --job-name=sysbench	
##SBATCH --reservation=psistemi	
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --output=out/out.txt
#SBATCH --time=00:30:00
#SBATCH --mem=16G

IMAGE="ghcr.io/jan146/alma-sysbench:latest"
PROLOG_PODMAN="${HOME}/.config/containers/prolog.sh"
SYSBENCH_ARGS_SINGLE=${SYSBENCH_ARGS_SINGLE:-"--threads=$(nproc) --cpu-max-prime=10000"}
SYSBENCH_ARGS_MULTI=${SYSBENCH_ARGS_MULTI:-"--threads=$(nproc) --cpu-max-prime=10000"}
SYSBENCH_SKIP_SINGLE=${SYSBENCH_SKIP_SINGLE:-""}
OUTPUT_DIR="${HOME}/bench/sysbench/podman/out"

# Eval $(nproc) in SYSBENCH_ARGS_*
SYSBENCH_ARGS_SINGLE=$(eval echo "$SYSBENCH_ARGS_SINGLE")
SYSBENCH_ARGS_MULTI=$(eval echo "$SYSBENCH_ARGS_MULTI")

# First "podman run" job step usually fails with sbatch
srun --prolog="$PROLOG_PODMAN" podman run --rm "alpine" > /dev/null 2>&1

if [ -z "$SYSBENCH_SKIP_SINGLE" ]; then
    srun --output="${OUTPUT_DIR}/out_single.txt" \
    	sh -c " \
    		sh $PROLOG_PODMAN ; \
    		podman run \
    			--rm \
    			$IMAGE \
    			/bin/sysbench --test=cpu run $SYSBENCH_ARGS_SINGLE \
    	"
fi

srun --output="${OUTPUT_DIR}/out_multi.txt" \
	sh -c " \
		sh $PROLOG_PODMAN ; \
		podman run \
			--rm \
			$IMAGE \
			/bin/sysbench --test=cpu run $SYSBENCH_ARGS_MULTI \
	"

