#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
EXTRACT_DIR="${REPO_ROOT}/cenario-2-migracao-manual-para-gitops/extracted-config"

echo "=== Validação de Extração ==="
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/..)" && pwd)"
EXTRACT_DIR="${REPO_ROOT}/extracted-config"

echo "=== Validação de Extração ==="
echo

# Função para validar arquivo
validate_file() {
  local file=$1
  local name=$2
  if [ -f "$file" ] && [ -s "$file" ]; then
    echo "✓ $name: $(wc -l < "$file") linhas"
    return 0
  else
    echo "⚠️  $name: não encontrado ou vazio"
    return 1
  fi
}

echo "[1] Verificando arquivos extraídos..."
validate_file "$EXTRACT_DIR/helm-history.txt" "Helm History"
validate_file "$EXTRACT_DIR/helm-manifest.yaml" "Helm Manifest"
validate_file "$EXTRACT_DIR/secrets/argocd-secrets.yaml.raw" "Secrets" || true
validate_file "$EXTRACT_DIR/configmaps/argocd-configmaps.yaml" "ConfigMaps"
validate_file "$EXTRACT_DIR/projects/appprojects.yaml" "Projects" || true
validate_file "$EXTRACT_DIR/repositories/repositories.yaml" "Repositories" || true
validate_file "$EXTRACT_DIR/rbac/roles.yaml" "RBAC Roles" || true
echo

echo "[2] Verificando Argo CD em execução..."
POD_COUNT=$(kubectl get pods -n argocd --no-headers | wc -l)
READY_COUNT=$(kubectl get pods -n argocd -o jsonpath='{range .items[*]}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}' | grep -c True || true)
echo "✓ Pods em execução: $POD_COUNT, Ready: $READY_COUNT"
echo

echo "[3] Verificando Services..."
kubectl get svc -n argocd --no-headers
echo

echo "[4] Verificando Applications Argo CD..."
kubectl get applications -n argocd --no-headers || echo "⚠️  Nenhuma application no namespace argocd"
echo

echo "[5] Verificando Projetos..."
kubectl get appprojects -n argocd --no-headers | wc -l | xargs echo "✓ Total de projetos:"
echo

echo "[6] Verificando Repositories..."
kubectl get repositories -n argocd --no-headers | wc -l | xargs echo "✓ Total de repositories:"
echo

echo "=== Validação Completa ==="
echo
echo "Se todos os itens acima estão OK, você pode prosseguir com:"
echo "  bash scripts/03-deploy-self-managed.sh"
