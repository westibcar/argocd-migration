#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
EXTRACT_DIR="${REPO_ROOT}/cenario-2-migracao-manual-para-gitops/extracted-config"
HELM_VALUES_DIR="${REPO_ROOT}/cenario-2-migracao-manual-para-gitops/helm-values"

mkdir -p "$EXTRACT_DIR" "$HELM_VALUES_DIR"

echo "=== Extração do Estado Atual do Argo CD ==="
echo

# Checklist de verificação
echo "[1/8] Verificando se Argo CD está em execução..."
if ! kubectl get namespace argocd >/dev/null 2>&1; then
  echo "❌ Namespace 'argocd' não encontrado"
  exit 1
fi
echo "✓ Namespace argocd encontrado"
echo

# Extrair Helm values
echo "[2/8] Extraindo valores do Helm release..."
helm get values argocd -n argocd > "$HELM_VALUES_DIR/base-values.yaml"
echo "✓ Salvos em: $HELM_VALUES_DIR/base-values.yaml"
echo

# Extrair secrets (com warning de segurança)
echo "[3/8] Extraindo secrets (CUIDADO: dados sensíveis!)..."
mkdir -p "$EXTRACT_DIR/secrets"
kubectl get secrets -n argocd -o yaml > "$EXTRACT_DIR/secrets/argocd-secrets.yaml.raw" 2>/dev/null || true
if [ -f "$EXTRACT_DIR/secrets/argocd-secrets.yaml.raw" ]; then
  echo "⚠️  Secrets extraídos para: $EXTRACT_DIR/secrets/argocd-secrets.yaml.raw"
  echo "⚠️  IMPORTANTE: Este arquivo contém dados sensíveis! Não commitar em Git público."
else
  echo "⚠️  Nenhum secret encontrado (ou sem permissão)"
fi
echo

# Extrair ConfigMaps
echo "[4/8] Extraindo ConfigMaps..."
mkdir -p "$EXTRACT_DIR/configmaps"
kubectl get configmaps -n argocd -o yaml > "$EXTRACT_DIR/configmaps/argocd-configmaps.yaml" 2>/dev/null || true
echo "✓ Salvos em: $EXTRACT_DIR/configmaps/argocd-configmaps.yaml"
echo

# Extrair Projetos Argo CD
echo "[5/8] Extraindo Argo CD Projects..."
mkdir -p "$EXTRACT_DIR/projects"
kubectl get appprojects -n argocd -o yaml > "$EXTRACT_DIR/projects/appprojects.yaml" 2>/dev/null || true
echo "✓ Salvos em: $EXTRACT_DIR/projects/appprojects.yaml"
echo

# Extrair Repositories
echo "[6/8] Extraindo Argo CD Repositories..."
mkdir -p "$EXTRACT_DIR/repositories"
kubectl get repositories -n argocd -o yaml > "$EXTRACT_DIR/repositories/repositories.yaml" 2>/dev/null || true
echo "✓ Salvos em: $EXTRACT_DIR/repositories/repositories.yaml"
echo

# Extrair RBAC
echo "[7/8] Extraindo RBAC (Roles, RoleBindings)..."
mkdir -p "$EXTRACT_DIR/rbac"
kubectl get roles -n argocd -o yaml > "$EXTRACT_DIR/rbac/roles.yaml" 2>/dev/null || true
kubectl get rolebindings -n argocd -o yaml > "$EXTRACT_DIR/rbac/rolebindings.yaml" 2>/dev/null || true
echo "✓ Salvos em: $EXTRACT_DIR/rbac/"
echo

# Extrair Helm history
echo "[8/8] Extraindo histórico do Helm..."
helm history argocd -n argocd > "$EXTRACT_DIR/helm-history.txt" 2>/dev/null || true
helm get manifest argocd -n argocd > "$EXTRACT_DIR/helm-manifest.yaml" 2>/dev/null || true
echo "✓ Salvos em: $EXTRACT_DIR/"
echo

echo "=== Extração Completa ==="
echo
echo "📁 Arquivos extraídos em: $EXTRACT_DIR"
echo
echo "Próximos passos:"
echo "1. Revisar os arquivos extraídos"
echo "2. Executar: bash scripts/02-validate-extraction.sh"
echo "3. Executar: bash scripts/03-deploy-self-managed.sh"
