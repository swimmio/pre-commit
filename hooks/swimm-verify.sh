#!/bin/bash

# A check to make sure all documentation is up-to-date as a pre-commit hook.
# Written by Tim Post <tim@swimm.io> April 2021
# Permission to use and distribute granted under the MIT license


ARGS="verify"

set -e

# Make certain that our CLI can be found locally

export PATH=$PATH:/usr/local/bin

# Make sure we can continue

APP=$(which swimm) || {
	echo "The swimm CLI tool could not be located. Please contact support."
	exit 1
}

# Everything checks out, time to swimm! Err, time to verify!
$APP $ARGS

exit $?
