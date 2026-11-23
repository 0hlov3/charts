# Linkwarden Helm Chart

Deploy [Linkwarden](https://github.com/linkwarden/linkwarden), a self-hosted collaborative bookmark manager that keeps a snapshot of every saved page, on Kubernetes.

## Requirements
 - Kubernetes 1.19+
 - Helm 3.8+
 - An external PostgreSQL database

## Installation

```shell
helm repo add schoenwald https://charts.schoenwald.aero
helm install linkwarden schoenwald/linkwarden \
  --set env.nextauth.url=https://linkwarden.example.com/api/v1/auth \
  --set env.nextauth.secret="$(openssl rand -base64 32)" \
  --set externalPostgresql.host=postgresql.example.svc.cluster.local \
  --set externalPostgresql.username=linkwarden \
  --set externalPostgresql.password=<password> \
  --set persistence.enabled=true
```

For production, keep the secrets in existing Kubernetes Secrets (`env.nextauth.existingSecret` and `externalPostgresql.existingSecret`) instead of passing them as values.

## Parameters

### image parameters

| Name               | Description       | Value                   |
| ------------------ | ----------------- | ----------------------- |
| `image.registry`   | image registry    | `ghcr.io`               |
| `image.repository` | image repository  | `linkwarden/linkwarden` |
| `image.pullPolicy` | image pull policy | `IfNotPresent`          |

### Linkwarden Environment Config

| Name                               | Description                                                                                                                               | Value                               |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| `env.nextauth.url`                 | Defines the NEXTAUTH_URL and specifies the base URL for NextAuth.js authentication endpoints.                                             | `http://localhost:3000/api/v1/auth` |
| `env.nextauth.secret`              | Defines the NEXTAUTH_SECRET and is used by NextAuth.js to encrypt session tokens and JWTs. Can be generated via `openssl rand -base64 32` | `""`                                |
| `env.nextauth.existingSecret.name` | Defines the NEXTAUTH_SECRET kubernetes secret name where to get the secret.                                                               | `""`                                |
| `env.nextauth.existingSecret.key`  | Defines the NEXTAUTH_SECRET kubernetes secret key where to get the secret.                                                                | `""`                                |
| `extraEnv`                         | additional environment variables to pass to the Linkwarden deployment                                                                     | `[]`                                |

### Persistence

| Name                           | Description                                                                                                                                                                      | Value           |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| `persistence.enabled`          | Store Linkwarden data (/data/data: archived pages, screenshots, PDFs) in a PersistentVolumeClaim. When false, an emptyDir is used and the data is lost whenever the pod restarts | `false`         |
| `persistence.size`             | Size of the PersistentVolumeClaim for Linkwarden data                                                                                                                            | `1Gi`           |
| `persistence.accessMode`       | Access mode of the PersistentVolumeClaim                                                                                                                                         | `ReadWriteOnce` |
| `persistence.storageClassName` | StorageClass of the PersistentVolumeClaim. If empty, the default StorageClass is used                                                                                            | `""`            |

### Database Configuration

| Name                                              | Description                                                                                                                   | Value                                     |
| ------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------- |
| `externalPostgresql.enabled`                      | Enable external PostgreSQL as the database backend.                                                                           | `true`                                    |
| `externalPostgresql.host`                         | Hostname of the external PostgreSQL database.                                                                                 | `postgresql.postgresql.svc.cluster.local` |
| `externalPostgresql.port`                         | Port for the external PostgreSQL database, as a quoted string (e.g. "5432")                                                   | `5432`                                    |
| `externalPostgresql.database`                     | Name of the database to use. Must be URL-safe (see externalPostgresql.password)                                               | `linkwarden`                              |
| `externalPostgresql.username`                     | Username of the database to use. Must be URL-safe (see externalPostgresql.password)                                           | `""`                                      |
| `externalPostgresql.password`                     | Password of the database to use. It is inserted into DATABASE_URL without URL encoding, so it must not contain @ : / # ? or % | `""`                                      |
| `externalPostgresql.existingSecret.name`          | Name of an existing Kubernetes secret containing database credentials.                                                        | `""`                                      |
| `externalPostgresql.existingSecret.keys.host`     | Key for the host in the existing secret.                                                                                      | `""`                                      |
| `externalPostgresql.existingSecret.keys.port`     | Key for the port in the existing secret. The value must be the bare port number (no trailing newline)                         | `""`                                      |
| `externalPostgresql.existingSecret.keys.database` | Key for the database name in the existing secret.                                                                             | `""`                                      |
| `externalPostgresql.existingSecret.keys.username` | Key for the username in the existing secret.                                                                                  | `""`                                      |
| `externalPostgresql.existingSecret.keys.password` | Key for the password in the existing secret.                                                                                  | `""`                                      |

### Traffic Exposure Parameters

| Name                  | Description                                                                                                                      | Value       |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| `service.type`        | Service type                                                                                                                     | `ClusterIP` |
| `service.port`        | service port                                                                                                                     | `80`        |
| `ingress.enabled`     | Enable Ingress for the Linkwarden web UI                                                                                         | `false`     |
| `ingress.className`   | IngressClass that will be used to implement the Ingress                                                                          | `""`        |
| `ingress.annotations` | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. | `{}`        |
| `ingress.tls`         | TLS configuration                                                                                                                | `[]`        |

### General

| Name                         | Description                                                                                                       | Value  |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------------- | ------ |
| `imagePullSecrets`           | Global registry secret names as an array                                                                          | `[]`   |
| `nameOverride`               | String to partially override common.names.fullname                                                                | `""`   |
| `fullnameOverride`           | String to fully override common.names.fullname                                                                    | `""`   |
| `serviceAccount.create`      | Specifies whether a ServiceAccount should be created                                                              | `true` |
| `serviceAccount.automount`   | Automount service account token for the server service account                                                    | `true` |
| `serviceAccount.annotations` | Additional custom annotations for the ServiceAccount                                                              | `{}`   |
| `serviceAccount.name`        | The name of the ServiceAccount to use.                                                                            | `""`   |
| `podAnnotations`             | Annotations for pods                                                                                              | `{}`   |
| `podLabels`                  | Labels for pods                                                                                                   | `{}`   |
| `podSecurityContext`         | podSecurityContext for pods                                                                                       | `{}`   |
| `securityContext`            | securityContext for pods                                                                                          | `{}`   |
| `resources`                  | Set container requests and limits for different resources like CPU or memory (essential for production workloads) | `{}`   |
