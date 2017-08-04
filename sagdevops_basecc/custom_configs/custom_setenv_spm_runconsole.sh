#!/bin/sh -x

########################################################################
# The environment variable USE_WRAPPER changes the way profile instance
# is started.
# Values:
#     no    - profile instance is started by pure Java call
#     yes   - Tanuki Wrapper is used to launch the profile instance
if [ "x$USE_WRAPPER" = "x" ]; then
    USE_WRAPPER=yes
fi

#########################################################################
# The environment variable STARTUP_MODE changes the default startup mode
# of this profile instance if it is installed as a system service.
# Values:
#     service    - start the service, if any
#     console    - start as a regular process, but only if
#                  the service is not already running
if [ "x$STARTUP_MODE" = "x" ]; then
    STARTUP_MODE=console
fi

##############################################################################
# The environment variable BLOCKING_SCRIPT changes behavior of startup script
# when STARTUP_MODE is set to "console"
# Values:
#     no    - startup script is non-blocking
#     yes   - startup script is blocking
if [ "x$BLOCKING_SCRIPT" = "x" ]; then
    BLOCKING_SCRIPT=yes
fi

JAVA_MIN_MEM=32M
JAVA_MAX_PERM_SIZE=98M