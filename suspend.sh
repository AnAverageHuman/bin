#!/usr/bin/env bash

# Requires that the user is allowed to run pm-suspend

physlock -msd
sudo pm-suspend
exit

