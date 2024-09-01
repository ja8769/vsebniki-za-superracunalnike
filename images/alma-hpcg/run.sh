#!/bin/bash

WORKDIR="$1"
shift

# Check if output dir is set
test -z "$WORKDIR" && echo "Error: output directory for hpcg not specified" && exit 1
mkdir -p "$WORKDIR" && cd "$WORKDIR"

if [ -n "$OMPI_COMM_WORLD_RANK" ]; then
    echo "MPI rank ${OMPI_COMM_WORLD_RANK} is on host $(hostname)"
    /bin/xhpcg $*
else
    NPROC="$1"
    shift
    test -z "$NPROC" && echo "Error: Missing MPI process count argument" && exit 1
    echo "Running ${NPROC} MPI processes on host $(hostname)"
    mpirun -np "$NPROC" --allow-run-as-root /bin/xhpcg $*
fi
