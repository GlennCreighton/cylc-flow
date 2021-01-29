#!/usr/bin/env bash
# THIS FILE IS PART OF THE CYLC SUITE ENGINE.
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
# Test suite event handler, flexible interface
. "$(dirname "$0")/test_header"
set_test_number 5

install_suite "${TEST_NAME_BASE}" "${TEST_NAME_BASE}"
run_ok "${TEST_NAME_BASE}-validate" \
    cylc validate "${SUITE_NAME}"

suite_run_ok "${TEST_NAME_BASE}-run1" \
    cylc play --reference-test --debug --no-detach "${SUITE_NAME}"

LOG="${SUITE_RUN_DIR}/log/suite/log"
MESSAGE="('suite-event-handler-00', 'startup') bad template: 'rubbish'"
run_ok "${TEST_NAME_BASE}-run1-log" grep -q -F "ERROR - ${MESSAGE}" "${LOG}"

delete_db
suite_run_fail "${TEST_NAME_BASE}-run2" \
    cylc play --reference-test --debug --no-detach \
        -s 'ABORT="True"' "${SUITE_NAME}"

run_ok "${TEST_NAME_BASE}-run2-err" \
    grep -q -F "Suite shutting down - ${MESSAGE}" \
    "${TEST_NAME_BASE}-run2.stderr"

purge
exit
