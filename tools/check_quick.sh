#!/bin/bash
#shellcheck disable=SC2012
set -euo pipefail
whereami="$(dirname "${BASH_SOURCE[0]}")"
#shellcheck source=find-icd-home.sh
source "${whereami}/find-icd-home.sh"
# ICD_HOME=$(find_icd_home)

IFS=$'\n\t'
tmpd=$(mktemp -d /tmp/icdquickcheck.XXXXXXXXXXX)
function finish {
    #	  rm -rf "$tmpd"
    echo "Finished with $tmpd"
}
trap finish EXIT
#rsync -r --exclude=".git" "${ICD_HOME:-$HOME/rprojects/icd}" "$tmpd"
pushd "$tmpd"
"${whereami}"/build.sh \
    --no-build-vignettes \
    --no-manual \
    --resave-data=no

# try to unset debug flag, so ccache caches the results regardless of original path,
# or configure ccache to do this

# for all environment variable options see here:
# https://cran.r-project.org/doc/manuals/r-release/R-ints.html#Tools
# R_MAKEVARS_USER="$HOME/.R/Makevars.mac.quick" \
R_MAKEVARS_USER=${HOME}/.R/Makevars.quick \
    MAKEFLAGS=-j$(getconf _NPROCESSORS_ONLN) \
    _R_CHECK_ALL_NON_ISO_C_=TRUE \
    _R_CHECK_CODE_ASSIGN_TO_GLOBALENV_=TRUE \
    _R_CHECK_CODETOOLS_PROFILE_="suppressLocalUnused=FALSE" \
    _R_CHECK_COMPACT_DATA_=false \
    _R_CHECK_COMPILATION_FLAGS_=FALSE \
    _R_CHECK_CRAN_INCOMING_=false \
    _R_CHECK_CRAN_INCOMING_REMOTE_=false \
    _R_CHECK_EXIT_ON_FIRST_ERROR_=TRUE \
    _R_CHECK_NATIVE_ROUTINE_REGISTRATION_=TRUE \
    _R_CHECK_NO_STOP_ON_TEST_ERROR_=FALSE \
    _R_CHECK_RD_EXAMPLES_T_AND_F_=TRUE \
    _R_CHECK_RD_LINE_WIDTHS_=true \
    _R_CHECK_TESTS_NLINES_=0 \
    _R_CHECK_USE_INSTALL_LOG_=FALSE \
    _R_CHECK_VIGNETTES_NLINES_=0 \
    _R_CHECK_PKG_SIZES_=false \
    _R_CHECK_LENGTH_1_CONDITION_="verbose" \
    _R_CHECK_LENGTH_1_LOGIC2_="verbose" \
    R CMD check \
    --no-build-vignettes \
    --ignore-vignettes \
    "$(ls -t "$tmpd"/icd*.tar.gz | head -1)"
    popd
    #   _R_CHECK_PKG_SIZES_THRESHOLD_=50 \
