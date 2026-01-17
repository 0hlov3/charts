# koffan

Helm chart for Koffan.

## Notes

- SQLite does not support safe horizontal scaling. Keep `replicaCount: 1` in production.
- Default behavior: `persistence.enabled: true` and `persistence.useEmptyDir: false`, so a PVC is created.
- For dev/testing without persistence, set `persistence.enabled: false` and
  `persistence.useEmptyDir: false` to run with the container filesystem.

## Minimal values

```yaml
auth:
  createSecret: false
  existingSecret:
    name: "koffan-secret"
    passwordKey: app-password

ingress:
  enabled: true
  className: "nginx-external"
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    kubernetes.io/tls-acme: "true"
  hosts:
    - host: shopping.example.io
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - secretName: tls-koffan-general
      hosts:
       - shopping.example.io
```

## Parameters

### Koffan Parameters

| Name                                       | Description                                                                        | Value                     |
| ------------------------------------------ | ---------------------------------------------------------------------------------- | ------------------------- |
| `replicaCount`                             | Number of replicas to deploy                                                       | `1`                       |
| `image.registry`                           | image registry                                                                     | `ghcr.io`                 |
| `image.repository`                         | image repository                                                                   | `pansalut/koffan`         |
| `image.pullPolicy`                         | image pull policy                                                                  | `IfNotPresent`            |
| `image.tag`                                | image tag (immutable tags are recommended)                                         | `""`                      |
| `app.env`                                  | Set to development for non secure cookies                                          | `production`              |
| `app.port`                                 | Service port used by the container                                                 | `80`                      |
| `app.dbPath`                               | Database file path                                                                 | `/data/shopping.db`       |
| `app.defaultLang`                          | Default UI language (pl, en, de, es, fr, pt, uk, no, lt, el)                       | `en`                      |
| `app.loginMaxAttempts`                     | Max login attempts before lockout                                                  | `5`                       |
| `app.loginWindowMinutes`                   | Time window for counting attempts                                                  | `15`                      |
| `app.loginLockoutMinutes`                  | Lockout duration after exceeding limit                                             | `30`                      |
| `auth.disableAuth`                         | Set to true to disable authentication (for reverse proxy setups)                   | `false`                   |
| `auth.password`                            | Login password (ignored when auth.existingSecret.name is set)                      | `change-me`               |
| `auth.apiToken.enabled`                    | Enable REST API using a token                                                      | `false`                   |
| `auth.apiToken.value`                      | Token value (ignored when auth.existingSecret.name is set)                         | `""`                      |
| `auth.createSecret`                        | Create a Secret for app credentials                                                | `true`                    |
| `auth.existingSecret.name`                 | Use an existing Secret name instead of creating one                                | `""`                      |
| `auth.existingSecret.passwordKey`          | Key name for the password in the Secret (also used for chart-created Secret keys)  | `app-password`            |
| `auth.existingSecret.apiTokenKey`          | Key name for the API token in the Secret (also used for chart-created Secret keys) | `api-token`               |
| `persistence.enabled`                      | Enable persistent storage for the DB                                               | `true`                    |
| `persistence.size`                         | Persistent volume size                                                             | `1Gi`                     |
| `persistence.accessModes`                  | Persistent volume access modes                                                     | `["ReadWriteOnce"]`       |
| `persistence.storageClass`                 | Storage class for the PVC (empty = default)                                        | `""`                      |
| `persistence.annotations`                  | PVC annotations                                                                    | `{}`                      |
| `persistence.existingClaim`                | Use an existing PVC instead of creating one                                        | `""`                      |
| `persistence.mountPath`                    | Mount path for the DB directory                                                    | `/data`                   |
| `persistence.useEmptyDir`                  | Use an emptyDir when persistence is disabled                                       | `false`                   |
| `imagePullSecrets`                         | Secrets for pulling images from a private registry                                 | `[]`                      |
| `nameOverride`                             | Override the chart name                                                            | `""`                      |
| `fullnameOverride`                         | Override the full chart name                                                       | `""`                      |
| `serviceAccount.create`                    | Create a service account                                                           | `true`                    |
| `serviceAccount.automount`                 | Automount service account token                                                    | `false`                   |
| `serviceAccount.annotations`               | Service account annotations                                                        | `{}`                      |
| `serviceAccount.name`                      | Service account name                                                               | `""`                      |
| `podAnnotations`                           | Pod annotations                                                                    | `{}`                      |
| `podLabels`                                | Pod labels                                                                         | `{}`                      |
| `podSecurityContext.fsGroup`               | Pod security context fsGroup                                                       | `1000`                    |
| `securityContext.capabilities.drop`        | Container security context capabilities drop list                                  | `["ALL"]`                 |
| `securityContext.readOnlyRootFilesystem`   | Container security context read-only root filesystem                               | `true`                    |
| `securityContext.runAsNonRoot`             | Container security context run as non-root                                         | `true`                    |
| `securityContext.runAsUser`                | Container security context run as user                                             | `1000`                    |
| `service.type`                             | Service type                                                                       | `ClusterIP`               |
| `service.port`                             | Service port                                                                       | `80`                      |
| `ingress.enabled`                          | Enable ingress                                                                     | `false`                   |
| `ingress.className`                        | Ingress class name                                                                 | `""`                      |
| `ingress.annotations`                      | Ingress annotations                                                                | `{}`                      |
| `ingress.hosts[0].host`                    | Ingress host                                                                       | `chart-example.local`     |
| `ingress.hosts[0].paths[0].path`           | Ingress path                                                                       | `/`                       |
| `ingress.hosts[0].paths[0].pathType`       | Ingress path type                                                                  | `ImplementationSpecific`  |
| `ingress.tls`                              | Ingress TLS configuration                                                          | `[]`                      |
| `httpRoute.enabled`                        | Enable HTTPRoute                                                                   | `false`                   |
| `httpRoute.annotations`                    | HTTPRoute annotations                                                              | `{}`                      |
| `httpRoute.parentRefs[0].name`             | HTTPRoute parent ref name                                                          | `gateway`                 |
| `httpRoute.parentRefs[0].sectionName`      | HTTPRoute parent ref section name                                                  | `http`                    |
| `httpRoute.hostnames`                      | HTTPRoute hostnames                                                                | `["chart-example.local"]` |
| `httpRoute.rules[0].matches[0].path.type`  | HTTPRoute match path type                                                          | `PathPrefix`              |
| `httpRoute.rules[0].matches[0].path.value` | HTTPRoute match path value                                                         | `/headers`                |
| `resources`                                | Container resources                                                                | `{}`                      |
| `livenessProbe.httpGet.path`               | Liveness probe path                                                                | `/`                       |
| `livenessProbe.httpGet.port`               | Liveness probe port                                                                | `http`                    |
| `readinessProbe.httpGet.path`              | Readiness probe path                                                               | `/`                       |
| `readinessProbe.httpGet.port`              | Readiness probe port                                                               | `http`                    |
| `volumes`                                  | Additional volumes                                                                 | `[]`                      |
| `volumeMounts`                             | Additional volume mounts                                                           | `[]`                      |
| `nodeSelector`                             | Node selector                                                                      | `{}`                      |
| `tolerations`                              | Pod tolerations                                                                    | `[]`                      |
| `affinity`                                 | Pod affinity                                                                       | `{}`                      |
