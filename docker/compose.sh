#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
docker compose -f $SCRIPT_DIR/compose.yml -p air-quality-prediction up --force-recreate -d