# Estrutura do Projeto - Cenário 2

```
cenario-2-migracao-manual-para-gitops/
│
├── README.md                              ⭐ COMECE AQUI
│   └── Visão geral, passo a passo rápido, estrutura
│
├── ESTRATEGIA.md                          📋 Entenda a estratégia
│   └── Problema atual, solução, matriz de risco, cronograma
│
├── .gitignore                             🔐 Proteção de secrets
│   └── Não permite secrets serem commitados
│
├── scripts/                               🔧 Automação
│   ├── 01-extract-argocd-state.sh         → Extrai config atual
│   ├── 02-validate-extraction.sh          → Valida extração
│   ├── 03-deploy-self-managed.sh          → Aplica self-management
│   └── 04-verify-migration.sh             → Verifica sucesso
│
├── extracted-config/                      📦 Saída dos scripts
│   ├── helm-history.txt                   → Histórico de upgrades
│   ├── helm-manifest.yaml                 → Manifest completo
│   ├── secrets/
│   │   └── argocd-secrets.yaml.raw        ⚠️  SENSÍVEL! Não commitar
│   ├── configmaps/
│   │   └── argocd-configmaps.yaml         → ConfigMaps atuais
│   ├── projects/
│   │   └── appprojects.yaml               → Projects Argo CD
│   ├── repositories/
│   │   └── repositories.yaml              → Repositories cadastrados
│   └── rbac/
│       ├── roles.yaml                     → Roles customizados
│       └── rolebindings.yaml              → RoleBindings
│
├── helm-values/                           ⚙️  Configuração Helm
│   ├── base-values.yaml                   → Template base
│   ├── custom-values.yaml                 → Suas customizações
│   └── merged-values.yaml                 → Resultado final (gerado)
│
├── applications/                          🚀 Aplicações
│   ├── argocd-self-managed.yaml           → App que gerencia Argo CD
│   └── sample-app-managed.yaml            → App de teste
│
└── checklists/                            ✅ Validações
    ├── PRE-MIGRATION.md                   → Antes de migrar
    └── POST-MIGRATION.md                  → Depois de migrar
```

## Fluxo de Execução

```
1️⃣  Ler README.md
         ↓
2️⃣  Revisar ESTRATEGIA.md
         ↓
3️⃣  Completar PRE-MIGRATION.md checklist
         ↓
4️⃣  Executar scripts em ordem:
    a) scripts/01-extract-argocd-state.sh
    b) scripts/02-validate-extraction.sh
    c) scripts/03-deploy-self-managed.sh
    d) scripts/04-verify-migration.sh
         ↓
5️⃣  Completar POST-MIGRATION.md checklist
         ↓
6️⃣  Commitar no Git:
    git add cenario-2-migracao-manual-para-gitops/
    git commit -m "Migrate Argo CD to GitOps self-managed"
    git push
         ↓
7️⃣  Monitorar por 1-2 semanas
         ↓
8️⃣  Feedback e ajustes finos
```

## Arquivos Importantes

| Arquivo | Propósito | Editar? |
|---------|-----------|---------|
| README.md | Documentação principal | Não (ou apenas notas) |
| ESTRATEGIA.md | Entendimento técnico | Não |
| helm-values/custom-values.yaml | Suas customizações | **SIM** |
| applications/argocd-self-managed.yaml | Application do Argo CD | **SIM** (versão, valores) |
| extracted-config/* | Dados extraídos | Auto (scripts) |

## Setor de Segurança 🔐

**NÃO FAÇA:**
- ❌ Commitar `extracted-config/secrets/`
- ❌ Deixar credentials em plain text
- ❌ Publicar repo em GitHub público
- ❌ Ignorar .gitignore

**FAÇA:**
- ✅ Usar repositório **privado** no GitHub/GitLab
- ✅ Criptografar secrets com `sealed-secrets` ou `external-secrets`
- ✅ Revisar .gitignore antes de commitar
- ✅ Usar Vault ou AWS Secrets Manager para production

## Troubleshooting Rápido

### Scripts não têm permissão
```bash
chmod +x scripts/*.sh
```

### Erro: "kubectl not found"
```bash
# Instale kubectl ou use container
docker run -it -v ~/.kube:/root/.kube kubectl/kubectl bash
```

### Application fica em "Unknown"
```bash
# Verificar erro
kubectl describe app argocd -n argocd

# Ver logs do controller
kubectl logs -n argocd statefulset/argocd-application-controller
```

### Secrets vazaram por acidente
```bash
# Rodar git secret scan
git secrets --scan

# Remover do histórico (se necessário)
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch extracted-config/secrets/*' \
  --prune-empty --tag-name-filter cat -- --all
```

## Suporte e Dúvidas

Revisar em ordem:
1. README.md seção "Passo a Passo Rápido"
2. ESTRATEGIA.md seção "Matriz de Risco"
3. Logs do Argo CD: `kubectl logs -n argocd -l app.kubernetes.io/name=argocd`
4. Events: `kubectl get events -n argocd --sort-by='.lastTimestamp'`

---

**Versão**: 1.0  
**Última atualização**: 19 de maio de 2026  
**Mantido por**: Equipe Argo CD
