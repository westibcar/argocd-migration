#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
APP_FILE="${REPO_ROOT}/applications/argocd-self-managed.yaml"

echo "=== Deploy de Argo CD Self-Managed ==="
echo

echo "[1] Validando arquivo Application..."
if ! kubectl apply -f "$APP_FILE" --dry-run=server >/dev/null 2>&1; then
  echo "❌ Erro ao validar Application"
  exit 1
fi
echo "✓ Application válida"
echo

echo "[2] Aplicando Application argocd..."
kubectl apply -f "$APP_FILE"
echo "✓ Application aplicada"
echo

echo "[3] Aguardando sincronização..."
for i in {1..30}; do
  SYNC=$(kubectl get app argocd -n argocd -o jsonpath='{.status.sync.status}' 2>/dev/null || echo "Unknown")
  HEALTH=$(kubectl get app argocd -n argocd -o jsonpath='{.status.health.status}' 2>/dev/null || echo "Unknown")
  echo "  [$i/30] Sync: $SYNC, Health: $HEALTH"
  
  if [ "$SYNC" = "Synced" ] && [ "$HEALTH" = "Healthy" ]; then
    echo "✓ Application sincronizada e saudável!"
    break
  fi
  sleep 5
done
echo

echo "=== Deploy Completo ==="
echo
echo "Próximo passo:"
echo "  bash scripts/04-verify-migration.sh"
