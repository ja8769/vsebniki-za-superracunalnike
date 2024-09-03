#!/bin/bash

#SBATCH --job-name=nvidia-hpcg
##SBATCH --reservation=psistemi
#SBATCH --cpus-per-task=1
#SBATCH --output=out/out.txt
#SBATCH --time=00:30:00
#SBATCH --mem=16G

#SBATCH --partition=gpu
#SBATCH --constraint=h100
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gpus-per-task=1

IMAGE="ghcr.io/jan146/alma-nvidia-hpcg:latest"
TMPDIR_BASE="/tmp/udocker-mpirun-$UID"
NVIDIA_HPCG_ARGS="${NVIDIA_HPCG_ARGS:-"--nx=128 --ny=128 --nz=128 --rt=60"}"
NVIDIA_HPCG_THREADS_PER_PROC="${NVIDIA_HPCG_THREADS_PER_PROC:-1}"
# Nvidia's HPCG doesn't work with --arg=123 format
# It uses space instead of equals (separate args)
NVIDIA_HPCG_ARGS="$(echo $NVIDIA_HPCG_ARGS | tr '=' ' ')"
UDOCKER_EXEC_MODE="${UDOCKER_EXEC_MODE:-P1}"
CONT_NAME="nvidia-hpcg_${UDOCKER_EXEC_MODE}"

module is-loaded Python || \
	module load Python
module load OpenMPI/4.1.7a1

udocker create --name="$CONT_NAME" "$IMAGE"
udocker setup --nvidia "$CONT_NAME"
udocker setup --execmode="$UDOCKER_EXEC_MODE" "$CONT_NAME"

mpirun \
	--mca orte_tmpdir_base "$TMPDIR_BASE" \
	udocker run \
		--nobanner \
		--hostenv \
        --env="OMP_NUM_THREADS=$NVIDIA_HPCG_THREADS_PER_PROC" \
        --workdir="/tmp" \
		--volume="$TMPDIR_BASE" \
		--hostauth \
		--user="$USER" \
		"$CONT_NAME" \
            bash /workspace/hpcg/hpcg.sh $NVIDIA_HPCG_ARGS

mpirun sh -c "echo hostname: \$(hostname)"
mpirun nvidia-smi -L

mpirun \
	rm -rf "$TMPDIR_BASE"

udocker rm "$CONT_NAME"

