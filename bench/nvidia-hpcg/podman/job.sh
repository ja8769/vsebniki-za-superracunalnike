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
OMPI_DIR="/opt/ompi"
UCX_DIR="/opt/ucx"
TMPDIR_BASE="/tmp/podman-mpirun-$UID"
# NVIDIA_HPCG_ARGS="${NVIDIA_HPCG_ARGS:-"--nx=16 --ny=16 --nz=16 --rt=10"}"
NVIDIA_HPCG_ARGS="${NVIDIA_HPCG_ARGS:-"--nx=128 --ny=128 --nz=128 --rt=60"}"
NVIDIA_HPCG_THREADS_PER_PROC="${NVIDIA_HPCG_THREADS_PER_PROC:-1}"
# Nvidia's HPCG doesn't work with --arg=123 format
# It uses space instead of equals (separate args)
NVIDIA_HPCG_ARGS="$(echo $NVIDIA_HPCG_ARGS | tr '=' ' ')"

export PROLOG_CDI_NO_LDCACHE="yes"
export PROLOG_PODMAN="${HOME}/.config/containers/prolog.sh"
PROLOG_CDI="${HOME}/.config/cdi/prolog.sh"

module load OpenMPI/4.1.7a1

# First "podman run" job step usually fails with sbatch
srun --ntasks-per-node=1 --prolog="$PROLOG_PODMAN" podman run --rm "alpine" > /dev/null 2>&1

mpirun \
	--mca orte_tmpdir_base "${TMPDIR_BASE}" \
	--mca prte_tmpdir_base "${TMPDIR_BASE}" \
	sh -c " \
		sh $PROLOG_CDI; \
		podman run \
			--rm \
			--env-host \
            --env OMP_NUM_THREADS=${NVIDIA_HPCG_THREADS_PER_PROC} \
            --env OMPI_DIR=${OMPI_DIR} \
            --env PATH=${OMPI_DIR}/bin:${UCX_DIR}/bin:${PATH}:/usr/bin:/bin:/usr/sbin:/sbin \
            --env LD_LIBRARY_PATH=${OMPI_DIR}/lib:${UCX_DIR}/lib:${LD_LIBRARY_PATH}:/usr/lib:/lib:/usr/lib64:/lib64 \
            --env OPAL_PREFIX=${OMPI_DIR} \
            --env OMPI_MCA_coll_hcoll_enable=0 \
            --env OMPI_MCA_pml=ucx \
            --env OMPI_ALLOW_RUN_AS_ROOT=1 \
            --env OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
			-v ${TMPDIR_BASE}:${TMPDIR_BASE} \
			--userns=keep-id \
			--net=host \
			--pid=host \
			--ipc=host \
            --device=nvidia.com/gpu=all \
			$IMAGE \
                sh -c \" \
					ldconfig /usr/lib64 ; \
					/workspace/hpcg/hpcg.sh $NVIDIA_HPCG_ARGS \
				\" \
	"

mpirun sh -c "echo hostname: \$(hostname)"
mpirun nvidia-smi -L

