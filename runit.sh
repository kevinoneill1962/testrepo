#!/bin/bash
# This is junk
time docker run \
            --rm \
            -e ROBOT_THREADS=4 \
            -e BROWSER=chrome \
            -e ROBOT_OPTIONS="--loglevel TRACE:INFO" \
            -v ${PWD}/reports:/opt/robotframework/reports \
            -v ${PWD}/test:/opt/robotframework/tests \
            kon/test

