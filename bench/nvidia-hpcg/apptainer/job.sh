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

IMAGE="${HOME}/apptainer-builds/alma-nvidia-hpcg+latest.sif"
NVIDIA_HPCG_ARGS="${NVIDIA_HPCG_ARGS:-"--nx=128 --ny=128 --nz=128 --rt=60"}"
NVIDIA_HPCG_THREADS_PER_PROC="${NVIDIA_HPCG_THREADS_PER_PROC:-1}"
# Nvidia's HPCG doesn't work with --arg=123 format
# It uses space instead of equals (separate args)
NVIDIA_HPCG_ARGS="$(echo $NVIDIA_HPCG_ARGS | tr '=' ' ')"

module load OpenMPI/4.1.7a1

mpirun \
    apptainer exec \
        --nv \
        --env "OMP_NUM_THREADS=$NVIDIA_HPCG_THREADS_PER_PROC" \
        "$IMAGE" \
            /workspace/hpcg/hpcg.sh $NVIDIA_HPCG_ARGS

mpirun sh -c "echo hostname: \$(hostname)"
mpirun nvidia-smi -L

