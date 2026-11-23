# Element Web Helm Chart

Deploy [Element Web](https://github.com/element-hq/element-web), a Matrix web client, on Kubernetes.

## Requirements
 - Kubernetes 1.19+
 - Helm 3.8+

## Configuration

`defaultServer.url` and `defaultServer.name` are required and render the `default_server_config` block of Element's `config.json`. The identity server defaults to `https://vector.im` and can be overridden with `defaultServer.identity_url`. Any additional settings in `config` are merged into `config.json`; see the [Element configuration docs](https://github.com/element-hq/element-web/blob/develop/docs/config.md).

## Parameters

### Deployment parameters

| Name           | Description                                                          | Value |
| -------------- | -------------------------------------------------------------------- | ----- |
| `replicaCount` | Number of Element Web replicas (ignored when autoscaling is enabled) | `1`   |

### Image parameters

| Name               | Description                                       | Value                  |
| ------------------ | ------------------------------------------------- | ---------------------- |
| `image.registry`   | Image registry                                    | `docker.io`            |
| `image.repository` | Image repository                                  | `vectorim/element-web` |
| `image.pullPolicy` | Image pull policy                                 | `IfNotPresent`         |
| `image.tag`        | Image tag (defaults to chart appVersion if empty) | `""`                   |

### Element configuration parameters

| Name                   | Description                                                                    | Value                        |
| ---------------------- | ------------------------------------------------------------------------------ | ---------------------------- |
| `defaultServer.url`    | Base URL of the default homeserver (required)                                  | `https://matrix.example.com` |
| `defaultServer.name`   | Server name of the default homeserver (required)                               | `matrix.example.com`         |
| `config`               | Additional Element config.json settings                                        | `{}`                         |
| `env.ELEMENT_WEB_PORT` | Port Element Web listens on (currently not rendered; the Deployment uses 8080) | `8080`                       |

### Volume parameters

| Name                | Description                                                 | Value |
| ------------------- | ----------------------------------------------------------- | ----- |
| `extraVolumes`      | Additional volumes to add to the Pod                        | `[]`  |
| `extraVolumeMounts` | Additional volumeMounts to add to the Element Web container | `[]`  |

### Common parameters

| Name               | Description                                 | Value |
| ------------------ | ------------------------------------------- | ----- |
| `imagePullSecrets` | Image pull secrets for private registries   | `[]`  |
| `nameOverride`     | String to partially override the chart name | `""`  |
| `fullnameOverride` | String to fully override the release name   | `""`  |

### Service account parameters

| Name                         | Description                                                                 | Value  |
| ---------------------------- | --------------------------------------------------------------------------- | ------ |
| `serviceAccount.create`      | Enable creation of a ServiceAccount                                         | `true` |
| `serviceAccount.annotations` | Annotations to add to the ServiceAccount                                    | `{}`   |
| `serviceAccount.name`        | Name of the ServiceAccount to use (auto-generated if empty and create=true) | `""`   |

### Pod parameters

| Name                                | Description                                     | Value     |
| ----------------------------------- | ----------------------------------------------- | --------- |
| `podAnnotations`                    | Additional annotations to add to the Pod        | `{}`      |
| `podSecurityContext.fsGroup`        | Group ID for the Pod's volumes                  | `1000`    |
| `securityContext.capabilities.drop` | Linux capabilities to drop                      | `["ALL"]` |
| `securityContext.runAsNonRoot`      | Require the container to run as a non-root user | `true`    |
| `securityContext.runAsUser`         | User ID to run the container as                 | `1000`    |

### Service parameters

| Name           | Description                         | Value       |
| -------------- | ----------------------------------- | ----------- |
| `service.type` | Kubernetes Service type             | `ClusterIP` |
| `service.port` | Service port for the Element Web UI | `80`        |

### Ingress parameters

| Name                  | Description                                                                                                                   | Value   |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------- | ------- |
| `ingress.enabled`     | Enable Ingress for the Element Web UI                                                                                         | `false` |
| `ingress.className`   | IngressClass name to use                                                                                                      | `""`    |
| `ingress.annotations` | Extra annotations for the Ingress                                                                                             | `{}`    |
| `ingress.hosts`       | List of host rules (each item supports host and paths[].path/pathType; default: example host chart-example.local with path /) | `[]`    |
| `ingress.tls`         | TLS configuration for hosts (secretName, hosts[])                                                                             | `[]`    |

### Resources & scheduling

| Name                                         | Description                              | Value   |
| -------------------------------------------- | ---------------------------------------- | ------- |
| `resources.limits.cpu`                       | CPU limit for the container              | `200m`  |
| `resources.limits.memory`                    | Memory limit for the container           | `256Mi` |
| `resources.requests.cpu`                     | CPU request for the container            | `200m`  |
| `resources.requests.memory`                  | Memory request for the container         | `256Mi` |
| `autoscaling.enabled`                        | Enable a HorizontalPodAutoscaler         | `false` |
| `autoscaling.minReplicas`                    | Minimum number of replicas               | `1`     |
| `autoscaling.maxReplicas`                    | Maximum number of replicas               | `100`   |
| `autoscaling.targetCPUUtilizationPercentage` | Target average CPU utilization (percent) | `80`    |
| `nodeSelector`                               | Node selector rules for pod assignment   | `{}`    |
| `tolerations`                                | Tolerations for pod assignment           | `[]`    |
| `affinity`                                   | Affinity rules for pod assignment        | `{}`    |

### Network policy parameters

| Name                    | Description                                    | Value   |
| ----------------------- | ---------------------------------------------- | ------- |
| `networkPolicy.enabled` | Create a NetworkPolicy for the Element Web Pod | `false` |

## Contributing
Issues and PRs welcome! Please bump the chart version in Chart.yaml when changing templates or values, and keep this README’s Parameters in sync using the [Bitnami generator](https://github.com/bitnami/readme-generator-for-helm).
```shell
podman run -v $(pwd):/chart 0hlov3/readme-generator-for-helm readme-generator --readme=/chart/README.md --values=/chart/values.yaml
```
