#!/usr/bin/env bash
set -eu
IFS=$'\n\t'

ICD_HOME="${ICD_HOME:-${HOME}/icd}"

R CMD build \
    --log \
    --compact-vignettes=gs+qpdf \
    "$@" \
    "${ICD_HOME}"

