---
name: argocd-helper
description: |
  This skill should be used when the user mentions ArgoCD, GitOps, application sync,
  argocd commands, or asks about Kubernetes deployment synchronization, sync policies,
  or declarative configuration management. Provides complete ArgoCD CLI guidance for
  GitOps deployments, application management, and troubleshooting.
version: 1.0.0
---

# ArgoCD Helper Agent

## What's New in ArgoCD 2.13+

- **ApplicationSets**: Templated application generation across clusters, repos, and environments
- **Multi-Source Applications**: Combine multiple repos/charts in a single Application
- **Server-Side Diff**: More accurate diff calculations with live cluster state
- **Progressive Rollouts**: ApplicationSet rollout strategies with canary deployments
- **Improved Notifications**: Native notifications controller with triggers and templates
- **Enhanced RBAC**: Fine-grained permissions with project-scoped roles
- **Config Management Plugins v2**: Sidecar-based plugins for custom tooling
- **Resource Tracking**: Improved annotation-based resource tracking

## Overview

Provides guidance for working with ArgoCD for GitOps-based Kubernetes deployments, application synchronization, and declarative configuration management.

## Auto-Approved Commands

Safe read-only commands that don't require confirmation:
- `argocd app list` - List applications
- `argocd app get` - Get application details
- `argocd app diff` - Show diff between git and cluster
- `argocd app history` - Show application history
- `argocd app manifests` - Show application manifests
- `argocd app resources` - List application resources
- `argocd proj list` - List projects
- `argocd proj get` - Get project details
- `argocd repo list` - List repositories
- `argocd cluster list` - List clusters
- `argocd context` - Show current context
- `argocd account get-user-info` - Show current user info
- `argocd version` - Show version information

## CLI Commands

### Installation

```bash
# macOS
brew install argocd

# Linux
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/
```

### Authentication

```bash
argocd login argocd.example.com
argocd login argocd.example.com --auth-token=$ARGOCD_AUTH_TOKEN
argocd login localhost:8080 --insecure
argocd context
```

### Common Operations

```bash
# List applications
argocd app list
argocd app list -o wide
argocd app list --selector environment=production

# Get application details
argocd app get my-app
argocd app get my-app --refresh
argocd app get my-app -o yaml

# Sync application
argocd app sync my-app
argocd app sync my-app --prune
argocd app sync my-app --resource Deployment:my-deployment
argocd app sync my-app --dry-run

# Rollback
argocd app history my-app
argocd app rollback my-app 5

# Diff
argocd app diff my-app
argocd app diff my-app --revision HEAD
```

## Application Management

### Creating Applications

**Via CLI**:
```bash
argocd app create my-app \
  --repo https://github.com/myorg/myrepo \
  --path manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --sync-policy automated \
  --auto-prune \
  --self-heal
```

**Via YAML**:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/myorg/myrepo
    targetRevision: HEAD
    path: manifests
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### Sync Policies

```bash
argocd app set my-app --sync-policy automated
argocd app set my-app --auto-prune
argocd app set my-app --self-heal
argocd app set my-app --sync-policy none
```

## Application Status

```bash
argocd app get my-app --show-operation
argocd app wait my-app --health
argocd app resources my-app
argocd app diff my-app
```

## Projects

```bash
argocd proj list
argocd proj create my-project \
  --description "My Project" \
  --src "https://github.com/myorg/*" \
  --dest "https://kubernetes.default.svc,*" \
  --allow-cluster-resource "*"
argocd proj add-destination my-project https://kubernetes.default.svc my-namespace
argocd proj add-source my-project https://github.com/myorg/myrepo
```

## Repository Management

```bash
argocd repo list
argocd repo add https://github.com/myorg/myrepo --username myuser --password mytoken
argocd repo add git@github.com:myorg/myrepo.git --ssh-private-key-path ~/.ssh/id_rsa
argocd repo rm https://github.com/myorg/myrepo
```

## Common Workflows

### Deploy New Application

```bash
argocd app create "$APP_NAME" \
  --repo "$REPO_URL" --path "$PATH" \
  --dest-namespace "$NAMESPACE" \
  --dest-server https://kubernetes.default.svc \
  --sync-policy automated --auto-prune --self-heal
argocd app wait "$APP_NAME" --health
argocd app get "$APP_NAME"
```

### Troubleshoot Sync Issues

```bash
argocd app get "$APP"
argocd app diff "$APP"
kubectl get events -n argocd --field-selector involvedObject.name="$APP"
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller --tail=50 | grep "$APP"
```

### Bulk Sync Applications

```bash
argocd app sync -l environment=production
```

## Advanced Features

### Sync Hooks

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migration
  annotations:
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  template:
    spec:
      containers:
      - name: migrate
        image: migrate:latest
        command: ["./migrate.sh"]
      restartPolicy: Never
```

Hook types: `PreSync`, `Sync`, `PostSync`, `SyncFail`, `Skip`

### Sync Waves

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "0"  # Lower waves sync first
```

### App of Apps Pattern

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: apps
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/myorg/gitops
    path: apps
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
```

### Resource Hooks

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-options: Prune=false       # Skip from prune
    argocd.argoproj.io/sync-options: Replace=true       # Force replacement
    argocd.argoproj.io/compare-options: IgnoreExtraneous
```

## Best Practices

- **Use Projects** to organize apps and enforce RBAC boundaries
- **Enable auto-sync** for stable environments; use manual sync for production gates
- **Test prune behavior** before enabling auto-prune
- **Use sync windows** for maintenance periods
- **Use PreSync hooks** for database migrations
- **Order resources** with sync waves (lower numbers sync first)
- **Define custom health checks** for CRDs

## When to Ask for Help

Ask the user for clarification when:
- ArgoCD server URL or credentials are not specified
- Application name or namespace is ambiguous
- Repository URL or path needs confirmation
- Sync strategy (auto vs manual) is unclear
- Destructive operations like prune need confirmation
- Multiple clusters/destinations are involved

## Additional Resources

Detailed reference docs are available in the `references/` directory:

- **`references/applicationsets.md`** - ApplicationSet generators (List, Cluster, Git Directory, Git Files, Matrix) and progressive rollout strategies for multi-cluster deployments
- **`references/multi-source-and-notifications.md`** - Multi-source application patterns (Helm + Git values, multiple charts, Kustomize with remote base) and notification configuration (Slack integration, triggers, subscriptions)
- **`references/troubleshooting.md`** - Complete debugging workflows, sync issues, out-of-sync diagnosis, resource health, repo/cluster connection problems, RBAC issues, common error messages, performance tuning, and recovery operations
