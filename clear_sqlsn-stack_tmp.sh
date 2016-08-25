#!/usr/bin/env bash

# Sometimes sqlsn stucks and the only thing that helps is to clear temp ... sorry

pushd "$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)" 1> /dev/null
rm oradb_modules/sqlsn/sqlsn_modules/sqlsn-stack/lib/tmp/* 2> /dev/null
popd 1> /dev/null