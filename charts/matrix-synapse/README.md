# Matrix Synapse Helm Chart [WiP]

This Helm chart deploys a [Matrix Synapse](https://github.com/element-hq/synapse) homeserver instance on a Kubernetes cluster. It supports various configurations, including SQLite and external PostgreSQL databases, and integrates seamlessly with Kubernetes-native resources for high availability and scalability.

## ⚠️ Important Warning - BIG REFACTOR
Please review your values file before updating, we did a complete new chart for refactoring.

## Features

- Flexible database configurations: Supports both SQLite and external PostgreSQL.
- Persistent volume support for media storage.
- Customizable secrets management for secure deployments.
- Integration with external SMTP for email notifications.
- Health checks for liveness and readiness probes.
- Optional Ingress configuration for public access.
- Metrics collection and reporting options.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.7.0+ (for JSON Schema validation)
- PV provisioner for persistent volume support (if enabled)

Installation

## 1. Add the Helm Repository
```shell
helm repo add schoenwald https://charts.schoenwald.aero
helm repo update schoenwald

```
## 2. Install the Chart
```shell
helm install matrix-synapse schoenwald/matrix-synapse --namespace synapse --create-namespace
```
## 3. Provide Custom Values
Create a values.yaml file to override default values:
```yaml
config:
  server:
    server_name: "example.com"
    public_baseurl: "https://example.com/"
sqlite:
  enabled: true
externalPostgresql:
  enabled: false
signingkey:
  job:
    enabled: true
```
Install the chart using the custom values:
```shell
helm install matrix-synapse 0hlov3/matrix-synapse -f values.yaml
```

## Configuration

### Database
You must Choose between SQLite or external PostgreSQL for the database backend. If none is choosen the Chart will fail Enable the desired database in your values.yaml:
#### SQLite
```yaml
sqlite:
  enabled: true
externalPostgresql:
  enabled: false
```
#### External PostgreSQL:
```shell
sqlite:
  enabled: false
externalPostgresql:
  enabled: true
  host: "your-database-host"
  port: 5432
  database: "synapse"
  username: "your-username"
  password: "your-password"
```
### Media Store
Enable persistent storage for media:
```yaml
config:
  mediaStore:
    enable_media_repo: true
    persistence:
      enabled: true
      size: 10Gi
      accessMode: ReadWriteOnce
```
### Secrets
Secure sensitive information such as database credentials and SMTP settings using Kubernetes secrets. Reference existing secrets in your values.yaml:
```yaml
externalPostgresql:
  existingSecret:
    name: "db-credentials"
    keys:
      username: "db-username-key"
      password: "db-password-key"
```

## Create first User
After deploying your Chart you may want to create the first USer/Admin, for theat check the containers in your Release Namespace:
```shell
kubectl get pods -n synapse
```
Exec into the Container
```shell
kubectl exec -n synapse -ti matrix-synapse-* -- /bin/bash
```
Register you first user when you are logged in to your container.
```shell
register_new_matrix_user http://localhost:8008 -c /synapse/config/homeserver.yaml -c /synapse/config/conf.d/secrets.yaml 
```

## ArgoCD
When you are using Argocd it you may should set
```yaml
  ignoreDifferences:
    - group: ""
      kind: Secret
      name: signingkey-matrix-synapse
      jsonPointers:
        - /data
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
      - RespectIgnoreDifferences=true
```

## Parameters

### Synapse Image

| Name               | Description                                     | Value                |
| ------------------ | ----------------------------------------------- | -------------------- |
| `image.registry`   | Global Docker image registry                    | `ghcr.io`            |
| `image.repository` | Global Docker registry secret names as an array | `element-hq/synapse` |
| `image.pullPolicy` | default image pullPolicy                        | `IfNotPresent`       |
| `image.tag`        | default image tag                               | `""`                 |

### Synapse Config

| Name                                                                 | Description                                                                                                                                                                                        | Value           |
| -------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| `config.server.server_name`                                          | This sets the public-facing domain of the server e.g. matrix.org or localhost:8080.                                                                                                                | `""`            |
| `config.server.public_baseurl`                                       | The public-facing base URL that clients use to access this Homeserver (not including _matrix/...). This is the same URL a user might enter into the 'Custom Homeserver URL' field on their client. | `""`            |
| `config.server.web_client_location`                                  | The absolute URL to the web client which / will redirect to. Defaults to none.                                                                                                                     | `""`            |
| `config.server.serve_server_wellknown`                               | By default, other servers will try to reach our server on port 8448, which can be inconvenient in some environments.                                                                               | `false`         |
| `config.server.email.enabled`                                        | Enabled the rendering of the emailconfig                                                                                                                                                           | `false`         |
| `config.server.email.smtp_host`                                      | The hostname of the outgoing SMTP server to use.                                                                                                                                                   | `""`            |
| `config.server.email.smtp_port`                                      | The port on the mail server for outgoing SMTP.                                                                                                                                                     | `""`            |
| `config.server.email.smtp_user`                                      | Username for authentication to the SMTP server                                                                                                                                                     | `""`            |
| `config.server.email.smtp_pass`                                      | password for authentication to the SMTP server                                                                                                                                                     | `""`            |
| `config.server.email.existingSecret.name`                            | the name for the SMTP Secret Configuration                                                                                                                                                         | `""`            |
| `config.server.email.existingSecret.keys.smtp_host`                  | The secret key of the smtp_host overrides smtp_host.                                                                                                                                               | `""`            |
| `config.server.email.existingSecret.keys.smtp_port`                  | The secret key of the smtp_port overrides smtp_port.                                                                                                                                               | `""`            |
| `config.server.email.existingSecret.keys.smtp_user`                  | The secret key of the smtp_user overrides smtp_user.                                                                                                                                               | `""`            |
| `config.server.email.existingSecret.keys.smtp_pass`                  | The secret key of the smtp_pass overrides smtp_pass.                                                                                                                                               | `""`            |
| `config.server.email.force_tls`                                      | By default, Synapse connects over plain text and then optionally upgrades to TLS via STARTTLS.                                                                                                     | `""`            |
| `config.server.email.require_transport_security`                     | Set to true to require TLS transport security for SMTP.                                                                                                                                            | `""`            |
| `config.server.email.enable_tls`                                     | By default, if the server supports TLS, it will be used, and the server must present a certificate that is valid for 'smtp_host'.                                                                  | `""`            |
| `config.server.email.notif_from`                                     | defines the "From" address to use when sending emails. It must be set if email sending is enabled.                                                                                                 | `""`            |
| `config.server.email.enable_notifs`                                  | Set to true to allow users to receive e-mail notifications.                                                                                                                                        | `""`            |
| `config.server.email.client_base_url`                                | Custom URL for client links within the email notifications.                                                                                                                                        | `""`            |
| `config.mediaStore.enable_media_repo`                                | Enable the media store service in the Synapse master. Defaults to true.                                                                                                                            | `true`          |
| `config.mediaStore.persistence.enabled`                              | Enable persistence mediaStore, if false refers to emptyDir (not recommendet).                                                                                                                      | `true`          |
| `config.mediaStore.persistence.size`                                 | Defines the Size of Peristant volume for Media.                                                                                                                                                    | `2Gi`           |
| `config.mediaStore.persistence.accessMode`                           | Enable persistence for SQLite data.                                                                                                                                                                | `ReadWriteOnce` |
| `config.mediaStore.persistence.storageClassName`                     | If empty uses the default storageClass.                                                                                                                                                            | `""`            |
| `config.metrics.enable_metrics`                                      | Set to true to enable collection and rendering of performance metrics. Defaults to false.                                                                                                          | `false`         |
| `config.metrics.report_stats`                                        | Whether or not to report homeserver usage statistics. This is originally set when generating the config.                                                                                           | `false`         |
| `config.metrics.serviceMonitor.enabled`                              | If the serviceMonitor should be deployed.                                                                                                                                                          | `false`         |
| `config.metrics.prometheusRule.enabled`                              | If the PrometheusRule should be deployed.                                                                                                                                                          | `false`         |
| `config.metrics.prometheusRule.rules`                                | Prometheus Rules to deploy.                                                                                                                                                                        | `[]`            |
| `config.registration.enable_registration`                            | Enable registration for new users. Defaults to false.                                                                                                                                              | `false`         |
| `config.registration.enable_registration_without_verification`       | Enable registration without email or captcha verification.                                                                                                                                         | `false`         |
| `config.registration.registration_shared_secret`                     | Enable registration without email or captcha verification.                                                                                                                                         | `""`            |
| `config.registration.existingSecret.name`                            | Enable registration without email or captcha verification.                                                                                                                                         | `""`            |
| `config.registration.existingSecret.keys.registration_shared_secret` | Enable registration without email or captcha verification.                                                                                                                                         | `""`            |
| `config.apiConfiguration.macaroon_secret_key`                        | A secret which is used to sign access token for guest users, short-term login token used during SSO logins (OIDC or SAML2) and token used for unsubscribing from email notifications.              | `""`            |
| `config.apiConfiguration.existingSecret.name`                        |                                                                                                                                                                                                    | `""`            |
| `config.apiConfiguration.existingSecret.keys.macaroon_secret_key`    |                                                                                                                                                                                                    | `""`            |
| `config.signingKeys.trusted_key_servers`                             | The trusted servers to download signing keys from.                                                                                                                                                 | `[]`            |
| `config.signingKeys.suppress_key_server_warning`                     | Set the following to true to disable the warning that is emitted when the trusted_key_servers include 'matrix.org'.                                                                                | `false`         |
| `config.oidc_providers_enabled`                                      | Enables an OIDC Providor config [#synapse-oidc-config](synapse-oidc-config)                                                                                                                        | `false`         |
| `config.oidc_providers`                                              | Configures an OIDC Providor [#synapse-oidc-config](synapse-oidc-config)                                                                                                                            | `[]`            |
| `extraListeners`                                                     | Configure Extra listeners if needed.                                                                                                                                                               | `[]`            |
| `extraConfig`                                                        | Provide custom Synapse configurations in this section.                                                                                                                                             | `{}`            |
| `extraCommands`                                                      | Extra commands to run when starting Synapse                                                                                                                                                        | `[]`            |

### Synapse Log Config

| Name                             | Description                             | Value   |
| -------------------------------- | --------------------------------------- | ------- |
| `logConfig.useStructuredLogging` | If Synapseshould use structured logging | `false` |
| `logConfig.logLevel`             | The Loglevel of Synapse                 | `INFO`  |
| `logConfig.extraLoggers`         | Configure extra loggers                 | `{}`    |

### Synapse Database Configuration

| Name                                              | Description                                                                        | Value                                     |
| ------------------------------------------------- | ---------------------------------------------------------------------------------- | ----------------------------------------- |
| `sqlite.enabled`                                  | Enable SQLite as the database backend.                                             | `false`                                   |
| `sqlite.persistence.enabled`                      | Enable persistence for SQLite data, if false refers to emptyDir (not recommendet). | `true`                                    |
| `sqlite.persistence.size`                         | Persistent Volume size for SQLite data.                                            | `2Gi`                                     |
| `sqlite.persistence.accessMode`                   | Access mode for the Persistent Volume.                                             | `ReadWriteOnce`                           |
| `sqlite.persistence.storageClassName`             | If empty uses the default storageClass.                                            | `""`                                      |
| `externalPostgresql.enabled`                      | Enable external PostgreSQL as the database backend.                                | `false`                                   |
| `externalPostgresql.host`                         | Hostname of the external PostgreSQL database.                                      | `postgresql.postgresql.svc.cluster.local` |
| `externalPostgresql.port`                         | Port for the external PostgreSQL database.                                         | `5432`                                    |
| `externalPostgresql.database`                     | Name of the database to use.                                                       | `synapse`                                 |
| `externalPostgresql.username`                     | Username of the database to use.                                                   | `""`                                      |
| `externalPostgresql.password`                     | Password of the database to use.                                                   | `""`                                      |
| `externalPostgresql.existingSecret.name`          | Name of an existing Kubernetes secret containing database credentials.             | `""`                                      |
| `externalPostgresql.existingSecret.keys.host`     | Key for the host in the existing secret.                                           | `""`                                      |
| `externalPostgresql.existingSecret.keys.port`     | Key for the port in the existing secret.                                           | `""`                                      |
| `externalPostgresql.existingSecret.keys.database` | Key for the port in the existing secret.                                           | `""`                                      |
| `externalPostgresql.existingSecret.keys.username` | Key for the username in the existing secret.                                       | `""`                                      |
| `externalPostgresql.existingSecret.keys.password` | Key for the password in the existing secret.                                       | `""`                                      |

### Redis/Dragonfly WiP Don't USE right NOW!

| Name                | Description                                                  | Value   |
| ------------------- | ------------------------------------------------------------ | ------- |
| `dragonfly.enabled` | Enables Deployment of dragonflyDB as Redis replacement [WiP] | `false` |

### General

| Name                                | Description                                                                                                                      | Value       |
| ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| `imagePullSecrets`                  | Global registry secret names as an array                                                                                         | `[]`        |
| `nameOverride`                      | String to partially override common.names.fullname                                                                               | `""`        |
| `fullnameOverride`                  | String to fully override common.names.fullname                                                                                   | `""`        |
| `serviceAccount.create`             | Specifies whether a ServiceAccount should be created                                                                             | `true`      |
| `serviceAccount.automount`          | Automount service account token for the server service account                                                                   | `false`     |
| `serviceAccount.annotations`        | Additional custom annotations for the ServiceAccount                                                                             | `{}`        |
| `serviceAccount.name`               | The name of the ServiceAccount to use.                                                                                           | `""`        |
| `podAnnotations`                    | Annotations for pods                                                                                                             | `{}`        |
| `podLabels`                         | Labels for pods                                                                                                                  | `{}`        |
| `podSecurityContext.fsGroup`        | Set pod's Security Context fsGroup                                                                                               | `1000`      |
| `podSecurityContext.runAsGroup`     | Set pod's Security Context runAsGroup                                                                                            | `1000`      |
| `podSecurityContext.runAsUser`      | Set pod's Security Context runAsUser                                                                                             | `1000`      |
| `securityContext.capabilities.drop` | List of capabilities to be dropped                                                                                               | `["ALL"]`   |
| `securityContext.runAsNonRoot`      | Set containers Security Context runAsNonRoot                                                                                     | `true`      |
| `securityContext.runAsUser`         | Set containers Security Context runAsUser                                                                                        | `1000`      |
| `service.type`                      | Sets the Service Type.                                                                                                           | `ClusterIP` |
| `service.port`                      | Sets the Service port.                                                                                                           | `8008`      |
| `ingress.enabled`                   | Enable ingress record generation for Keycloak                                                                                    | `false`     |
| `ingress.className`                 | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+)                                                    | `""`        |
| `ingress.annotations`               | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. | `{}`        |
| `ingress.tls`                       | Enable TLS configuration for the hostname defined at ingress.hostname parameter                                                  | `[]`        |
| `resources`                         | Set container requests and limits for different resources like CPU or memory (essential for production workloads) 	{}            | `{}`        |

### Synapse signing Key config

| Name                                         | Description                                                   | Value             |
| -------------------------------------------- | ------------------------------------------------------------- | ----------------- |
| `signingkey.job.enabled`                     | Enables the signinkeyjob to create a SigningKey if nor exists | `false`           |
| `signingkey.job.storeSecretImage.registry`   | The Kubectl Image Registry to for storing the singinKey       | `docker.io`       |
| `signingkey.job.storeSecretImage.repository` | The Kubectl Image Rposiory to for storing the singinKey       | `bitnami/kubectl` |
| `signingkey.job.storeSecretImage.tag`        | The Kubectl Image Tag to for storing the singinKey            | `latest`          |
| `signingkey.job.storeSecretImage.pullPolicy` | The Kubectl Image pullPolicy                                  | `IfNotPresent`    |
| `signingkey.existingSecret`                  | The Secret of the SinginKey if Exists                         | `""`              |
| `signingkey.existingSecretKey`               | The Secret Key of the SinginKey where the key is stored       | `""`              |
| `signingkey.resources`                       | Resources of the SigningKeyJob Containers                     | `{}`              |

## Synapse OIDC Config
This Helm chart supports configuring OpenID Connect (OIDC) providers for authentication in a Synapse server. This allows users to log in using identity providers such as Zitadel, Keycloak, or any other OIDC-compliant provider.

### Prerequisites
Before enabling OIDC authentication, ensure the following:

- You have a running Synapse instance deployed using Helm.
- Your OIDC provider (e.g., Zitadel, Keycloak) is properly configured.
- A Kubernetes Secret exists to securely store the client_id and client_secret for OIDC authentication.

### 1. Create a Kubernetes Secret
Since OIDC providers require client credentials, create a Kubernetes Secret to store them securely:
```shell
kubectl create secret generic oauth-provider1-secret  --from-literal clientId="my_cliend_id" --from-literal clientSecret="my-client-secret"
```
Replace `"my_client_id"` and `"my_client_secret"` with your actual OIDC credentials.

### Explanation of Configuration Fields
```yaml
  oidc_providers_enabled: true
  oidc_providers:
    - idp_id: zitadel
      idp_name: zitadel
      discover: true
      issuer: "https://<your-issuer-domain>"
      scopes:
        - "openid"
        - "profile"
        - "email"
      allow_existing_users: "true"
      user_mapping_provider:
        config:
          localpart_template: "{{ user.preferred_username }}"
          display_name_template: "{{ user.preferred_username }}"
      existingSecretName: "oauth-provider1-secret"
      extra_oidc_provider_config: {}
```
| Parameter                  | Description                                                                                                                                                       |
|----------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| oidc_providers_enabled     | Enables OIDC authentication in Synapse.                                                                                                                           |
| oidc_providers             | Defines a list of OIDC providers for authentication.                                                                                                              |
| idp_id                     | Unique identifier for the OIDC provider (e.g., zitadel).                                                                                                          |
| idp_name                   | Display name for the provider in Synapse.                                                                                                                         |
| discover                   | If true, Synapse will use discovery (.well-known/openid-configuration) for OIDC settings.                                                                         |
| issuer                     | The OIDC provider’s issuer URL (replace with your actual OIDC provider URL).                                                                                      |
| scopes                     | list of scopes to request. This should normally include the "openid" scope                                                                                        |
| allow_existing_users       | set to true to allow a user logging in via OIDC to match a pre-existing account instead of failing. This could be used if switching from password logins to OIDC. |
| existingSecretName         | The name of the Kubernetes Secret storing the client_id and client_secret.                                                                                        |
| extra_oidc_provider_config | Allows additional OIDC provider-specific configurations if needed.                                                                                                |

### OIDC Callback URL
Once deployed, you need to configure your OIDC provider (e.g., Zitadel, Keycloak) to allow authentication callbacks from Synapse.

Use the following callback URL format:
```shell
https://<your-synapse-domain>/_synapse/client/oidc/callback
```
For example:
```shell
https://auth.your-synapse.com/_synapse/client/oidc/callback
```
Make sure to update the redirect URIs in your OIDC provider’s settings to match this format.
