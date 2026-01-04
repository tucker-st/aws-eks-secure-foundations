#!/bin/sh
set -e
bad="$(git ls-files | grep -i -E 'rhcsa|ex200|cram|mock|autograd|lab|practice' || true)"
if [ -n "$bad" ]; then
  echo "ERROR: RHCSA artifacts detected in this AWS repo:"
  echo "$bad"
  exit 1
fi
echo "OK: No RHCSA artifacts detected."
