# Estratégia Detalhada de Migração

## O Problema Atual

Seu Argo CD foi instalado manualmente com Helm:

```bash
# ❌ Instalação com erro (NÃO FAZER ASSIM!)
helm install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --version 2.7.0 \
  --skip-crds  # ← ERRO: Remove isso! Causa falha na Application

# ✅ Instalação CORRETA
kubectl apply -k https://github.com/argoproj/argo-cd/manifests/crds?ref=v2.7.0
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --version 2.7.0
```

Depois, foram feitas customizações **diretas no cluster**:
- Mudanças RBAC
- Novos projetos criados via UI
- Repositories adicionados manualmente
- Configurações de notification, SSO, etc

**Resultado**: Nenhuma documentação, ninguém sabe o que foi customizado, upgrade é arriscado.

## Solução: GitOps Self-Managed

### Fase 1: Extração (Capturar Estado Atual)

**O que fazemos**:
1. Rodamos Helm `helm get values` para capturar o que foi instalado.
2. Fazemos kubectl `get` de cada recurso Argo CD (Projects, Repositories, RBAC, etc).
3. Consolidamos em arquivos YAML versionáveis.
4. Criptografamos secrets (opcionalmente).

**Resultado**: Diretório `extracted-config/` com tudo documentado.

### Fase 2: Validação

**Garantimos que**:
- Nenhuma configuração foi perdida.
- Todos os secrets foram capturados.
- Todos os projetos estão documentados.
- RBAC foi preservado.

### Fase 3: Migração Gradual

**Opção A (Mais Segura - Recomendada)**:
1. Manter Argo CD antigo rodando.
2. Criar Application nova de self-management apontando para os mesmos valores.
3. Validar por 1-2 semanas sem deletar recursos antigos.
4. Depois, limpar e consolidar.

**Opção B (Mais Rápida)**:
1. Deletar Application manual do Argo CD.
2. Aplicar nova Application de self-management.
3. Rollback rápido se necessário.

Recomendamos **Opção A** para produção.

### Fase 4: Governança Contínua

Após migração, qualquer mudança segue:

```
Mudança Local (YAML)
        ↓
        Git Commit/Push
        ↓
        Webhook Argo CD
        ↓
        Auto-Sync (se ativado) ou Manual Sync
        ↓
        Cluster Atualizado
```

**Audit Trail**: Git log mostra quem, o quê, quando.

## Matriz de Risco

| Item | Risco | Mitigation |
|------|-------|-----------|
| **Perda de Secrets** | Alto | Scripts extraem e criptografam; guardar backup seguro |
| **Downtime do Argo CD** | Médio | Self-healing ativado; Pod restart automático |
| **RBAC quebrado** | Médio | Validar RBAC antes e depois; ter acesso shell |
| **Projects perdidos** | Baixo | Projects estão no Git; recuperáveis |
| **Upgrade dá ruim** | Médio | Helm rollback em 1 comando |

## Cronograma Estimado

| Fase | Tempo | Notas |
|------|-------|-------|
| Extração | 15 min | Automatizado |
| Validação | 30 min | Manual review |
| Migração (Opção A) | 1-2 semanas | Validação contínua |
| Migração (Opção B) | 30 min | Mais risco |
| Governança | Contínuo | Mudanças via Git |

## Checklist de Pré-Migração

- [ ] Backup completo do namespace argocd
- [ ] Backup do PVC de dados (se houver)
- [ ] Documentar versão atual do Argo CD
- [ ] Listar todos os projetos e repositories
- [ ] Testar rollback em homologação
- [ ] Ter plano de comunicação com time
- [ ] Agendar janela de manutenção (ou escolher Opção A)

## Checklist de Pós-Migração

- [ ] Application self-managed está Synced e Healthy
- [ ] Todos os projetos aparecem no Argo CD
- [ ] Todos os repositories foram sincronizados
- [ ] RBAC continua funcionando
- [ ] Webhooks estão recebendo eventos
- [ ] Notifications foram restauradas
- [ ] Deletar helmrelease antigo (se não for mais usar)

## Versioning e Tags

Recomendamos usar tags no Git para marcar milestones:

```bash
git tag -a v1.0-migrated-to-gitops -m "Argo CD migrated to self-managed"
git tag -a v1.0.1-stable -m "Stable after 1 week validation"
```

Isso facilita rastrear qual versão foi usada em qual período.
