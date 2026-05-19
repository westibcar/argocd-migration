#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Verificação Final da Migração ==="
echo

echo "[1] Status da Application argocd..."
kubectl get app argocd -n argocd -o wide
echo

echo "[2] Pods do Argo CD..."
kubectl get pods -n argocd
echo

echo "[3] Services do Argo CD..."
kubectl get svc -n argocd
echo

echo "[4] Helm release..."
helm list -n argocd
echo

echo "[5] Últimos eventos..."
kubectl get events -n argocd --sort-by='.lastTimestamp' | tail -n 10
echo

echo "[6] Logs do Application Controller..."
kubectl logs -n argocd statefulset/argocd-application-controller --tail=30 | tail -n 10
echo

echo "=== Verificação Completa ==="
echo
echo "Se tudo está verde acima, a migração foi bem-sucedida!"
echo
echo "Para acessar a UI:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:80"
echo "  # Abrir http://localhost:8080"
