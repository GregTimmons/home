#!/usr/bin/env bash
function aws-login-if-needed {
    if aws sts get-caller-identity &> /dev/null; then
        echo "Logged in!"
    else
        aws sso login
    fi
}
