#!/usr/bin/env bash
# =============================================================================
# ... (header and variables same as previous) ...
# =============================================================================

set -euo pipefail

# Extensions...
EXTENSOES=( "*.nix" "*.json" "*.css" "*.conf" )
DUMP_FILE="DUMP.log"

# Colors...
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# =============================================================================
# Dump generation (same as previous)
# =============================================================================

echo "Generating ${DUMP_FILE}..."

: > "$DUMP_FILE"

find . -type f \
    \( -name "*.nix" -o -name "*.json" -o -name "*.css" -o -name "*.conf" \) \
    -not -path "*/.git/*" \
    -not -path "*/.github/*" \
    -not -name "*.bak" \
    | sort \
    | while read -r arquivo; do
        caminho_relativo="${arquivo#./}"
        {
            echo "# ----------"
            echo "# $caminho_relativo"
            echo "# ----------"
            echo ""
            cat "$arquivo"
            echo ""
            echo ""
        } >> "$DUMP_FILE"
    done

echo -e "${GREEN}Dump generated at:${NC} $DUMP_FILE"
echo "Files included: $(find . -type f \( -name "*.nix" -o -name "*.json" -o -name "*.css" -o -name "*.conf" \) -not -path "*/.git/*" -not -path "*/.github/*" -not -name "*.bak" | wc -l)"
