# Guia de Instalação Correta do Argo CD 2.7.0

Este documento descreve como instalar o Argo CD corretamente **ANTES** de usar este projeto de migração para GitOps.

## ⚠️ Erros Comuns que Causam Falhas

### ❌ ERRO 1: Usar `--skip-crds`

```bash
# NÃO FAÇA ISSO:
helm install argocd argo/argo-cd \
  --namespace argocd \
  --version 2.7.0 \
  --skip-crds  # ← ERRO FATAL!
```

**Resultado**: 
- Pod `argocd-server` em `CrashLoopBackOff`
- Erro: `"the server could not find the requested resource (post appprojects.argoproj.io)"`
- Application controller não consegue criar projetos

### ❌ ERRO 2: Não instalar CRDs

Se CRDs não forem instaladas ANTES de instalar Argo CD, o Helm chart não consegue criar os recursos Argo CD.

## ✅ Instalação CORRETA (Passo a Passo)

### Pré-requisitos

```bash
# Verificar K8s está rodando
kubectl cluster-info

# Adicionar repo Helm do Argo
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

### Passo 1: Instalar CRDs

**IMPORTANTE**: Instale CRDs ANTES de instalar o chart Helm!

```bash
# Opção A: via Kustomize (recomendado)
kubectl apply -k https://github.com/argoproj/argo-cd/manifests/crds?ref=v2.7.0

# Opção B: via manifesto direto
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.7.0/manifests/crds-cluster-scoped.yaml
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.7.0/manifests/crds-namespaced.yaml

# Esperar um pouco para CRDs serem registradas
sleep 10
```

**Verificar sucesso:**
```bash
kubectl get crd | grep argoproj
# Esperado:
# applicationsets.argoproj.io
# applications.argoproj.io
# appprojects.argoproj.io
```

### Passo 2: Criar Namespace

```bash
kubectl create namespace argocd
```

### Passo 3: Instalar Argo CD via Helm

```bash
helm install argocd argo/argo-cd \
  --namespace argocd \
  --version 2.7.0 \
  --timeout 5m
  # NÃO use --skip-crds!
```

**Opcionalmente**, se não precisa de SSO, desabilite Dex:
```bash
helm install argocd argo/argo-cd \
  --namespace argocd \
  --version 2.7.0 \
  --set dex.enabled=false
```

### Passo 4: Esperar Pods Ficarem Ready

```bash
# Aguardar todos os pods Running (2-3 minutos)
kubectl get pods -n argocd -w

# Quando terminar, deve ver (ou similar):
# argocd-application-controller-0     1/1  Running
# argocd-server-xxx                   1/1  Running
# argocd-repo-server-xxx              1/1  Running
# argocd-redis-xxx                    1/1  Running
# etc
```

**Ctrl+C para sair do watch**

### Passo 5: Verificar Instalação

```bash
# Todos os pods em Running?
kubectl get pods -n argocd

# Helm release está OK?
helm status argocd -n argocd

# Argo CD UI acessível?
kubectl port-forward svc/argocd-server -n argocd 8080:80
# Abrir http://localhost:8080
```

## Checklist de Validação

- [ ] `kubectl get crd | grep argoproj` mostra 3 CRDs (applications, applicationsets, appprojects)
- [ ] `kubectl get pods -n argocd` mostra todos os pods em `Running`
- [ ] Nenhum pod em `CrashLoopBackOff` ou `ImagePullBackOff`
- [ ] `helm list -n argocd` mostra release `argocd` como `deployed`
- [ ] UI do Argo CD abre em `http://localhost:8080` (após port-forward)

Se tudo passou ✅, você está pronto para:
```bash
bash scripts/01-extract-argocd-state.sh
```

## Troubleshooting

### Problema: Pod em CrashLoopBackOff

```bash
# Ver logs do pod
kubectl logs -n argocd <pod-name> --tail=100

# Se falha de CRD, instale manualmente as CRDs
kubectl apply -k https://github.com/argoproj/argo-cd/manifests/crds?ref=v2.7.0
```

### Problema: ImagePullBackOff

Geralmente é `argocd-dex-server` (componente opcional para SSO).

**Solução**: Desabilitar Dex na reinstalação:
```bash
helm uninstall argocd -n argocd
helm install argocd argo/argo-cd \
  --namespace argocd \
  --version 2.7.0 \
  --set dex.enabled=false
```

### Problema: "apiVersion v1beta1 not supported"

Isso pode ocorrer em K8s 1.25+. Solução:

```bash
helm template argocd argo/argo-cd \
  --version 2.7.0 \
  --namespace argocd \
  | kubectl apply -f -
```

## Próximos Passos

Quando a instalação estiver ✅:

```bash
cd argocd-migration

# 1. Extrair estado atual
bash scripts/01-extract-argocd-state.sh

# 2. Validar extração
bash scripts/02-validate-extraction.sh

# 3. Migrar para self-managed
bash scripts/03-deploy-self-managed.sh

# 4. Verificar migração
bash scripts/04-verify-migration.sh
```

Ver [README.md](README.md) para detalhes do processo.
