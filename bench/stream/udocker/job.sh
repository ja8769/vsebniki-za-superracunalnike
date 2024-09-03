#!/bin/bash

#SBATCH --job-name=stream
##SBATCH --reservation=psistemi
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --output=out/out.txt
#SBATCH --time=00:10:00	
#SBATCH --mem=16G

IMAGE="ghcr.io/jan146/alma-stream:latest"
ARRAY_SIZE_SCRIPT="${HOME}/bench/stream/arr_size.sh"
UDOCKER_EXEC_MODE="${UDOCKER_EXEC_MODE:-P1}"
CONT_NAME="stream_${UDOCKER_EXEC_MODE}"

# Make sure individual array size is at least 4 times the size of system cache
ARRAY_SIZE=$($ARRAY_SIZE_SCRIPT) && \
	echo "Array size: $ARRAY_SIZE" || \
	echo "Error: Can't get array size" 1>&2 || exit 1
	
module is-loaded Python || \
	module load Python

udocker create --name="$CONT_NAME" "$IMAGE"
udocker setup --execmode="$UDOCKER_EXEC_MODE" "$CONT_NAME"

srun \
	udocker run \
		--nobanner \
		"$CONT_NAME" \
		"/bin/stream.$ARRAY_SIZE"

udocker rm "$CONT_NAME"

