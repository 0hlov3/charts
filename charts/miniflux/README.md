# Miniflux


## Parameters

### Global parameters

| Name               | Description                                                 | Value |
| ------------------ | ----------------------------------------------------------- | ----- |
| `nameOverride`     | String to partially override common.names.name              | `""`  |
| `fullnameOverride` | String to fully override common.names.fullname              | `""`  |
| `imagePullSecrets` | Global image pull secrets (list of Kubernetes Secret names) | `[]`  |

### Image parameters

| Name               | Description                                            | Value               |
| ------------------ | ------------------------------------------------------ | ------------------- |
| `image.registry`   | Miniflux image registry                                | `docker.io`         |
| `image.repository` | Miniflux image repository                              | `miniflux/miniflux` |
| `image.pullPolicy` | Miniflux image pull policy                             | `IfNotPresent`      |
| `image.tag`        | Miniflux image tag (overrides chart appVersion if set) | `""`                |

### Miniflux configuration

| Name                 | Description                                                                                                           | Value |
| -------------------- | --------------------------------------------------------------------------------------------------------------------- | ----- |
| `env.RUN_MIGRATIONS` | Run database migrations on startup ("1" or "0")                                                                       | `1`   |
| `env.CREATE_ADMIN`   | Create admin user on startup ("1" or "0"). The admin credentials are only read from admin.existingSecret when enabled | `1`   |
| `env.BASE_URL`       | Public base URL (e.g. https://rss.example.com)                                                                        | `""`  |

### Credentials

| Name                               | Description                                                                                                | Value                  |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------------- | ---------------------- |
| `database.existingSecret.name`     | Name of the existing Secret holding the PostgreSQL connection URL (DATABASE_URL)                           | `miniflux-db-creds`    |
| `database.existingSecret.key`      | Key inside the Secret holding the connection URL (e.g. postgres://user:pass@host/miniflux?sslmode=disable) | `database_url`         |
| `admin.existingSecret.name`        | Name of the existing Secret holding the admin credentials (only used when env.CREATE_ADMIN is enabled)     | `miniflux-admin-creds` |
| `admin.existingSecret.usernameKey` | Key inside the Secret holding the admin username                                                           | `username`             |
| `admin.existingSecret.passwordKey` | Key inside the Secret holding the admin password                                                           | `password`             |

### Extra environment variables

| Name       | Description                                                                                                                                                                                                                                                                                                      | Value |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| `extraEnv` | Additional environment variables for the Miniflux container (Kubernetes EnvVar objects with value or valueFrom). Not allowed: variables set by the chart (DATABASE_URL, RUN_MIGRATIONS, CREATE_ADMIN, ADMIN_USERNAME, ADMIN_PASSWORD, BASE_URL and their _FILE variants) and PORT/LISTEN_ADDR (use service.port) | `[]`  |

### ServiceAccount parameters

| Name                         | Description                                                                      | Value   |
| ---------------------------- | -------------------------------------------------------------------------------- | ------- |
| `serviceAccount.create`      | Specifies whether a service account should be created                            | `true`  |
| `serviceAccount.automount`   | Automatically mount ServiceAccount API credentials                               | `false` |
| `serviceAccount.annotations` | Annotations to add to the service account                                        | `{}`    |
| `serviceAccount.name`        | The name of the service account to use (auto-generated if empty and create=true) | `""`    |

### Pod metadata

| Name             | Description                   | Value |
| ---------------- | ----------------------------- | ----- |
| `podAnnotations` | Annotations to add to the Pod | `{}`  |
| `podLabels`      | Labels to add to the Pod      | `{}`  |

### Security contexts

| Name                                     | Description                              | Value  |
| ---------------------------------------- | ---------------------------------------- | ------ |
| `podSecurityContext.fsGroup`             | Pod fsGroup                              | `1000` |
| `securityContext.readOnlyRootFilesystem` | Mount root filesystem as read-only       | `true` |
| `securityContext.runAsNonRoot`           | Require the container to run as non-root | `true` |
| `securityContext.runAsUser`              | Container UID                            | `1000` |

### Service parameters

| Name           | Description             | Value       |
| -------------- | ----------------------- | ----------- |
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port            | `8080`      |

### Ingress parameters

| Name                  | Description                        | Value   |
| --------------------- | ---------------------------------- | ------- |
| `ingress.enabled`     | Enable ingress controller resource | `false` |
| `ingress.className`   | IngressClass name                  | `""`    |
| `ingress.annotations` | Ingress annotations                | `{}`    |
| `ingress.tls`         | Ingress TLS configuration          | `[]`    |

### Gateway API parameters

| Name                    | Description                  | Value   |
| ----------------------- | ---------------------------- | ------- |
| `httpRoute.enabled`     | Enable Gateway API HTTPRoute | `false` |
| `httpRoute.annotations` | HTTPRoute annotations        | `{}`    |

### Resource parameters


### Probes parameters


### Extra volume parameters

| Name           | Description                                | Value |
| -------------- | ------------------------------------------ | ----- |
| `volumes`      | Extra volumes to add to the Deployment     | `[]`  |
| `volumeMounts` | Extra volumeMounts to add to the container | `[]`  |

### Scheduling parameters

| Name           | Description                    | Value |
| -------------- | ------------------------------ | ----- |
| `nodeSelector` | Node labels for pod assignment | `{}`  |
| `tolerations`  | Tolerations for pod assignment | `[]`  |
| `affinity`     | Affinity for pod assignment    | `{}`  |
