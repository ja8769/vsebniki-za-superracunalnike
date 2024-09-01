#!/bin/sh

main() {
	if test -n "$PROLOG_PODMAN"
	then
		sh "$PROLOG_PODMAN"
	fi
	
	NVIDIA_YAML="${CDI_CONFIG_DIR}/nvidia.yaml"
	
	# Generate (overwrite) CDI yaml file
	nvidia-ctk cdi generate --output="$NVIDIA_YAML" 2> /dev/null
	
	# Only source, even though it was useless: https://github.com/NVIDIA/nvidia-container-runtime/issues/182
	# Using --userns=keep-id with Nvidia CDI doesn't work by default
	# Remove ld cache hook in CDI spec
	# However, you must run ldconfig manually after this
	if test -n "$PROLOG_CDI_NO_LDCACHE"; then
	    yq -i "del(.containerEdits.hooks)" "$NVIDIA_YAML"
	fi
}

if test -z "$CDI_CONFIG_DIR"
then
	CDI_CONFIG_DIR="$HOME/.config/cdi"
fi
main 1>"${CDI_CONFIG_DIR}/log.out" 2>"${CDI_CONFIG_DIR}/log.err"

