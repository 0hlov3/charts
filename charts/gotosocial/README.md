# GoToSocial HELM Chart

This Helm chart deploys GoToSocial, a lightweight and privacy-focused social network server. It provides customization options for persistence, database configuration, and scaling.

## ⚠️ Important Warning

If PostgreSQL or external database is not enabled, SQLite is used by default. In this scenario, it is critical to back up your instance key before recreating the pod, as the instance key is tied to the database. Failure to do so may result in data loss and federation issues.

## Deployment Steps
### Create Namespace
```shell
kubectl create ns gts-test
```
### Create a PostgreSQL-Secret
```shell
kubectl create secret generic gts-postgresql-secret \
  --from-literal="password=$(openssl rand -hex 32)" \
  --from-literal="postgres-password=$(openssl rand -hex 32)" \
  -n gts-test
```
### Deploy Helm Chart
```shell
helm repo add schoenwald https://charts.schoenwald.aero
helm repo update schoenwald
helm upgrade --install gotosocial schoenwald/gotosocial \
  --namespace gotosocial --create-namespace \
  --set gotosocial.config.host='domain.tld' \
  --set gotosocial.config.accountDomain='domain.tld'
```
## Create First User
```shell
kubectl exec -ti $CONTAINER_ID -- /gotosocial/gotosocial --config-path /config/config.yaml admin account create --username $USERNAME --email $USER_EMAIL --password $USER_PASS
```

```shell
kubectl exec -ti $CONTAINER_ID -- /gotosocial/gotosocial --config-path /config/config.yaml admin account confirm --username $USERNAME
```

```shell
kubectl exec -ti $CONTAINER_ID -- /gotosocial/gotosocial --config-path /config/config.yaml admin account promote --username $USERNAME
```

## Known Limitations
### Rate Limiting

If your GoToSocial instance frequently exceeds rate limits, it may be due to NAT or load balancers that do not preserve client IPs. In such cases, all incoming requests are seen as originating from the same IP, causing rate limiting issues. For detailed information, refer to the [official documentation](https://docs.gotosocial.org/en/latest/api/ratelimiting/).

#### Solution

1. **Preserve Source IPs (Kubernetes):**  
   When using a `LoadBalancer` or `NodePort` service type, set `externalTrafficPolicy` to `Local` in your Service specification to preserve client IPs:

   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: gotosocial
   spec:
     type: LoadBalancer
     externalTrafficPolicy: Local
   ```

2. Disable Rate Limiting (if IP preservation is not possible):
   If client IPs cannot be preserved due to NAT, disable rate limiting by adding the following to your Helm values:

   ```yaml
   gotosocial:
     extraConfig:
       advanced-rate-limit-requests: 0
   ```

## Parameters

### GoToSocial parameters

| Name                                                     | Description                                                                                                                                  | Value                                                   |
| -------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| `image.registry`                                         | GoToSocial image registry                                                                                                                    | `docker.io`                                             |
| `image.repository`                                       | GoToSocial image repository                                                                                                                  | `superseriousbusiness/gotosocial`                       |
| `image.pullPolicy`                                       | GoToSocial image pull policy                                                                                                                 | `Always`                                                |
| `imagePullSecrets`                                       | GoToSocial image pull secrets                                                                                                                | `[]`                                                    |
| `gotosocial.strategy.type`                               | GoToSocial deployment strategy type, should be Recreate if ReadWriteMany not enabled.                                                        | `Recreate`                                              |
| `gotosocial.persistence.enabled`                         | Enable persistence using a PersistentVolumeClaim                                                                                             | `false`                                                 |
| `gotosocial.persistence.accessMode`                      | Persistent Volume Access Modes                                                                                                               | `ReadWriteOnce`                                         |
| `gotosocial.persistence.size`                            | Persistent Volume Size                                                                                                                       | `10Gi`                                                  |
| `gotosocial.persistence.existingClaim`                   | use an existing persistent volume claim instead of creating one                                                                              | `""`                                                    |
| `gotosocial.tmpfs.enabled`                               | Enable tmpfs using an emptyDir                                                                                                               | `false`                                                 |
| `gotosocial.tmpfs.size`                                  | emptyDir Size                                                                                                                                | `1Gi`                                                   |
| `gotosocial.extraEnv`                                    | additional environment variables to pass to the gotosocial deployment                                                                        | `[]`                                                    |
| `gotosocial.extraVolumes`                                | additional volumes to pass to the gotosocial deployment                                                                                      | `[]`                                                    |
| `gotosocial.extraVolumeMounts`                           | additional volume mounts to pass to the gotosocial deployment                                                                                | `[]`                                                    |
| `gotosocial.config.applicationName`                      | Application name to use internally.                                                                                                          | `gotosocial`                                            |
| `gotosocial.config.host`                                 | Hostname that this server will be reachable at.                                                                                              | `""`                                                    |
| `gotosocial.config.accountDomain`                        | Domain to use when federating profiles.                                                                                                      | `""`                                                    |
| `gotosocial.config.protocol`                             | Protocol over which the server is reachable from the outside world.                                                                          | `https`                                                 |
| `gotosocial.config.bindAddress`                          | Address to bind the GoToSocial server to.                                                                                                    | `0.0.0.0`                                               |
| `gotosocial.config.trustedProxies`                       | Array of string. CIDRs or IP addresses of proxies that should be trusted when determining real client IP from behind a reverse proxy.        | `["::1","10.0.0.0/8","172.16.0.0/12","192.168.0.0/16"]` |
| `gotosocial.config.db.maxOpenConnsMultiplier`            | Number to multiply by CPU count to set permitted total of open database connections (in-use and idle).                                       | `8`                                                     |
| `gotosocial.config.db.cache.memoryTarget`                | cache.memory-target sets a target limit that the application will try to keep it's caches within.                                            | `100MiB`                                                |
| `gotosocial.config.storage.backend`                      | Type of storage backend to use.                                                                                                              | `local`                                                 |
| `gotosocial.config.storage.localBasePath`                | Directory to use as a base path for storing files.                                                                                           | `/gotosocial/storage`                                   |
| `gotosocial.config.storage.s3.enabled`                   | Enables s3 support in Config                                                                                                                 | `false`                                                 |
| `gotosocial.config.storage.s3.endpoint`                  | API endpoint of the S3 compatible service.                                                                                                   | `""`                                                    |
| `gotosocial.config.storage.s3.proxy`                     | Set this to true if data stored in S3 should be proxied through GoToSocial instead of forwarding the request to a presigned URL.             | `false`                                                 |
| `gotosocial.config.storage.s3.useSSL`                    | Use SSL for S3 connections.                                                                                                                  | `true`                                                  |
| `gotosocial.config.storage.s3.accessKey`                 | Access key part of the S3 credentials.                                                                                                       | `""`                                                    |
| `gotosocial.config.storage.s3.secretKey`                 | Secret key part of the S3 credentials.                                                                                                       | `""`                                                    |
| `gotosocial.config.storage.s3.existingSecret`            | If this is set, accessKey, secretKey will not take place, Needs the S3_ACCESS_KEY_ID and S3_SECRET_ACCESS_KEY keys.                          | `""`                                                    |
| `gotosocial.config.storage.s3.bucket`                    | Name of the storage bucket.                                                                                                                  | `""`                                                    |
| `gotosocial.config.oidc.enabled`                         | Enable authentication with external OIDC provider.                                                                                           | `false`                                                 |
| `gotosocial.config.oidc.idpName`                         | Name of the oidc idp (identity provider). This will be shown to users when they log in.                                                      | `""`                                                    |
| `gotosocial.config.oidc.skipVerification`                | Skip the normal verification flow of tokens returned from the OIDC provider, ie., don't check the expiry or signature.                       | `""`                                                    |
| `gotosocial.config.oidc.issuer`                          | The OIDC issuer URI. This is where GtS will redirect users to for login.                                                                     | `""`                                                    |
| `gotosocial.config.oidc.clientID`                        | The ID for this client as registered with the OIDC provider.                                                                                 | `""`                                                    |
| `gotosocial.config.oidc.clientSecret`                    | The secret for this client as registered with the OIDC provider.                                                                             | `""`                                                    |
| `gotosocial.config.oidc.oidcScopes`                      | Scopes to request from the OIDC provider.                                                                                                    | `["openid","email","profile","groups"]`                 |
| `gotosocial.config.oidc.linkExisting`                    | Link OIDC authenticated users to existing ones based on their email address.                                                                 | `false`                                                 |
| `gotosocial.config.oidc.adminGroups`                     | If the returned ID token contains a 'groups' claim that matches one of the groups in oidc-admin-groups ...                                   | `[]`                                                    |
| `gotosocial.config.oidc.existingSecretName`              | Use an existing kubernetes Secret for issuer, clientID, and clientSecret. If set, ignores oidc.issuer, odic.clientID, and oidc.clientSecret. | `""`                                                    |
| `gotosocial.config.oidc.existingSecretKeys.issuer`       | The secretKey for the issuer.                                                                                                                | `""`                                                    |
| `gotosocial.config.oidc.existingSecretKeys.clientID`     | The secretKey for the clientID.                                                                                                              | `""`                                                    |
| `gotosocial.config.oidc.existingSecretKeys.clientSecret` | The secretKey for the clientSecret.                                                                                                          | `""`                                                    |
| `gotosocial.config.smtp.host`                            | The hostname of the smtp server you want to use.                                                                                             | `""`                                                    |
| `gotosocial.config.smtp.port`                            | Port to use to connect to the smtp server.                                                                                                   | `""`                                                    |
| `gotosocial.config.smtp.userName`                        | Username to use when authenticating with the smtp server.                                                                                    | `""`                                                    |
| `gotosocial.config.smtp.password`                        | Password to use when authenticating with the smtp server.                                                                                    | `""`                                                    |
| `gotosocial.config.smtp.existingSecretName`              | Existing Secret for the gotosocial.smtp.password (e.g. gts-smtp-secret)                                                                      | `""`                                                    |
| `gotosocial.config.smtp.existingSecretKeys.host`         | The key in the specified Secret containing the SMTP server hostname.                                                                         | `""`                                                    |
| `gotosocial.config.smtp.existingSecretKeys.port`         | The key in the specified Secret containing the SMTP server port.                                                                             | `""`                                                    |
| `gotosocial.config.smtp.existingSecretKeys.username`     | The key in the specified Secret containing the username for SMTP authentication.                                                             | `""`                                                    |
| `gotosocial.config.smtp.existingSecretKeys.password`     | The key in the specified Secret containing the password for SMTP authentication.                                                             | `""`                                                    |
| `gotosocial.config.smtp.from`                            | From address for sent emails.                                                                                                                | `""`                                                    |
| `gotosocial.config.smtp.discloseRecipients`              | If true, when an email is sent that has multiple recipients, each recipient...                                                               | `false`                                                 |
| `gotosocial.extraConfig`                                 | Set ExtraConfig from [gotosocial/config.yaml](https://github.com/superseriousbusiness/gotosocial/blob/main/example/config.yaml) here.        | `nil`                                                   |
| `initContainers`                                         | Add additional init containers                                                                                                               | `[]`                                                    |
| `resources.limits.cpu`                                   | Set container limits for CPU.                                                                                                                | `500m`                                                  |
| `resources.limits.memory`                                | Set container limits for memory.                                                                                                             | `512Mi`                                                 |
| `resources.requests.cpu`                                 | Set container requests for CPU.                                                                                                              | `500m`                                                  |
| `resources.requests.memory`                              | Set container requests for memory.                                                                                                           | `512Mi`                                                 |
| `serviceAccount.create`                                  | whether a service account should be created                                                                                                  | `true`                                                  |
| `serviceAccount.annotations`                             | Annotations to add to the service account                                                                                                    | `{}`                                                    |
| `serviceAccount.name`                                    | The name of the service account to use, if not set and create is true, a name is generated using the fullname template                       | `""`                                                    |
| `podAnnotations`                                         | Pod annotations                                                                                                                              | `{}`                                                    |
| `podSecurityContext.runAsUser`                           | Security Context runAsUser                                                                                                                   | `1000`                                                  |
| `podSecurityContext.runAsGroup`                          | Security Context runAsGroup                                                                                                                  | `1000`                                                  |
| `podSecurityContext.fsGroup`                             | Security Context fsGroup                                                                                                                     | `1000`                                                  |
| `securityContext.capabilities.drop`                      | List of capabilities to be dropped                                                                                                           | `["ALL"]`                                               |
| `securityContext.readOnlyRootFilesystem`                 | Set primary container's Security Context readOnlyRootFilesystem                                                                              | `true`                                                  |
| `securityContext.allowPrivilegeEscalation`               | Set primary container's Security Context allowPrivilegeEscalation                                                                            | `false`                                                 |
| `securityContext.runAsNonRoot`                           | Set Controller container's Security Context runAsNonRoot                                                                                     | `true`                                                  |
| `securityContext.runAsUser`                              | Security Context runAsUser                                                                                                                   | `1000`                                                  |
| `securityContext.runAsGroup`                             | Security Context runAsGroup                                                                                                                  | `1000`                                                  |
| `startupProbe.httpGet.path`                              | Path to access on the HTTP server                                                                                                            | `/livez`                                                |
| `startupProbe.httpGet.port`                              | Port for startupProbe                                                                                                                        | `http`                                                  |
| `startupProbe.failureThreshold`                          | Failure threshold for startupProbe                                                                                                           | `60`                                                    |
| `startupProbe.periodSeconds`                             | Period seconds for startupProbe                                                                                                              | `10`                                                    |
| `startupProbe.initialDelaySeconds`                       | ensures probes don't start prematurely.                                                                                                      | `5`                                                     |
| `livenessProbe.httpGet.path`                             | Path to access on the HTTP server                                                                                                            | `/livez`                                                |
| `livenessProbe.httpGet.port`                             | Port for livenessProbe                                                                                                                       | `http`                                                  |
| `livenessProbe.failureThreshold`                         | Failure threshold for livenessProbe                                                                                                          | `2`                                                     |
| `livenessProbe.periodSeconds`                            | Period seconds for livenessProbe, Default: Check every 30 seconds to reduce overhead                                                         | `30`                                                    |
| `readinessProbe.httpGet.path`                            | Path to access on the HTTP server                                                                                                            | `/readyz`                                               |
| `readinessProbe.httpGet.port`                            | Port for readinessProbe                                                                                                                      | `http`                                                  |
| `readinessProbe.failureThreshold`                        | Failure threshold for readinessProbe                                                                                                         | `5`                                                     |
| `readinessProbe.periodSeconds`                           | Period seconds for readinessProbe, Default: Check every 10 seconds for readiness                                                             | `10`                                                    |

### Traffic Exposure Parameters

| Name                  | Description                                                                                                                      | Value       |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| `service.type`        | GoToSocial Service type                                                                                                          | `ClusterIP` |
| `service.port`        | GoToSocial service port                                                                                                          | `8080`      |
| `ingress.enabled`     | Enable ingress record generation for GoToSocial                                                                                  | `false`     |
| `ingress.className`   | IngressClass that will be used to implement the Ingress                                                                          | `""`        |
| `ingress.annotations` | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. | `{}`        |
| `ingress.tls`         | TLS configuration                                                                                                                | `[]`        |

### Database Config

| Name                                           | Description                                                                                       | Value                           |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------- | ------------------------------- |
| `postgresql.enabled`                           | Enables Deployment of an old Bitnami PostgreSQL Chart (deprecated)                                | `false`                         |
| `postgresql.image.pullPolicy`                  | Enables Deployment of an old Bitnami PostgreSQL Chart (deprecated)                                | `Always`                        |
| `postgresql.auth.username`                     | Name for a custom user to create                                                                  | `gotosocial`                    |
| `postgresql.auth.database`                     | Name for a custom database to create                                                              | `gotosocial`                    |
| `postgresql.auth.existingSecret`               | Name of existing secret to use for PostgreSQL credentials                                         | `gts-postgresql-secret`         |
| `externalPostgresql.enabled`                   | Enables externalPostgresql.                                                                       | `false`                         |
| `externalPostgresql.host`                      | Database host                                                                                     | `postgres.postgres.svc.local`   |
| `externalPostgresql.port`                      | Database port number                                                                              | `5432`                          |
| `externalPostgresql.username`                  | Non-root username for GoToSocial                                                                  | `""`                            |
| `externalPostgresql.password`                  | Password for the non-root username for GoToSocial                                                 | `""`                            |
| `externalPostgresql.existingSecret`            | Name of an existing secret resource containing the database credentials                           | `""`                            |
| `externalPostgresql.existingSecretPasswordKey` | Name of an existing secret key containing the database credentials                                | `postgres-password`             |
| `externalPostgresql.tls_mode`                  | TLS Mode                                                                                          | `disable`                       |
| `externalPostgresql.ca_cert`                   | CA Cert to use when tls mode is in required state                                                 | `""`                            |
| `externalPostgresql.database`                  | GoToSocial database name                                                                          | `GoToSocial`                    |
| `sqLite.address`                               | For Sqlite, this should be the path to your sqlite database file. Eg., /opt/gotosocial/sqlite.db. | `/gotosocial/storage/sqlite.db` |
| `sqLite.journalMode`                           | SQLite journaling mode                                                                            | `WAL`                           |
| `sqLite.synchronous`                           | SQLite synchronous mode.                                                                          | `NORMAL`                        |
| `sqLite.cacheSize`                             | SQlite cache size.                                                                                | `8MiB`                          |
| `sqLite.busyTimeout`                           | SQlite busy timeout.                                                                              | `30m`                           |

### Additional Config

| Name               | Description                                        | Value |
| ------------------ | -------------------------------------------------- | ----- |
| `nameOverride`     | String to partially override common.names.fullname | `""`  |
| `fullnameOverride` | String to fully override common.names.fullname     | `""`  |
| `nodeSelector`     | Node labels for pod assignment                     | `{}`  |
| `tolerations`      | Tolerations for pod assignment                     | `[]`  |
| `affinity`         | Affinity for pod assignment                        | `{}`  |
