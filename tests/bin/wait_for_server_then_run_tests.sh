#!/usr/bin/env bash
##
## This software is Copyright ©️ 2020 The University of Southern California. All Rights Reserved.
## Permission to use, copy, modify, and distribute this software and its documentation for educational, research and non-profit purposes, without fee, and without a written agreement is hereby granted, provided that the above copyright notice and subject to the full license file found in the root of this software deliverable. Permission to make commercial use of this software may be obtained by contacting:  USC Stevens Center for Innovation University of Southern California 1150 S. Olive Street, Suite 2300, Los Angeles, CA 90115, USA Email: accounting@stevens.usc.edu
##
## The full terms of this copyright and license should always be found in the root directory of this software deliverable as "license.txt" and if these terms are not found with this software, please contact the USC Stevens Center for the full license.
##

BIN="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
timeout=10

timer=0
echo "waiting for server to respond to ping"
until $(curl --output /dev/null --silent --head --fail http://localhost:5000/mentor-api/ping); do
    printf '.'
    timer=$((timer+1))
    if [[ $timer -gt $timeout ]]; then
        echo
        echo "ERROR: timeout waited ${timeout} secs for server to respond to ping"
        exit 1
    fi
    sleep 1
done

echo 
echo "server ready, running behave tests..."
behave
