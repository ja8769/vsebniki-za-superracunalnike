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
SYSBENCH_ARGS_SINGLE=${SYSBENCH_ARGS_SINGLE:-"--threads=$(nproc) --cpu-max-prime=10000"}
SYSBENCH_ARGS_MULTI=${SYSBENCH_ARGS_MULTI:-"--threads=$(nproc) --cpu-max-prime=10000"}
SYSBENCH_SKIP_SINGLE=${SYSBENCH_SKIP_SINGLE:-""}
UDOCKER_EXEC_MODE="${UDOCKER_EXEC_MODE:-P1}"
OUTPUT_DIR="${HOME}/bench/sysbench/udocker/out_${UDOCKER_EXEC_MODE}"
CONT_NAME="sysbench_${UDOCKER_EXEC_MODE}"

# Eval $(nproc) in SYSBENCH_ARGS_*
SYSBENCH_ARGS_SINGLE=$(eval echo "$SYSBENCH_ARGS_SINGLE")
SYSBENCH_ARGS_MULTI=$(eval echo "$SYSBENCH_ARGS_MULTI")

mkdir -p "$OUTPUT_DIR"

module is-loaded Python || \
	module load Python

udocker create --name="$CONT_NAME" "$IMAGE"
udocker setup --execmode="$UDOCKER_EXEC_MODE" "$CONT_NAME"

if [ -z "$SYSBENCH_SKIP_SINGLE" ]; then
    srun --output="${OUTPUT_DIR}/out_single.txt" \
    	udocker run \
    		--nobanner \
    		"$CONT_NAME" \
    		/bin/sysbench --test=cpu run $SYSBENCH_ARGS_SINGLE
fi

srun --output="${OUTPUT_DIR}/out_multi.txt" \
	udocker run \
		--nobanner \
		"$CONT_NAME" \
		/bin/sysbench --test=cpu run $SYSBENCH_ARGS_MULTI

udocker rm "$CONT_NAME"

