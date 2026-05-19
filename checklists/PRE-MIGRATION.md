# Checklist Pré-Migração

Antes de executar a migração, valide todos os itens abaixo:

## Infraestrutura e Backups

- [ ] Cluster Kubernetes está saudável
  ```bash
  kubectl get nodes
  kubectl get all -n argocd
  ```

- [ ] Backup do namespace argocd foi feito
  ```bash
  kubectl get all -n argocd -o yaml > /backup/argocd-backup-$(date +%Y%m%d-%H%M%S).yaml
  ```

- [ ] Backup do PVC (se houver)
  ```bash
  kubectl get pvc -n argocd
  ```

- [ ] Helm release atual foi documentado
  ```bash
  helm get values argocd -n argocd > /backup/argocd-values-$(date +%Y%m%d-%H%M%S).yaml
  helm get manifest argocd -n argocd > /backup/argocd-manifest-$(date +%Y%m%d-%H%M%S).yaml
  ```

## Estado do Argo CD

- [ ] Todos os pods do Argo CD estão em Running
  ```bash
  kubectl get pods -n argocd
  ```

- [ ] Nenhuma app está em erro ou fora de sync
  ```bash
  kubectl get applications -n argocd
  ```

- [ ] Credentials de repositórios estão configuradas
  ```bash
  kubectl get secret -n argocd
  ```

- [ ] RBAC está funcionando (usuários conseguem fazer login)

## Documentação e Planejamento

- [ ] Lista de customizações documentada
  ```
  - Ingress? Sim/Não
  - SSO configurado? Sim/Não
  - Notification habilitada? Sim/Não
  - Projetos customizados? Quantos?
  - Repositories customizados? Quantos?
  ```

- [ ] Matriz de risco revisada (ver ESTRATEGIA.md)

- [ ] Cronograma comunicado ao time

- [ ] Janela de manutenção agendada (se Opção B)

## Validação Técnica

- [ ] Helm chart 5.31.0 está disponível
  ```bash
  helm search repo argo/argo-cd --version 5.31.0
  ```

- [ ] Git repository para versionamento pronto
  ```bash
  git status
  ```

- [ ] Permissões de kubectl validadas
  ```bash
  kubectl auth can-i get applications -n argocd
  kubectl auth can-i create applications -n argocd
  ```

## Comunicação

- [ ] Time foi comunicado sobre a migração
- [ ] Janela de manutenção foi divulgada
- [ ] Plano de rollback foi explicado
- [ ] Contato de escalation definido

## Validações Finais

- [ ] Todos os itens acima estão marcados ✓
- [ ] Ninguém tem objeções ou dúvidas
- [ ] Você está pronto para começar

---

Se todos os itens estão OK, você pode prosseguir com a migração:

```bash
bash scripts/01-extract-argocd-state.sh
bash scripts/02-validate-extraction.sh
bash scripts/03-deploy-self-managed.sh
bash scripts/04-verify-migration.sh
```
