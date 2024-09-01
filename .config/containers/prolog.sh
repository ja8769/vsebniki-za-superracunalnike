#!/bin/sh

# Sometimes the pause process causes problems
rm "/tmp/run-${UID}/libpod/tmp/pause.pid" 2> /dev/null

# This doesn't get created automatically for some reason
mkdir -p "${XDG_RUNTIME_DIR}/libpod/tmp"

# Create OpenMPI directory
mkdir -p "/tmp/podman-mpirun"
