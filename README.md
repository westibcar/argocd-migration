# Cenário 2: Migração de Argo CD Manual para GitOps Self-Managed

## Visão Geral

Sua empresa tem um Argo CD instalado manualmente com Helm e várias customizações aplicadas diretamente no cluster (manual port-forward, projects customizados, repo credentials, RBAC, etc).

**Objetivo**: Capturar todo o estado atual, versioná-lo e colocar o Argo CD em modo self-managed via GitOps.

## Benefícios

- **Versionamento**: Todo o estado do Argo CD fica em Git.
- **Auditoria**: Quem mudou o quê e quando.
- **Disaster Recovery**: Recuperar o Argo CD rapidamente se falhar.
- **Upgrades Controlados**: Atualizar versão sem perder customizações.
- **Documentação Viva**: O Git é a fonte da verdade.

## Arquivos Neste Cenário

```
cenario-2-migracao-manual-para-gitops/
├── README.md                              (este arquivo)
├── ESTRATEGIA.md                          (estratégia detalhada)
├── scripts/
│   ├── 01-extract-argocd-state.sh         (extrai config do Argo CD atual)
│   ├── 02-validate-extraction.sh          (valida dados extraídos)
│   ├── 03-deploy-self-managed.sh          (cria Application self-managed)
│   └── 04-verify-migration.sh             (valida migração)
├── extracted-config/                      (saída do script de extração)
│   └── .gitkeep
├── helm-values/
│   ├── base-values.yaml                   (valores base do Argo CD)
│   ├── custom-values.yaml                 (customizações da empresa)
│   └── merged-values.yaml                 (resultado final, gerado automaticamente)
├── applications/
│   ├── argocd-self-managed.yaml           (Application que gerencia Argo CD)
│   └── sample-app-managed.yaml            (app de teste gerenciada)
└── checklists/
    ├── PRE-MIGRATION.md                   (verificações antes de migrar)
    └── POST-MIGRATION.md                  (validações após migração)
```

## Passo a Passo Rápido

### Fase 1: Capturar Estado Atual

1. **Extrair configurações**:
   ```bash
   bash scripts/01-extract-argocd-state.sh
   ```
   Isso gera:
   - Helm values atuais
   - RBAC roles/rolebindings
   - Secrets (encrypted)
   - ConfigMaps
   - Projetos Argo CD
   - Repositories configuradas

2. **Validar extração**:
   ```bash
   bash scripts/02-validate-extraction.sh
   ```

### Fase 2: Migrar para Self-Managed

3. **Revisar valores customizados**:
   ```bash
   cat helm-values/custom-values.yaml
   ```
   Ajuste conforme necessário.

4. **Criar Application de self-management**:
   ```bash
   bash scripts/03-deploy-self-managed.sh
   ```
   Isso cria a Application `argocd` que gerencia a si mesma.

5. **Validar migração**:
   ```bash
   bash scripts/04-verify-migration.sh
   ```

### Fase 3: Versionamento

6. **Commitar tudo no Git**:
   ```bash
   git add cenario-2-migracao-manual-para-gitops/
   git commit -m "Migrate Argo CD to self-managed GitOps"
   ```

## Fluxo de Alterações Após Migração

Qualquer mudança no Argo CD deve seguir este fluxo:

1. Editar `helm-values/custom-values.yaml` ou `applications/argocd-self-managed.yaml`
2. Commitar no Git
3. Application do Argo CD sincroniza automaticamente
4. Mudança refletida no cluster

**Nunca mais fazer mudanças manuais** no Argo CD via UI ou kubectl.

## Segurança: Secrets e Credentials

Os scripts extraem:
- Repo credentials (GitHub tokens, SSH keys)
- TLS certificates
- SSO config (se houver)

**IMPORTANTE**: Esses dados sensíveis NÃO devem ir para Git público!

Recomendações:
- Usar um repositório privado no GitHub/GitLab
- Criptografar secrets com `sealed-secrets` ou `external-secrets`
- Revisar o arquivo `.gitignore` antes de commitar
- Usar uma ferramenta de secrets management (Vault, AWS Secrets Manager)

## Rollback Rápido

Se algo der errado:

1. **Voltar para a versão anterior do Helm**:
   ```bash
   helm rollback argocd -n argocd
   ```

2. **Cancelar a Application**:
   ```bash
   kubectl delete app argocd -n argocd
   ```

## Próximos Passos

Depois que self-managed estiver estável:

- Fazer upgrades de versão via Git (sem downtime)
- Adicionar múltiplos clusters como destinations
- Integrar CI/CD para promover aplicações automaticamente
- Implementar controle de acesso (RBAC) via GitOps

## Suporte

Se algo quebrar:
- Verificar logs: `kubectl logs -n argocd deploy/argocd-application-controller`
- Revisar eventos: `kubectl get events -n argocd --sort-by='.lastTimestamp'`
- Rollback de imediato se necessário
# argocd-migration
