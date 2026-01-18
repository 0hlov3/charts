# Yopass Chart

A Helm chart to deploy **[Yopass](https://github.com/jhaals/yopass)** on Kubernetes.

Yopass is a minimal, open-source secret sharing service for one-time or time-limited secrets.  
This chart deploys the Yopass server with an in-pod **Memcached** sidecar for storage.

## Features

 - Yopass server with configurable flags (address, max secret length, UI feature toggles)
 - Built-in Memcached sidecar (ephemeral by design)
 - Configurable Service (ClusterIP by default)
 - Optional Ingress with TLS
 - Helm test hook to validate connectivity

## Requirements
 - Kubernetes 1.19+ (Ingress templates handle older APIs too)
 - Helm 3.9+
 - (Optional) An Ingress controller (e.g., NGINX) and cert-manager for TLS

## Notes & Caveats

 - Ephemeral storage: The chart hard-codes --database=memcached and runs a Memcached sidecar. If the Pod restarts, in-memory secrets are lost. This matches Yopass’ ephemeral design.
 - Replica caveat: replicaCount must remain 1 unless you wire external/shared storage; each pod has its own in-pod Memcached and the Service load-balances requests (no shared cache, no session affinity).
 - Sidecar image: Pin Memcached using `memcached.image.tag` to avoid drifting image versions.
 - Security context: Sensible defaults are provided but commented out—enable runAsNonRoot, readOnlyRootFilesystem, and drop capabilities as needed.
 - Resource limits: Not set by default; set resources.requests/limits to ensure stable scheduling and performance.

## Parameters

### Deployment

| Name           | Description                             | Value |
| -------------- | --------------------------------------- | ----- |
| `replicaCount` | Number of Yopass server replicas to run | `1`   |

### Container image

| Name               | Description                                       | Value           |
| ------------------ | ------------------------------------------------- | --------------- |
| `image`            | Container image configuration                     |                 |
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

| Name                 | Description                                                                           | Value |
| -------------------- | ------------------------------------------------------------------------------------- | ----- |
| `podAnnotations`     | Annotations to add to the Pod metadata                                                | `{}`  |
| `podSecurityContext` | Pod-level security context (e.g., fsGroup)                                            | `{}`  |
| `securityContext`    | Container-level security context (capabilities, runAs*, readOnlyRootFilesystem, etc.) | `{}`  |

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

| Name                         | Description                                       | Value          |
| ---------------------------- | ------------------------------------------------- | -------------- |
| `memcached`                  | Memcached sidecar configuration                   |                |
| `memcached.image`            | Memcached image configuration                     |                |
| `memcached.image.registry`   | Memcached image registry                          | `docker.io`    |
| `memcached.image.repository` | Memcached image repository                        | `memcached`    |
| `memcached.image.tag`        | Memcached image tag                               | `""`           |
| `memcached.image.pullPolicy` | Memcached image pull policy                       | `IfNotPresent` |
| `memcached.resources`        | CPU/Memory resource requests/limits for Memcached | `{}`           |

## Contributing
Issues and PRs welcome! Please bump the chart version in Chart.yaml when changing templates or values, and keep this README’s Parameters in sync using the [Bitnami generator](https://github.com/bitnami/readme-generator-for-helm).
```shell
podman run -v $(pwd):/chart 0hlov3/readme-generator-for-helm readme-generator --readme=/chart/README.md --values=/chart/values.yaml
```
