#!/usr/bin/env bash

PRIVILEGED_USER=sys
PRIVILEGED_PASSWORD=oracle

PETE_USER=PETE_000200
PETE_PASSWORD=PETE_000200
PETE_CONNECT_STRING=local

sql /nolog << EOF

connect $PRIVILEGED_USER/$PRIVILEGED_PASSWORD@$PETE_CONNECT_STRING as sysdba

@drop configured development
@create configured development

connect $PETE_USER/$PETE_PASSWORD@$PETE_CONNECT_STRING

@uninstall development
@install public development
@test configured

exit
EOF
