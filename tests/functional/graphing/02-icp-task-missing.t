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
# Test for GH bug #955, missing initial task depending on pre-initial.
. "$(dirname "$0")/test_header"
#-------------------------------------------------------------------------------
set_test_number 3
#-------------------------------------------------------------------------------
install_workflow "${TEST_NAME_BASE}" "${TEST_NAME_BASE}"
#-------------------------------------------------------------------------------
TEST_NAME="${TEST_NAME_BASE}-validate"
run_ok "${TEST_NAME}" cylc validate "${WORKFLOW_NAME}"
#-------------------------------------------------------------------------------
TEST_NAME="${TEST_NAME_BASE}-r1"
graph_workflow "${WORKFLOW_NAME}" 'r1.graph.plain.test' \
   --set='INCLUDE_R1="true"' \
   20150304T00Z +P2D
cmp_ok 'r1.graph.plain.test' "${TEST_SOURCE_DIR}/${TEST_NAME_BASE}/graph.plain.ref"
#-------------------------------------------------------------------------------
TEST_NAME="${TEST_NAME_BASE}-no-r1"
graph_workflow "${WORKFLOW_NAME}" 'no-r1.graph.plain.test' \
   --set='INCLUDE_R1="false"' \
   20150304T00Z +P2D
cmp_ok 'no-r1.graph.plain.test' "${TEST_SOURCE_DIR}/${TEST_NAME_BASE}/graph.plain.ref"
#-------------------------------------------------------------------------------
purge
