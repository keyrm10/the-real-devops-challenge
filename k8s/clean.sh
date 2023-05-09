#!/usr/bin/env bash

set -euo pipefail

if kind get clusters | grep -q '^kind$'; then
  kind delete cluster --name=kind
  echo "'kind' cluster deleted successfully"
else
  echo "'kind' cluster does not exist"
fi

if [ -e /usr/local/bin/kind ]; then
  rm /usr/local/bin/kind
  echo "kind uninstalled successfully"
else
  echo "/usr/local/bin/kind does not exist"
fi
