#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# push-to-github.sh
# Clona el repo LuchoN83/DevSecOps, copia el proyecto generado y hace push
# a la rama develop.
#
# Uso:
#   chmod +x push-to-github.sh
#   ./push-to-github.sh
#
# Requiere:
#   - git instalado
#   - GitHub CLI (gh) autenticado  →  gh auth login
#     ó un PAT exportado           →  export GITHUB_TOKEN=ghp_xxxx
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────
REPO_URL="https://github.com/LuchoN83/DevSecOps.git"
BRANCH="develop"
TARGET_FOLDER="container-security-observability"
COMMIT_MSG="feat(portfolio): add container-security-observability project

- Dockerfile multi-stage distroless (nonroot, read-only FS)
- GitHub Actions pipeline: Semgrep → Trivy → Cosign → SBOM (Syft)
- Kyverno policies: verify-signature + pod security standards
- Falco custom rules for runtime threat detection (eBPF)
- NetworkPolicy zero-trust (deny-all + explicit allow-list)
- Prometheus metrics in app + PrometheusRule (SLO + Falco alerts)
- Grafana dashboard (latency, error rate, Falco events, Loki logs)
- Helm values-stack.yaml (Prometheus, Loki, Falco, Kyverno)
- Kustomize overlays: dev (1 replica) / prd (HPA 2-8)

Closes #container-security"

# Ruta al proyecto generado (carpeta donde está este script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_SRC="$SCRIPT_DIR/container-security-observability"

# ── Colores ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${GREEN}[✓]${NC} $*"; }
warning() { echo -e "${YELLOW}[!]${NC} $*"; }
error()   { echo -e "${RED}[✗]${NC} $*"; exit 1; }

# ── Validaciones previas ──────────────────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════════════════"
echo "  DevSecOps Portfolio — push container-security-observability"
echo "══════════════════════════════════════════════════════"
echo ""

command -v git >/dev/null 2>&1 || error "git no está instalado."

if [[ ! -d "$PROJECT_SRC" ]]; then
  error "No se encontró la carpeta del proyecto en: $PROJECT_SRC
  Asegúrate de que 'container-security-observability/' esté en el mismo
  directorio que este script."
fi

# Verificar autenticación GitHub
if command -v gh >/dev/null 2>&1; then
  gh auth status >/dev/null 2>&1 || warning "GitHub CLI no autenticado. Usando GITHUB_TOKEN si está disponible."
elif [[ -z "${GITHUB_TOKEN:-}" ]]; then
  warning "No se detectó 'gh' CLI ni GITHUB_TOKEN. Git pedirá credenciales manualmente."
fi

# ── Clonar repo ───────────────────────────────────────────────────────────────
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

info "Clonando $REPO_URL (rama: $BRANCH)..."

# Si hay token, inyectarlo en la URL
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  AUTH_URL="https://${GITHUB_TOKEN}@github.com/LuchoN83/DevSecOps.git"
else
  AUTH_URL="$REPO_URL"
fi

git clone --branch "$BRANCH" --depth 1 "$AUTH_URL" "$WORK_DIR/repo"
info "Repo clonado en $WORK_DIR/repo"

# ── Copiar proyecto ───────────────────────────────────────────────────────────
DEST="$WORK_DIR/repo/$TARGET_FOLDER"

if [[ -d "$DEST" ]]; then
  warning "La carpeta '$TARGET_FOLDER' ya existe en el repo. Será reemplazada."
  rm -rf "$DEST"
fi

cp -r "$PROJECT_SRC" "$DEST"
info "Archivos copiados a $DEST"

# ── Verificar qué cambia ──────────────────────────────────────────────────────
cd "$WORK_DIR/repo"
echo ""
echo "── Archivos que se agregarán / modificarán ──────────────"
git status --short "$TARGET_FOLDER"
echo ""

# Confirmar antes de hacer push
read -rp "¿Continuar con el commit y push? [s/N] " CONFIRM
[[ "${CONFIRM,,}" == "s" ]] || { warning "Operación cancelada."; exit 0; }

# ── Commit y push ─────────────────────────────────────────────────────────────
git config user.email "lucho.navarrete@globant.com"
git config user.name  "Lucho Navarrete"

git add "$TARGET_FOLDER"
git commit -m "$COMMIT_MSG"

info "Haciendo push a origin/$BRANCH..."
git push origin "$BRANCH"

echo ""
echo "══════════════════════════════════════════════════════"
info "¡Listo! El proyecto está en:"
echo "  https://github.com/LuchoN83/DevSecOps/tree/$BRANCH/$TARGET_FOLDER"
echo "══════════════════════════════════════════════════════"
echo ""
