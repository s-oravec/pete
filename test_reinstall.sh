#!/usr/bin/env bash

PETE_USER=PETE_000200
PETE_PASSWORD=PETE_000200
PETE_CONNECT_STRING=local

sql /nolog << EOF

connect $PETE_USER/$PETE_PASSWORD@$PETE_CONNECT_STRING

@uninstall development
@install public development
@test configured

exit
EOF
