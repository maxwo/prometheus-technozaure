#!/bin/bash

set -eu -o pipefail

confd -onetime -backend env
echo "${ZOO_MY_ID:-1}" > "${ZOO_DATA_DIR}/myid"

exec "$@"
