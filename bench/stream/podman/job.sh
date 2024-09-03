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
PROLOG_PODMAN="${HOME}/.config/containers/prolog.sh"
ARRAY_SIZE_SCRIPT="${HOME}/bench/stream/arr_size.sh"

# Make sure individual array size is at least 4 times the size of system cache
ARRAY_SIZE=$($ARRAY_SIZE_SCRIPT) && \
	echo "Array size: $ARRAY_SIZE" || \
	echo "Error: Can't get array size" 1>&2 || exit 1

# First "podman run" job step usually fails with sbatch
srun --prolog="$PROLOG_PODMAN" podman run --rm "alpine" > /dev/null 2>&1

srun \
	sh -c " \
		sh $PROLOG_PODMAN ; \
		podman run \
			--rm \
			$IMAGE \
			/bin/stream.$ARRAY_SIZE
	"
