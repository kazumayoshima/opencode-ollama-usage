#!/usr/bin/env bash
# Instalador de opencode-ollama-usage
# Muestra una barra superior fija en tmux con el uso de Ollama Cloud:
#   session usage, weekly usage (barras de progreso + % + reset)
#   modelo mas usado, y tiempo de sesion (reloj).
#
# Requisitos: tmux, opencode, curl, awk, grep, sed, date, stat.
# (herramientas bash/awk estandar de cualquier distribucion)
#
# La API key NO se guarda ni expone aqui: se lee de la instalacion de
# opencode ($HOME/.local/share/opencode/auth.json) en tiempo de ejecucion.
#
# Uso:
#   ./install.sh            # instala en ~/.local/bin (usa opencode-tmux)
#   ./install.sh --dry-run  # solo muestra pasos sin ejecutar
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
    *) echo "opcion desconocida: $a (usa --help)" >&2; exit 1 ;;
  esac
done

info()  { echo -e "$TAG $*"; }
warn()  { echo -e "$TAG [warn] $*" >&2; }
die()   { echo -e "$TAG [error] $*" >&2; exit 1; }

# ---- 1. dependencias ----
info "Revisando dependencias..."
MISSING=()
for bin in tmux opencode curl awk grep sed date stat; do
  if command -v "$bin" >/dev/null 2>&1; then
    info "  OK  $bin ($(command -v "$bin"))"
  else
    warn "  FALTA $bin"
    MISSING+=("$bin")
  fi
done
if [ "${#MISSING[@]}" -gt 0 ]; then
  die "Faltan binarios: ${MISSING[*]}. Instalalos antes de continuar."
fi

# ---- 2. key de ollama (sin exponerla) ----
AUTH="$HOME/.local/share/opencode/auth.json"
if [ -f "$AUTH" ]; then
  if grep -q '"ollama-cloud"' "$AUTH" 2>/dev/null && grep -q '"key"' "$AUTH" 2>/dev/null; then
    info "  OK  auth de opencode presente: $AUTH"
  else
    warn "auth.json no contiene 'ollama-cloud'; las barras mostraran 'no key'"
  fi
else
  warn "No se encontro $AUTH"
  warn "Ollama Cloud debe estar logueado en opencode. Las barras mostraran 'no key'."
fi
info "  (la key se lee en runtime desde opencode; no se copia ni imprime)"

# ---- 3. copiar scripts ----
if [ "$DRY_RUN" = "1" ]; then
  info "[dry-run] se copiarian a $PREFIX: ${FILES[*]}"
else
  mkdir -p "$PREFIX"
  for f in "${FILES[@]}"; do
    [ -f "$SRC_DIR/$f" ] || die "falta archivo: $SRC_DIR/$f"
    cp "$SRC_DIR/$f" "$PREFIX/$f"
    chmod +x "$PREFIX/$f"
    info "  instalado: $PREFIX/$f"
  done
fi

# ---- 4. comprobar PATH ----
case ":$PATH:" in
  *":$PREFIX:"*) info "  OK  $PREFIX ya esta en PATH" ;;
  *) warn "$PREFIX no esta en PATH. Anadelo para usar 'opencode-tmux' directamente."
     warn "  export PATH=\"$PREFIX:\$PATH\"" ;;
esac

# ---- 5. resumen ----
info "Listo. Ejecuta:  opencode-tmux   (en lugar de 'opencode')"
info "Dentro de tmux puedes cerrar la sesion con: tmux detach (C-b d)"
