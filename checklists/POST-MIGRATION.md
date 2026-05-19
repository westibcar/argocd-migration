# Checklist Pós-Migração

Após a migração, valide todos os itens para garantir sucesso:

## Aplicações e Pods

- [ ] Application `argocd` está Synced
  ```bash
  kubectl get app argocd -n argocd
  # Esperado: Synced e Healthy
  ```

- [ ] Todos os pods do Argo CD estão em Running
  ```bash
  kubectl get pods -n argocd
  ```

- [ ] Nenhum pod está em CrashLoopBackOff ou Error

- [ ] Health checks estão passando
  ```bash
  kubectl logs -n argocd deploy/argocd-server | grep -i health
  ```

## Funcionalidade Argo CD

- [ ] UI do Argo CD está acessível
  ```bash
  kubectl port-forward svc/argocd-server -n argocd 8080:80
  # Abrir: http://localhost:8080
  ```

- [ ] Login está funcionando (admin ou OAuth)

- [ ] Projetos aparecem na UI
  ```bash
  kubectl get appprojects -n argocd
  ```

- [ ] Repositories estão sincronizando
  ```bash
  kubectl get repositories -n argocd
  ```

- [ ] Nenhum erro de conexão aos repositórios

## Aplicações Gerenciadas

- [ ] Todas as apps que eram sincronizadas continuam sincronizadas
  ```bash
  kubectl get applications -A
  ```

- [ ] Sample-app está saudável (se foi criada)
  ```bash
  kubectl get app sample-app -n argocd
  ```

- [ ] Pods de aplicações estão rodando nos namespaces corretos

## RBAC e Segurança

- [ ] RBAC continua funcionando
  ```bash
  kubectl get roles -n argocd
  kubectl get rolebindings -n argocd
  ```

- [ ] Apenas usuários autorizados conseguem fazer login

- [ ] Secrets não foram vazados (revisar logs)

- [ ] Não há warnings de segurança nos pods

## Performance

- [ ] Argo CD está respondendo rápido
  - UI carrega em < 5 segundos
  - Sync não demora mais do que antes

- [ ] CPU/Memória dentro dos limites
  ```bash
  kubectl top pods -n argocd
  ```

- [ ] Nenhum OOMKilled ou CPU throttling

## Versionamento e Governança

- [ ] Arquivos foram commitados no Git
  ```bash
  git log --oneline cenario-2-migracao-manual-para-gitops/
  ```

- [ ] Mudança futuras devem ir via Git (não via kubectl)

- [ ] Equipe foi treinada no novo fluxo

- [ ] Documentação foi atualizada

## Plano de Rollback (Testes)

- [ ] Testou fazer rollback (em ambiente de teste)
  ```bash
  kubectl delete app argocd -n argocd
  helm rollback argocd -n argocd
  ```

- [ ] Rollback funcionou sem problemas

- [ ] Todos ficaram tranquilos com o plano de recover

## Validações Finais

- [ ] Nenhum erro nos logs
  ```bash
  kubectl logs -n argocd --all-containers=true -f --max-log-requests=5 | grep -i error
  ```

- [ ] Eventos não mostram problemas
  ```bash
  kubectl get events -n argocd --sort-by='.lastTimestamp' | tail -n 20
  ```

- [ ] Tudo está verde e funcionando

---

## Sign-Off

- [ ] Implantação foi validada com sucesso
- [ ] Todos os testes passaram
- [ ] Equipe está confortável com a nova setup
- [ ] Documentação foi atualizada

**Data da Migração**: _______________

**Responsável**: _______________

**Aprovado por**: _______________

---

## Próximos Passos

1. Monitorar por 1-2 semanas em produção
2. Coletar feedback da equipe
3. Fazer ajustes finos conforme necessário
4. Documentar lições aprendidas
5. Planejar próxima fase (upgrades, novos clusters, etc)
