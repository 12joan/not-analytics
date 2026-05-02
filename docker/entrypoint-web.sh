#!/bin/bash
set -e
export TZ="Europe/London"
rm -f /app/tmp/pids/server.pid
rails db:prepare
exec "$@"
