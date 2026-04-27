# Uptime Kuma Helm Chart

Deploy [Uptime Kuma](https://github.com/louislam/uptime-kuma)—a self-hosted monitoring tool—on Kubernetes.

- **Chart name:** `uptime-kuma`
- **Chart type:** Application
- **Chart version:** 1.0.0
- **App version:** `2.0.0`
- **Upstream image:** `docker.io/louislam/uptime-kuma`

This chart creates a `Deployment`, `Service`, optional `Ingress`(es), and an optional `PersistentVolumeClaim` for data.

## Upgrade note (0.3.0 -> 1.0.0)
When upgrading from v1 to v2, the data migration can take time and the app may not respond during the process. To avoid restarts mid-migration, temporarily disable probes:
```yaml
livenessProbe:
  enabled: false
readinessProbe:
  enabled: false
```
Re-enable them after the migration completes.

## Requirements
 - Kubernetes 1.19+ (Ingress v1 is used when available; older gates handled in templates)
 - Helm 3.8+
 - A default StorageClass (only if persistence.enabled=true)

## Parameters

### Image parameters

| Name               | Description                                       | Value |
| ------------------ | ------------------------------------------------- | ----- |
| `image.registry`   | Image registry                                    | `""`  |
| `image.repository` | Image repository                                  | `""`  |
| `image.tag`        | Image tag (defaults to chart appVersion if empty) | `""`  |
| `image.pullPolicy` | Image pull policy                                 | `""`  |

### Persistence parameters

| Name                  | Description                                       | Value   |
| --------------------- | ------------------------------------------------- | ------- |
| `persistence.enabled` | Enable PersistentVolumeClaim for Uptime Kuma data | `false` |
| `persistence.size`    | PVC size for data persistence                     | `""`    |

### Service account parameters

| Name                         | Description                                                                 | Value  |
| ---------------------------- | --------------------------------------------------------------------------- | ------ |
| `serviceAccount.create`      | Enable creation of a ServiceAccount                                         | `true` |
| `serviceAccount.annotations` | Annotations to add to the ServiceAccount                                    | `{}`   |
| `serviceAccount.name`        | Name of the ServiceAccount to use (auto-generated if empty and create=true) | `""`   |

### Deployment & Pod parameters

| Name                 | Description                                                               | Value |
| -------------------- | ------------------------------------------------------------------------- | ----- |
| `replicaCount`       | Number of replicas for the Uptime Kuma Deployment                         | `1`   |
| `podAnnotations`     | Additional annotations to add to the Pod                                  | `{}`  |
| `podSecurityContext` | Pod-level security context (e.g. fsGroup)                                 | `{}`  |
| `securityContext`    | Container-level security context (e.g. runAsUser, readOnlyRootFilesystem) | `{}`  |

### Probes parameters

| Name                                | Description                        | Value  |
| ----------------------------------- | ---------------------------------- | ------ |
| `livenessProbe.enabled`             | Enable liveness probe              | `true` |
| `livenessProbe.path`                | HTTP path for liveness probe       | `""`   |
| `livenessProbe.initialDelaySeconds` | Delay before liveness probe starts | `0`    |
| `livenessProbe.periodSeconds`       | Liveness probe period              | `10`   |
| `livenessProbe.timeoutSeconds`      | Liveness probe timeout             | `1`    |
| `livenessProbe.failureThreshold`    | Liveness probe failure threshold   | `3`    |
| `livenessProbe.successThreshold`    | Liveness probe success threshold   | `1`    |

### Probes parameters

| Name                                 | Description                         | Value  |
| ------------------------------------ | ----------------------------------- | ------ |
| `readinessProbe.enabled`             | Enable readiness probe              | `true` |
| `readinessProbe.path`                | HTTP path for readiness probe       | `""`   |
| `readinessProbe.initialDelaySeconds` | Delay before readiness probe starts | `0`    |
| `readinessProbe.periodSeconds`       | Readiness probe period              | `10`   |
| `readinessProbe.timeoutSeconds`      | Readiness probe timeout             | `1`    |
| `readinessProbe.failureThreshold`    | Readiness probe failure threshold   | `3`    |
| `readinessProbe.successThreshold`    | Readiness probe success threshold   | `1`    |

### Service parameters

| Name           | Description                             | Value       |
| -------------- | --------------------------------------- | ----------- |
| `service.type` | Kubernetes Service type                 | `ClusterIP` |
| `service.port` | Service port for the Uptime Kuma web UI | `3001`      |

### Ingress parameters

| Name                  | Description                                                                       | Value   |
| --------------------- | --------------------------------------------------------------------------------- | ------- |
| `ingress.enabled`     | Enable Ingress for the main UI                                                    | `false` |
| `ingress.className`   | IngressClass name to use                                                          | `""`    |
| `ingress.annotations` | Extra annotations for the Ingress                                                 | `{}`    |
| `ingress.hosts`       | List of host rules for the UI (each item supports host and paths[].path/pathType) | `[]`    |
| `ingress.tls`         | TLS configuration for hosts (secretName, hosts[])                                 | `[]`    |

### Status Ingress parameters

| Name                        | Description                                                             | Value   |
| --------------------------- | ----------------------------------------------------------------------- | ------- |
| `ingressStatus.enabled`     | Enable a separate Ingress for a public read-only status page            | `false` |
| `ingressStatus.className`   | IngressClass name to use for the status page                            | `""`    |
| `ingressStatus.annotations` | Extra annotations for the status Ingress                                | `{}`    |
| `ingressStatus.hosts`       | List of host rules for the status page (paths should point to /status/) | `[]`    |
| `ingressStatus.tls`         | TLS configuration for status hosts (secretName, hosts[])                | `[]`    |

### Resources & scheduling

| Name           | Description                                | Value |
| -------------- | ------------------------------------------ | ----- |
| `resources`    | Resource requests/limits for the container | `{}`  |
| `nodeSelector` | Node selector rules for pod assignment     | `{}`  |
| `tolerations`  | Tolerations for pod assignment             | `[]`  |
| `affinity`     | Affinity rules for pod assignment          | `{}`  |

### Common parameters

| Name               | Description                                 | Value |
| ------------------ | ------------------------------------------- | ----- |
| `nameOverride`     | String to partially override the chart name | `""`  |
| `fullnameOverride` | String to fully override the release name   | `""`  |
| `imagePullSecrets` | Image pull secrets for private registries   | `[]`  |

## Contributing
Issues and PRs welcome! Please bump the chart version in Chart.yaml when changing templates or values, and keep this README’s Parameters in sync using the [Bitnami generator](https://github.com/bitnami/readme-generator-for-helm).
```shell
podman run -v $(pwd):/chart 0hlov3/readme-generator-for-helm readme-generator --readme=/chart/README.md --values=/chart/values.yaml
```
