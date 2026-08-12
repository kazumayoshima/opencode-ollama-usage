#!/usr/bin/env bash
# Installer for opencode-ollama-usage
# Shows a fixed top bar in tmux with Ollama Cloud usage:
#   session usage, weekly usage (progress bars + % + reset)
#   most-used model, and session time (clock).
#
# Requirements: tmux, opencode, curl, awk, grep, sed, date, stat.
# (standard bash/awk tools available on any distribution)
#
# The API key is NOT stored or exposed here: it is read from the opencode
# installation ($HOME/.local/share/opencode/auth.json) at runtime.
#
# Usage:
#   ./install.sh            # installs into ~/.local/bin (uses opencode-tmux)
#   ./install.sh --dry-run  # only show steps without executing
#   ./install.sh --help
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local/bin}"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
FILES=(ollama-usage opencode-session-time opencode-ruler opencode-tmux)
TAG="[opencode-ollama-usage]"

DRY_RUN=0
for a in "$@"; do
  case "$a" in
    --help|-h)
      sed -n '2,30p' "$0" | grep '^#' | sed 's/^# \?//'
      exit 0 ;;
    --dry-run) DRY_RUN=1 ;;
    *) echo "unknown option: $a (use --help)" >&2; exit 1 ;;
  esac
done

info()  { echo -e "$TAG $*"; }
warn()  { echo -e "$TAG [warn] $*" >&2; }
die()   { echo -e "$TAG [error] $*" >&2; exit 1; }

# ---- 1. dependencies ----
info "Checking dependencies..."
MISSING=()
for bin in tmux opencode curl awk grep sed date stat; do
  if command -v "$bin" >/dev/null 2>&1; then
    info "  OK  $bin ($(command -v "$bin"))"
  else
    warn "  MISSING $bin"
    MISSING+=("$bin")
  fi
done
if [ "${#MISSING[@]}" -gt 0 ]; then
  die "Missing binaries: ${MISSING[*]}. Install them before continuing."
fi

# ---- 2. ollama key (without exposing it) ----
AUTH="$HOME/.local/share/opencode/auth.json"
if [ -f "$AUTH" ]; then
  if grep -q '"ollama-cloud"' "$AUTH" 2>/dev/null && grep -q '"key"' "$AUTH" 2>/dev/null; then
    info "  OK  opencode auth present: $AUTH"
  else
    warn "auth.json does not contain 'ollama-cloud'; bars will show 'no key'"
  fi
else
  warn "Could not find $AUTH"
  warn "Ollama Cloud must be logged in on opencode. Bars will show 'no key'."
fi
info "  (the key is read at runtime from opencode; it is not copied or printed)"

# ---- 3. copy scripts ----
if [ "$DRY_RUN" = "1" ]; then
  info "[dry-run] would copy to $PREFIX: ${FILES[*]}"
else
  mkdir -p "$PREFIX"
  for f in "${FILES[@]}"; do
    [ -f "$SRC_DIR/$f" ] || die "missing file: $SRC_DIR/$f"
    cp "$SRC_DIR/$f" "$PREFIX/$f"
    chmod +x "$PREFIX/$f"
    info "  installed: $PREFIX/$f"
  done
fi

# ---- 4. check PATH ----
case ":$PATH:" in
  *":$PREFIX:"*) info "  OK  $PREFIX already in PATH" ;;
  *) warn "$PREFIX is not in PATH. Add it to use 'opencode-tmux' directly."
     warn "  export PATH=\"$PREFIX:\$PATH\"" ;;
esac

# ---- 5. summary ----
info "Done. Run:  opencode-tmux   (instead of 'opencode')"
info "Inside tmux you can close the session with: tmux detach (C-b d)"
