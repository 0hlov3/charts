# Yopass Chart

A Helm chart to deploy **[Yopass](https://github.com/jhaals/yopass)** on Kubernetes.

Yopass is a minimal, open-source secret sharing service for one-time or time-limited secrets.  
This chart deploys the Yopass server with an in-pod **Memcached** sidecar for storage.

## Features

 - Yopass server with configurable flags (address, max secret length, UI feature toggles)
 - Built-in Memcached sidecar (ephemeral by design)
 - Configurable Service (ClusterIP by default)
 - Optional Ingress with TLS
 - Optional Prometheus metrics endpoint (`--metrics-port`)
 - `extraArgs` / `extraEnv` / `extraEnvFrom` escape hatches for upstream flags this chart doesn't model directly (license key, OIDC, webhooks, audit logging, TLS, `--trusted-proxies`, etc.)
 - Helm test hook to validate connectivity

## Upgrade note (1.0.2 -> 1.1.0)
`securityContext` and `podSecurityContext` changed from empty (`{}`) to hardened, non-root defaults (see [Pod annotations & security](#pod-annotations--security)). This is safe for the stock `jhaals/yopass` image with the chart's default in-database (Memcached) storage. If you run a custom/forked image with a different UID or as root, or enable a disk-writing feature such as `--file-store disk` via `extraArgs`, override the relevant key(s), e.g.:
```yaml
securityContext:
  runAsUser: null       # explicit null removes the key; an empty {} override does not,
  readOnlyRootFilesystem: false  # since Helm deep-merges map values against the chart defaults
```

## Requirements
 - Kubernetes 1.19+ (Ingress templates handle older APIs too)
 - Helm 3.9+
 - (Optional) An Ingress controller (e.g., NGINX) and cert-manager for TLS

## Notes & Caveats

 - Ephemeral storage: The chart hard-codes --database=memcached and runs a Memcached sidecar. If the Pod restarts, in-memory secrets are lost. This matches Yopass’ ephemeral design.
 - Replica caveat: replicaCount must remain 1 unless you wire external/shared storage; each pod has its own in-pod Memcached and the Service load-balances requests (no shared cache, no session affinity).
 - Redis backend: upstream Yopass also supports `--database redis` as an alternative to Memcached, but this chart only wires up Memcached today. Using Redis currently requires overriding `extraArgs`/`extraEnv` yourself and disabling the bundled sidecar is not supported; see the project's issue tracker/README if you need native Redis support added.
 - DynamoDB: not applicable here — the self-hosted `yopass-server` binary this chart deploys only supports `memcached` and `redis` as `--database` backends; DynamoDB is part of Yopass' separately-hosted offering, not something this chart can or should configure.
 - Sidecar image: Pin Memcached using `memcached.image.tag` to avoid drifting image versions.
 - Security context: `securityContext`/`podSecurityContext` default to a hardened, non-root, read-only-root-filesystem profile that matches the upstream image (`USER 1000` on a distroless base). This is safe with the chart's default in-database storage; if you enable a feature that writes to disk (e.g. `--file-store disk` via `extraArgs`), also relax `securityContext.readOnlyRootFilesystem`.
 - License-gated features: OIDC, audit logging, webhooks, secret requests, read receipts, and theming all require an upstream `--license-key` and are not modeled as first-class values. Use `extraArgs`/`extraEnv`/`extraEnvFrom` (e.g. to inject the license key from a Secret) to enable them.
 - Resource limits: The Yopass container (`resources`) has no defaults; the Memcached sidecar (`memcached.resources`) ships with default requests/limits. Tune both for your environment.

## Parameters

### Deployment

| Name           | Description                             | Value |
| -------------- | --------------------------------------- | ----- |
| `replicaCount` | Number of Yopass server replicas to run | `1`   |

### Container image

| Name               | Description                                       | Value           |
| ------------------ | ------------------------------------------------- | --------------- |
| `image`            | Container image configuration                     |                 |
| `image.registry`   | Container image registry                          | `docker.io`     |
| `image.repository` | Container image repository for Yopass             | `jhaals/yopass` |
| `image.pullPolicy` | Image pull policy                                 | `IfNotPresent`  |
| `image.tag`        | Image tag (defaults to chart appVersion if empty) | `""`            |

### Yopass server settings

| Name                     | Description                                                           | Value     |
| ------------------------ | --------------------------------------------------------------------- | --------- |
| `yopass`                 | Yopass server flags (mapped to CLI flags)                             |           |
| `yopass.listenAddress`   | Bind address for the server (maps to --address)                       | `0.0.0.0` |
| `yopass.secretMaxLength` | Maximum allowed encrypted secret size in bytes (maps to --max-length) | `10000`   |

### Web UI & feature toggles

| Name                          | Description                                                                   | Value   |
| ----------------------------- | ----------------------------------------------------------------------------- | ------- |
| `config`                      | Frontend/runtime feature flags returned via /config                           |         |
| `config.disable_upload`       | Disable file upload endpoints and UI (maps to --disable-upload)               | `false` |
| `config.prefetch_secret`      | Enable prefetch/status check for one-time secrets (maps to --prefetch-secret) | `true`  |
| `config.disable_features`     | Hide the “features” section on the homepage (maps to --disable-features)      | `true`  |
| `config.no_language_switcher` | Hide the language switcher in the UI (maps to --no-language-switcher)         | `false` |

### Metrics

| Name              | Description                                                                                                                                              | Value   |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `metrics`         | Prometheus metrics server (maps to --metrics-port)                                                                                                       |         |
| `metrics.enabled` | Start Yopass's built-in Prometheus metrics listener (--metrics-port) on a dedicated container port and annotate the Pod for prometheus.io auto-discovery | `false` |
| `metrics.port`    | Port the metrics listener binds to; also used for the `prometheus.io/port` pod annotation                                                                | `9090`  |

### Advanced configuration

| Name           | Description                                                                                                                                                   | Value |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| `extraArgs`    | Extra CLI flags appended to yopass-server, for upstream options this chart doesn't model directly (license key, OIDC, webhooks, TLS, --trusted-proxies, etc.) | `[]`  |
| `extraEnv`     | Extra environment variables appended to the yopass container (Kubernetes EnvVar objects), e.g. to inject a license key from a Secret                          | `[]`  |
| `extraEnvFrom` | Extra envFrom sources appended to the yopass container (Kubernetes EnvFromSource objects), for bulk-loading env vars from a ConfigMap/Secret                  | `[]`  |

### Global image & naming

| Name               | Description                                         | Value |
| ------------------ | --------------------------------------------------- | ----- |
| `imagePullSecrets` | Names of imagePullSecrets to use for pulling images | `[]`  |
| `nameOverride`     | String to partially override chart name             | `""`  |
| `fullnameOverride` | String to fully override chart fullname             | `""`  |

### Service account

| Name                         | Description                                                            | Value  |
| ---------------------------- | ---------------------------------------------------------------------- | ------ |
| `serviceAccount`             | ServiceAccount options                                                 |        |
| `serviceAccount.create`      | Whether to create a ServiceAccount                                     | `true` |
| `serviceAccount.annotations` | Annotations to add to the ServiceAccount                               | `{}`   |
| `serviceAccount.name`        | Name of the ServiceAccount to use (generated if empty and create=true) | `""`   |

### Pod annotations & security

| Name                 | Description                                                                                                                                                                                                                                                                                | Value |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----- |
| `podAnnotations`     | Annotations to add to the Pod metadata                                                                                                                                                                                                                                                     | `{}`  |
| `podSecurityContext` | Pod-level security context. Defaults to a restricted seccomp profile only, so it doesn't force a UID onto the Memcached sidecar's own non-root user                                                                                                                                        | `{}`  |
| `securityContext`    | Container-level security context for the yopass container. Defaults to a hardened non-root profile (UID 1000, all capabilities dropped, read-only root filesystem) matching the upstream distroless image; relax readOnlyRootFilesystem if you enable a disk-writing feature via extraArgs | `{}`  |

### Service

| Name           | Description                      | Value       |
| -------------- | -------------------------------- | ----------- |
| `service`      | Kubernetes Service configuration |             |
| `service.type` | Service type                     | `ClusterIP` |
| `service.port` | Service port for the HTTP API/UI | `1337`      |

### Ingress

| Name                  | Description                                               | Value   |
| --------------------- | --------------------------------------------------------- | ------- |
| `ingress`             | Kubernetes Ingress configuration                          |         |
| `ingress.enabled`     | Enable Ingress resource                                   | `false` |
| `ingress.className`   | IngressClass to use (Kubernetes >=1.18)                   | `""`    |
| `ingress.annotations` | Annotations to add to the Ingress                         | `{}`    |
| `ingress.hosts`       | Ingress host definitions                                  | `[]`    |
| `ingress.tls`         | TLS configuration for the Ingress (secrets and hostnames) | `[]`    |

### Resources

| Name        | Description                                     | Value |
| ----------- | ----------------------------------------------- | ----- |
| `resources` | CPU/Memory resource requests/limits for the Pod | `{}`  |

### Scheduling

| Name           | Description                                          | Value |
| -------------- | ---------------------------------------------------- | ----- |
| `nodeSelector` | Node labels for Pod assignment                       | `{}`  |
| `tolerations`  | Tolerations for taints to schedule on matching nodes | `[]`  |
| `affinity`     | Affinity/anti-affinity rules for Pod scheduling      | `{}`  |

### Memcached

| Name                         | Description                                                                                         | Value           |
| ---------------------------- | --------------------------------------------------------------------------------------------------- | --------------- |
| `memcached`                  | Memcached sidecar configuration                                                                     |                 |
| `memcached.image`            | Memcached image configuration                                                                       |                 |
| `memcached.image.registry`   | Memcached image registry                                                                            | `docker.io`     |
| `memcached.image.repository` | Memcached image repository                                                                          | `memcached`     |
| `memcached.image.tag`        | Memcached image tag (must be set, no `latest`)                                                      | `1.6.45-alpine` |
| `memcached.image.pullPolicy` | Memcached image pull policy                                                                         | `IfNotPresent`  |
| `memcached.resources`        | CPU/Memory resource requests/limits for Memcached (default limits/requests: cpu=100m, memory=100Mi) | `{}`            |

## Contributing
Issues and PRs welcome! Please bump the chart version in Chart.yaml when changing templates or values, and keep this README’s Parameters in sync using the [Bitnami generator](https://github.com/bitnami/readme-generator-for-helm).
```shell
podman run -v $(pwd):/chart 0hlov3/readme-generator-for-helm readme-generator --readme=/chart/README.md --values=/chart/values.yaml
```
