# Joplin Server Chart

> **Breaking change:** Chart >= 1.0.0 is **not compatible** with upgrades from earlier versions.
> The Bitnami PostgreSQL sub-chart has been removed and the values schema was restructured.
> See the migration note below before proceeding.

## Add the Chart

```shell
helm repo add schoenwald https://charts.schoenwald.aero
helm repo update schoenwald
```

## Show versions

```shell
helm search repo schoenwald/joplin-server
```

## Database backends

| `joplin.database.client` | Use case |
|---|---|
| `sqlite` (default) | Testing, development, single-user |
| `pg` | Production, multi-user |

### SQLite (default)

No extra configuration needed. The database file lives at `/home/joplin/.config/joplin-server/` inside the container — enable persistence so it survives pod restarts:

```yaml
persistence:
  enabled: true
  mountPath: /home/joplin/.config/joplin-server
  size: 2Gi
```

> **Note:** SQLite is not suitable for production or multi-user deployments.

### PostgreSQL

Provision PostgreSQL externally, set `joplin.database.client: pg`, and supply the credentials via `joplin.postgres.*` or a Kubernetes Secret.

## Create Namespace

```shell
kubectl create namespace joplin --dry-run=client -o yaml | kubectl apply -f -
```

## Configure PostgreSQL credentials

### Option A — plain values (not recommended for production)

```yaml
joplin:
  postgres:
    host: my-postgres.example.com
    port: 5432
    database: joplin-server
    user: joplin
    password: supersecret
```

### Option B — existing Secret (recommended)

```shell
kubectl create secret generic joplin-postgres \
  --namespace joplin \
  --from-literal=password='supersecret'
```

```yaml
joplin:
  postgres:
    host: my-postgres.example.com
    database: joplin-server
    user: joplin
    existingSecret: joplin-postgres
    existingSecretPasswordKey: password
```

## Configure Mailer (optional)

Create the Secret when `.Values.joplin.mailer.enabled` is `true`.
All keys must be present even if empty.

```shell
kubectl create secret generic joplin-mailer \
  --namespace joplin \
  --from-literal=mailerHost='' \
  --from-literal=mailerPort='' \
  --from-literal=mailerSecure='' \
  --from-literal=mailerAuthUser='' \
  --from-literal=mailerAuthPassword='' \
  --from-literal=mailerNoreplyName='' \
  --from-literal=mailerNoreplyEmail=''
```

## Configure Storage (optional)

The default storage driver keeps all data in PostgreSQL (`Type=Database`).
To use filesystem storage, enable persistence and point the driver at the mount path:

```yaml
joplin:
  storage:
    driver: "Type=Filesystem; Path=/data"

persistence:
  enabled: true
  size: 10Gi
```

For S3:

```yaml
joplin:
  storage:
    driver: "Type=S3; Region=us-east-1; AccessKeyId=…; SecretAccessKeyId=…; Bucket=my-bucket"
```

## Deploy

```shell
helm upgrade --install joplin schoenwald/joplin-server \
  --namespace joplin \
  --create-namespace \
  -f my-values.yaml
```

## Migration from chart < 1.0.0

1. **Back up your data** — dump the PostgreSQL database managed by the old Bitnami sub-chart.
2. Restore the dump into your external PostgreSQL instance.
3. Uninstall the old release: `helm uninstall joplin -n joplin`
4. Deploy fresh with the new values schema shown above.

There is no in-place upgrade path between chart versions `< 1.0.0` and `>= 1.0.0`.

## Parameters

### Global parameters

| Name           | Description                      | Value |
| -------------- | -------------------------------- | ----- |
| `replicaCount` | Number of Joplin Server replicas | `1`   |

### Image parameters

| Name               | Description                                         | Value           |
| ------------------ | --------------------------------------------------- | --------------- |
| `image.repository` | Docker image repository                             | `joplin/server` |
| `image.pullPolicy` | Image pull policy                                   | `IfNotPresent`  |
| `image.tag`        | Image tag (overrides the chart appVersion when set) | `""`            |
| `imagePullSecrets` | List of image pull secret names                     | `[]`            |
| `nameOverride`     | Override for the chart name                         | `""`            |
| `fullnameOverride` | Override for the full release name                  | `""`            |

### Joplin parameters

| Name                                        | Description                                                                                                                                                        | Value                    |
| ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------ |
| `joplin.appBaseUrl`                         | Publicly reachable base URL of the server (e.g. https://joplin.example.com)                                                                                        | `http://localhost:22300` |
| `joplin.appPort`                            | Port the Joplin Server process listens on inside the container                                                                                                     | `22300`                  |
| `joplin.database.client`                    | Database backend. `sqlite` for testing/single-user; `pg` for production                                                                                            | `sqlite`                 |
| `joplin.postgres.host`                      | PostgreSQL host                                                                                                                                                    | `localhost`              |
| `joplin.postgres.port`                      | PostgreSQL port                                                                                                                                                    | `5432`                   |
| `joplin.postgres.database`                  | PostgreSQL database name                                                                                                                                           | `joplin-server`          |
| `joplin.postgres.user`                      | PostgreSQL username                                                                                                                                                | `joplin`                 |
| `joplin.postgres.password`                  | Plain-text PostgreSQL password. Ignored when existingSecret is set. Do NOT use in production.                                                                      | `""`                     |
| `joplin.postgres.existingSecret`            | Name of an existing Secret containing the PostgreSQL password                                                                                                      | `""`                     |
| `joplin.postgres.existingSecretPasswordKey` | Key inside the Secret that holds the PostgreSQL password                                                                                                           | `password`               |
| `joplin.postgres.sslModeNoVerify`           | Connect via POSTGRES_CONNECTION_STRING with ?sslmode=no-verify appended                                                                                            | `false`                  |
| `joplin.storage.driver`                     | STORAGE_DRIVER passed verbatim to Joplin Server. Examples: `Type=Database`, `Type=Filesystem; Path=/data`, `Type=S3; Region=…`                                     | `Type=Database`          |
| `joplin.storage.driverFallback`             | Optional STORAGE_DRIVER_FALLBACK value for migration scenarios                                                                                                     | `""`                     |
| `joplin.mailer.enabled`                     | Enable mailer support. Requires an existing Secret named by joplin.mailer.existingSecretName                                                                       | `false`                  |
| `joplin.mailer.existingSecretName`          | Name of the Secret with mailer credentials (keys: mailerHost, mailerPort, mailerSecure, mailerAuthUser, mailerAuthPassword, mailerNoreplyName, mailerNoreplyEmail) | `joplin-mailer`          |

### Persistence parameters

| Name                        | Description                                                                     | Value                                |
| --------------------------- | ------------------------------------------------------------------------------- | ------------------------------------ |
| `persistence.enabled`       | Enable persistent storage. Required for SQLite and Filesystem storage backends. | `false`                              |
| `persistence.mountPath`     | Mount path inside the container                                                 | `/home/joplin/.config/joplin-server` |
| `persistence.storageClass`  | StorageClass for the PVC. Leave empty to use the cluster default.               | `""`                                 |
| `persistence.accessMode`    | PVC access mode                                                                 | `ReadWriteOnce`                      |
| `persistence.size`          | PVC size                                                                        | `1Gi`                                |
| `persistence.existingClaim` | Name of an existing PVC to use instead of creating one                          | `""`                                 |

### Service Account parameters

| Name                         | Description                                                                              | Value  |
| ---------------------------- | ---------------------------------------------------------------------------------------- | ------ |
| `serviceAccount.create`      | Create a ServiceAccount for the pod                                                      | `true` |
| `serviceAccount.annotations` | Annotations to add to the ServiceAccount                                                 | `{}`   |
| `serviceAccount.name`        | Name of the ServiceAccount. Auto-generated when empty and serviceAccount.create is true. | `""`   |

### Pod parameters

| Name                                     | Description                                      | Value   |
| ---------------------------------------- | ------------------------------------------------ | ------- |
| `podAnnotations`                         | Annotations to add to the pod                    | `{}`    |
| `podSecurityContext.fsGroup`             | Group ID for the pod filesystem                  | `1001`  |
| `securityContext.capabilities.drop`      | Capabilities to drop from the container          | `[]`    |
| `securityContext.readOnlyRootFilesystem` | Mount the container root filesystem as read-only | `false` |
| `securityContext.runAsNonRoot`           | Require the container to run as a non-root user  | `true`  |
| `securityContext.runAsUser`              | User ID to run the container process             | `1001`  |
| `securityContext.runAsGroup`             | Group ID to run the container process            | `1001`  |

### Service parameters

| Name           | Description             | Value       |
| -------------- | ----------------------- | ----------- |
| `service.type` | Kubernetes Service type | `ClusterIP` |
| `service.port` | Service port            | `80`        |

### Ingress parameters

| Name                                 | Description                                       | Value                    |
| ------------------------------------ | ------------------------------------------------- | ------------------------ |
| `ingress.enabled`                    | Enable Ingress                                    | `false`                  |
| `ingress.className`                  | IngressClass name (e.g. nginx)                    | `nginx`                  |
| `ingress.annotations`                | Additional annotations for the Ingress            | `{}`                     |
| `ingress.hosts[0].host`              | Hostname for the Ingress rule                     | `chart-example.local`    |
| `ingress.hosts[0].paths[0].path`     | URL path                                          | `/`                      |
| `ingress.hosts[0].paths[0].pathType` | Path type (Exact, Prefix, ImplementationSpecific) | `ImplementationSpecific` |
| `ingress.tls`                        | TLS configuration for the Ingress                 | `[]`                     |

### Resource parameters

| Name                        | Description    | Value   |
| --------------------------- | -------------- | ------- |
| `resources.limits.memory`   | Memory limit   | `512Mi` |
| `resources.limits.cpu`      | CPU limit      | `500m`  |
| `resources.requests.memory` | Memory request | `256Mi` |
| `resources.requests.cpu`    | CPU request    | `100m`  |

### Autoscaling parameters

| Name                                         | Description                       | Value   |
| -------------------------------------------- | --------------------------------- | ------- |
| `autoscaling.enabled`                        | Enable Horizontal Pod Autoscaler  | `false` |
| `autoscaling.minReplicas`                    | Minimum number of replicas        | `1`     |
| `autoscaling.maxReplicas`                    | Maximum number of replicas        | `5`     |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization percentage | `80`    |

### Scheduling parameters

| Name           | Description                       | Value |
| -------------- | --------------------------------- | ----- |
| `nodeSelector` | Node labels for pod assignment    | `{}`  |
| `tolerations`  | Tolerations for pod assignment    | `[]`  |
| `affinity`     | Affinity rules for pod assignment | `{}`  |
