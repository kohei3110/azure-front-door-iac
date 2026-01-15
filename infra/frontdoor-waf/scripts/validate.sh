#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BICEP_FILE="$ROOT_DIR/main.bicep"
PARAM_DIR="$ROOT_DIR/parameters"

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI (az) is required to validate Bicep." >&2
  echo "Install Azure CLI, then retry." >&2
  exit 2
fi

OUT_DIR="$ROOT_DIR/.out"
mkdir -p "$OUT_DIR"

echo "==> Install/upgrade Bicep CLI"
az bicep upgrade

# az bicep upgrade installs bicep into $HOME/.azure/bin by default.
BICEP_CMD="$(command -v bicep || true)"
if [[ -z "$BICEP_CMD" && -x "$HOME/.azure/bin/bicep" ]]; then
  BICEP_CMD="$HOME/.azure/bin/bicep"
fi

if [[ -z "$BICEP_CMD" ]]; then
  echo "Bicep CLI (bicep) was not found in PATH, and $HOME/.azure/bin/bicep does not exist." >&2
  exit 2
fi

echo "==> Lint: $BICEP_FILE"
az bicep lint --file "$BICEP_FILE"

echo "==> Build: $BICEP_FILE"
az bicep build --file "$BICEP_FILE" --outdir "$OUT_DIR"

for p in dev staging prod; do
  PARAM_FILE="$PARAM_DIR/$p.bicepparam"
  if [[ ! -f "$PARAM_FILE" ]]; then
    echo "Missing parameter file: $PARAM_FILE" >&2
    exit 1
  fi

  echo "==> Build-params: $PARAM_FILE"
  "$BICEP_CMD" build-params "$PARAM_FILE" --outfile "$OUT_DIR/$p.parameters.json"

done

echo "✅ Validation succeeded. Outputs: $OUT_DIR" 
