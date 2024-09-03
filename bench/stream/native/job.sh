#!/bin/bash

#SBATCH --job-name=stream
##SBATCH --reservation=psistemi	
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --output=out/out.txt
#SBATCH --time=00:10:00
#SBATCH --mem=16G

STREAM_BIN_PATH="${HOME}/bench/stream/native/bin"
ARRAY_SIZE_SCRIPT="${HOME}/bench/stream/arr_size.sh"

# Make sure individual array size is at least 4 times the size of system cache
ARRAY_SIZE=$($ARRAY_SIZE_SCRIPT) && \
	echo "Array size: $ARRAY_SIZE" || \
	echo "Error: Can't get array size" 1>&2 || exit 1

export LD_LIBRARY_PATH="${STREAM_BIN_PATH}/../libs:${LD_LIBRARY_PATH}"

srun \
	"${STREAM_BIN_PATH}/stream.$ARRAY_SIZE"

