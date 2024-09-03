#!/bin/sh

# Make sure individual array size is at least 4 times the size of system cache
CACHE_SIZE_BYTES=$(lscpu -B -C=ALL-SIZE | tail -n +2 | awk "{sum+=\$1}; END{printf sum}")
if [ $(( 8 * 10000000 )) -gt $(( 4 * CACHE_SIZE_BYTES )) ]; then
	ARRAY_SIZE="10M"
elif [ $(( 8 * 20000000 )) -gt $(( 4 * CACHE_SIZE_BYTES )) ]; then
	ARRAY_SIZE="20M"
elif [ $(( 8 * 50000000 )) -gt $(( 4 * CACHE_SIZE_BYTES )) ]; then
	ARRAY_SIZE="50M"
elif [ $(( 8 * 100000000 )) -gt $(( 4 * CACHE_SIZE_BYTES )) ]; then
	ARRAY_SIZE="100M"
elif [ $(( 8 * 200000000 )) -gt $(( 4 * CACHE_SIZE_BYTES )) ]; then
	ARRAY_SIZE="200M"
elif [ $(( 8 * 500000000 )) -gt $(( 4 * CACHE_SIZE_BYTES )) ]; then
	ARRAY_SIZE="500M"
else
	echo "Error: No available array size is large enough for current cache configuration" 1>&2
	exit 1
fi
echo "$ARRAY_SIZE"
