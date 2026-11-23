# Cinny Helm Chart

Deploy [Cinny](https://github.com/cinnyapp/cinny), a Matrix web client, on Kubernetes.

## Requirements
 - Kubernetes 1.19+ (Ingress v1 is used when available; older gates handled in templates)
 - Helm 3.8+

## Parameters

### Image parameters

| Name               | Description                                       | Value            |
| ------------------ | ------------------------------------------------- | ---------------- |
| `image.registry`   | Image registry                                    | `ghcr.io`        |
| `image.repository` | Image repository                                  | `cinnyapp/cinny` |
| `image.pullPolicy` | Image pull policy                                 | `IfNotPresent`   |
| `image.tag`        | Image tag (defaults to chart appVersion if empty) | `""`             |

### Cinny configuration parameters

| Name                            | Description                                                                                      | Value                                                                                            |
| ------------------------------- | ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| `config.override`               | Replace the image's default config.json with one generated from the values below                 | `false`                                                                                          |
| `config.homeserverList`         | Homeservers offered on the login screen                                                          | `["matrix.privatetrace.io","converser.eu","envs.net","halogen.city","matrix.org","mozilla.org"]` |
| `config.defaultHomeserver`      | Index in homeserverList of the preselected homeserver (must be lower than the number of entries) | `0`                                                                                              |
| `config.allowCustomHomeservers` | Allow users to enter a homeserver that is not in homeserverList                                  | `true`                                                                                           |

### Network policy parameters

| Name                      | Description                                                                                                   | Value   |
| ------------------------- | ------------------------------------------------------------------------------------------------------------- | ------- |
| `networkpolicies.enabled` | Create NetworkPolicies for the Cinny Pod only: deny by default, then allow DNS, public egress and all ingress | `false` |

### Service account parameters

| Name                         | Description                                                                 | Value  |
| ---------------------------- | --------------------------------------------------------------------------- | ------ |
| `serviceAccount.create`      | Enable creation of a ServiceAccount                                         | `true` |
| `serviceAccount.annotations` | Annotations to add to the ServiceAccount                                    | `{}`   |
| `serviceAccount.name`        | Name of the ServiceAccount to use (auto-generated if empty and create=true) | `""`   |

### Deployment & Pod parameters

| Name                 | Description                                                               | Value |
| -------------------- | ------------------------------------------------------------------------- | ----- |
| `podAnnotations`     | Additional annotations to add to the Pod                                  | `{}`  |
| `podSecurityContext` | Pod-level security context (e.g. fsGroup)                                 | `{}`  |
| `securityContext`    | Container-level security context (e.g. runAsUser, readOnlyRootFilesystem) | `{}`  |

### Service parameters

| Name           | Description                                     | Value       |
| -------------- | ----------------------------------------------- | ----------- |
| `service.type` | Kubernetes Service type                         | `ClusterIP` |
| `service.port` | Service and container port for the Cinny web UI | `80`        |

### Ingress parameters

| Name                  | Description                                                                                                                                                                | Value   |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `ingress.enabled`     | Enable Ingress for the Cinny web UI                                                                                                                                        | `false` |
| `ingress.className`   | IngressClass name to use                                                                                                                                                   | `""`    |
| `ingress.annotations` | Extra annotations for the Ingress                                                                                                                                          | `{}`    |
| `ingress.hosts`       | List of host rules (each item supports host and paths[].path/pathType; pathType defaults to ImplementationSpecific; default: example host chart-example.local with path /) | `[]`    |
| `ingress.tls`         | TLS configuration for hosts (secretName, hosts[])                                                                                                                          | `[]`    |

### Resources & scheduling

| Name                        | Description                            | Value   |
| --------------------------- | -------------------------------------- | ------- |
| `resources.limits.cpu`      | CPU limit for the container            | `100m`  |
| `resources.limits.memory`   | Memory limit for the container         | `128Mi` |
| `resources.requests.cpu`    | CPU request for the container          | `100m`  |
| `resources.requests.memory` | Memory request for the container       | `128Mi` |
| `nodeSelector`              | Node selector rules for pod assignment | `{}`    |
| `tolerations`               | Tolerations for pod assignment         | `[]`    |
| `affinity`                  | Affinity rules for pod assignment      | `{}`    |

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