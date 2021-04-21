#!/usr/bin/env bash
# THIS FILE IS PART OF THE CYLC WORKFLOW ENGINE.
# Copyright (C) NIWA & British Crown (Met Office) & Contributors.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#-------------------------------------------------------------------------------
# Test restarting a simple workflow with a failed task
if [[ -z ${TEST_DIR:-} ]]; then
    . "$(dirname "$0")/test_header"
fi
#-------------------------------------------------------------------------------
set_test_number 7
#-------------------------------------------------------------------------------
install_workflow "${TEST_NAME_BASE}" 'failed'
cp "$TEST_SOURCE_DIR/lib/flow-runtime-restart.cylc" "${RUN_DIR}/${WORKFLOW_NAME}/"
#-------------------------------------------------------------------------------
TEST_NAME="${TEST_NAME_BASE}-validate"
run_ok "${TEST_NAME}" cylc validate "${WORKFLOW_NAME}"
cmp_ok "${TEST_NAME}.stderr" <'/dev/null'
#-------------------------------------------------------------------------------
TEST_NAME="${TEST_NAME_BASE}-run"
workflow_run_ok "${TEST_NAME}" cylc play --debug --no-detach "${WORKFLOW_NAME}"
#-------------------------------------------------------------------------------
TEST_NAME="${TEST_NAME_BASE}-restart-run"
workflow_run_ok "${TEST_NAME}" cylc play --debug --no-detach "${WORKFLOW_NAME}"
#-------------------------------------------------------------------------------
grep_ok "failed_task|20130923T0000Z|1|1|failed" \
    "${RUN_DIR}/${WORKFLOW_NAME}/pre-restart-db"
contains_ok "${RUN_DIR}/${WORKFLOW_NAME}/post-restart-db" <<'__DB_DUMP__'
failed_task|20130923T0000Z|1|1|failed
shutdown|20130923T0000Z|1|1|succeeded
__DB_DUMP__
"${TEST_SOURCE_DIR}/bin/ctb-select-task-states" "${WORKFLOW_RUN_DIR}" \
    > "${RUN_DIR}/${WORKFLOW_NAME}/db"
contains_ok "${RUN_DIR}/${WORKFLOW_NAME}/db" <<'__DB_DUMP__'
failed_task|20130923T0000Z|1|1|failed
finish|20130923T0000Z|1|1|succeeded
output_states|20130923T0000Z|1|1|succeeded
shutdown|20130923T0000Z|1|1|succeeded
__DB_DUMP__
#-------------------------------------------------------------------------------
purge
