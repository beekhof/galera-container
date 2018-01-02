#!/bin/bash

: ${OCF_ROOT=/usr/lib/ocf}
: ${OCF_FUNCTIONS_DIR=${OCF_ROOT}/lib/heartbeat}
. ${OCF_FUNCTIONS_DIR}/ocf-shellfuncs
. ${OCF_FUNCTIONS_DIR}/mysql-common.sh
. container-common.sh

clog info "Replicating state from $(gcomm_from_args $*)..."
OCF_RESKEY_enable_creation=false

mysql_common_prepare_dirs
mysql_common_start "--wsrep-cluster-address=$(gcomm_from_args $*)"
handle_result "replication" $?
