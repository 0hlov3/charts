# PrivateBin Helm Chart

This Helm chart deploys [PrivateBin](https://privatebin.info/), a minimalist, open-source online pastebin where the server has zero knowledge of pasted data.

## Features

- Deploy PrivateBin as a Kubernetes application
- Supports Ingress configuration
- Configurable resource limits and security contexts
- Persistent storage support
- Customizable PrivateBin configuration

## Installation
### Prerequisites

- Kubernetes 1.14+
- Helm 3+
- A running Ingress controller (if using Ingress)

### Add Helm Repository
```bash
helm repo add schoenwald https://charts.schoenwald.aero
helm repo update
```
### Install the Chart

```bash
helm install privatebin schoenwald/privatebin
```
or specify custom values:
```bash
helm install privatebin schoenwald/privatebin -f values.yaml
```

## Uninstall
To uninstall the chart and delete all associated resources:
```bash
helm uninstall privatebin
```

## Parameters

### PrivateBin parameters

| Name               | Description                                           | Value                         |
| ------------------ | ----------------------------------------------------- | ----------------------------- |
| `image.registry`   | PrivateBin image registry                             | `docker.io`                   |
| `image.repository` | PrivateBin image repository                           | `privatebin/nginx-fpm-alpine` |
| `image.pullPolicy` | PrivateBin image pullPolicy                           | `IfNotPresent`                |
| `image.tag`        | PrivateBin image tag (immutable tags are recommended) | `""`                          |

### PrivateBin config parameters

| Name                                          | Description                                                                                                                                                                                                                                                                                                                                                                                            | Value                             |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------- |
| `config.name`                                 | (optional) set a project name to be displayed on the website                                                                                                                                                                                                                                                                                                                                           | `PrivateBin`                      |
| `config.basepath`                             | The full URL, with the domain name and directories that point to the PrivateBin files, including an ending slash (/). This URL is essential to allow Opengraph images to be displayed on social networks.                                                                                                                                                                                              | `https://privatebin.example.com/` |
| `config.discussion`                           | enable or disable the discussion feature, defaults to true                                                                                                                                                                                                                                                                                                                                             | `true`                            |
| `config.opendiscussion`                       | preselect the discussion feature, defaults to false                                                                                                                                                                                                                                                                                                                                                    | `false`                           |
| `config.password`                             | enable or disable the password feature, defaults to true                                                                                                                                                                                                                                                                                                                                               | `true`                            |
| `config.fileupload`                           | enable or disable the file upload feature, defaults to false                                                                                                                                                                                                                                                                                                                                           | `false`                           |
| `config.burnafterreadingselected`             | preselect the burn-after-reading feature, defaults to false                                                                                                                                                                                                                                                                                                                                            | `false`                           |
| `config.defaultformatter`                     | which display mode to preselect by default, defaults to "plaintext"                                                                                                                                                                                                                                                                                                                                    | `plaintext`                       |
| `config.syntaxhighlightingtheme`              | (optional) set a syntax highlighting theme, as found in css/prettify/                                                                                                                                                                                                                                                                                                                                  | `""`                              |
| `config.sizelimit`                            | size limit per paste or comment in bytes, defaults to 10 Mebibytes                                                                                                                                                                                                                                                                                                                                     | `10000000`                        |
| `config.template`                             | template to include, default is "bootstrap5" (tpl/bootstrap5.php), also available are "bootstrap" (tpl/bootstrap.php), the classic ZeroBin style and several bootstrap variants: "bootstrap-dark", "bootstrap-compact", "bootstrap-page", which can be combined with "-dark" and "-compact" for "bootstrap-dark-page" and finally "bootstrap-compact-page" - previews at: https://privatebin.info/screenshots.html | `bootstrap5`                      |
| `config.languageselection`                    | by default PrivateBin will guess the visitors language based on the browsers settings. Optionally you can enable the language selection menu, which uses a session cookie to store the choice until the browser is closed.                                                                                                                                                                             | `false`                           |
| `config.expire.default`                       | expire value that is selected per default                                                                                                                                                                                                                                                                                                                                                              | `1week`                           |
| `config.formatter_options.plaintext`          | Set available formatters, their order and their labels                                                                                                                                                                                                                                                                                                                                                 | `Plain Text`                      |
| `config.formatter_options.syntaxhighlighting` | Set available formatters, their order and their labels                                                                                                                                                                                                                                                                                                                                                 | `Source Code`                     |
| `config.formatter_options.markdown`           | Set available formatters, their order and their labels                                                                                                                                                                                                                                                                                                                                                 | `Markdown`                        |
| `config.traffic.limit`                        | time limit between calls from the same IP address in seconds Set this to 0 to disable rate limiting.                                                                                                                                                                                                                                                                                                   | `10`                              |
| `config.traffic.exempted`                     | (optional) Set IPs addresses (v4 or v6) or subnets (CIDR) which are exempted from the rate-limit. Invalid IPs will be ignored. If multiple values are to  be exempted, the list needs to be comma separated. Leave unset to disable                                                                                                                                                                    | `""`                              |
| `persistence.enabled`                         | Enable persistence using a PersistentVolumeClaim                                                                                                                                                                                                                                                                                                                                                       | `false`                           |
| `persistence.capacity`                        | Persistent Volume Size                                                                                                                                                                                                                                                                                                                                                                                 | `1Gi`                             |

### Additional Config

| Name                                     | Description                                                                                                                      | Value       |
| ---------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| `imagePullSecrets`                       | image pull secrets                                                                                                               | `[]`        |
| `nameOverride`                           | String to partially override common.names.fullname                                                                               | `""`        |
| `fullnameOverride`                       | String to fully override common.names.fullname                                                                                   | `""`        |
| `serviceAccount.create`                  | whether a service account should be created                                                                                      | `true`      |
| `serviceAccount.annotations`             | Annotations to add to the service account                                                                                        | `{}`        |
| `serviceAccount.name`                    | The name of the service account to use, if not set and create is true, a name is generated using the fullname template           | `""`        |
| `podAnnotations`                         | Pod annotations                                                                                                                  | `{}`        |
| `podSecurityContext.fsGroup`             | Security Context fsGroup                                                                                                         | `82`        |
| `securityContext.runAsNonRoot`           | Set Controller container's Security Context runAsNonRoot                                                                         | `true`      |
| `securityContext.runAsUser`              | Security Context runAsUser                                                                                                       | `65534`     |
| `securityContext.runAsGroup`             | Security Context runAsGroup                                                                                                      | `82i`       |
| `securityContext.readOnlyRootFilesystem` | Set primary container's Security Context readOnlyRootFilesystem                                                                  | `true`      |
| `service.type`                           | service type                                                                                                                     | `ClusterIP` |
| `service.port`                           | service port                                                                                                                     | `8080`      |
| `livenessProbe.enabled`                  | Enable liveness probe                                                                                                            | `true`      |
| `livenessProbe.config`                   | Liveness probe configuration                                                                                                     | `{}`        |
| `readinessProbe.enabled`                 | Enable readiness probe                                                                                                           | `true`      |
| `readinessProbe.config`                  | Readiness probe configuration                                                                                                    | `{}`        |
| `ingress.enabled`                        | Enable ingress record generation                                                                                                 | `false`     |
| `ingress.className`                      | IngressClass that will be used to implement the Ingress                                                                          | `""`        |
| `ingress.annotations`                    | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. | `{}`        |
| `ingress.tls`                            | TLS configuration                                                                                                                | `[]`        |
| `tolerations`                            | Tolerations for pod assignment                                                                                                   | `[]`        |
| `affinity`                               | Affinity for pod assignment                                                                                                      | `{}`        |


## Contributing
Feel free to submit issues and pull requests to improve this Helm chart.
