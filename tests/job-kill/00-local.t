#!/bin/bash
#C: THIS FILE IS PART OF THE CYLC SUITE ENGINE.
#C: Copyright (C) 2008-2014 NIWA
#C:
#C: This program is free software: you can redistribute it and/or modify
#C: it under the terms of the GNU General Public License as published by
#C: the Free Software Foundation, either version 3 of the License, or
#C: (at your option) any later version.
#C:
#C: This program is distributed in the hope that it will be useful,
#C: but WITHOUT ANY WARRANTY; without even the implied warranty of
#C: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#C: GNU General Public License for more details.
#C:
#C: You should have received a copy of the GNU General Public License
#C: along with this program.  If not, see <http://www.gnu.org/licenses/>.
#-------------------------------------------------------------------------------
# Test kill local jobs.
. $(dirname $0)/test_header
#-------------------------------------------------------------------------------
set_test_number 6
install_suite $TEST_NAME_BASE $TEST_NAME_BASE
#-------------------------------------------------------------------------------
TEST_NAME=$TEST_NAME_BASE-validate
run_ok $TEST_NAME cylc validate $SUITE_NAME
#-------------------------------------------------------------------------------
TEST_NAME=$TEST_NAME_BASE-run
suite_run_ok $TEST_NAME cylc run --reference-test --debug $SUITE_NAME
#-------------------------------------------------------------------------------
TEST_NAME=$TEST_NAME_BASE-ps
SUITE_RUN_DIR=$(cylc get-global-config --print-run-dir)/$SUITE_NAME
for DIR in $SUITE_RUN_DIR/work/*/t*; do
    run_fail $TEST_NAME-$(basename $DIR) ps $(cat $DIR/file)
done
N=0
for FILE in $SUITE_RUN_DIR/log/job/*/t*/01/job.status; do
    run_fail "$TEST_NAME-status-$((++N))" \
        ps $(awk -F= '$1 == "CYLC_JOB_PID" {print $2}' $FILE)
done
#-------------------------------------------------------------------------------
purge_suite $SUITE_NAME
exit