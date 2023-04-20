# GoToSocial HELM Chart

## Deployment
### Create Namespace
```shell
kubectl create ns gts-test
```
### Create a PostgreSQL-Secret
```shell
kubectl create secret generic gts-postgresql-secret --from-literal="password=$(openssl rand -hex 32)" --from-literal="postgres-password=$(openssl rand -hex 32)" -n gts-test
```
### Deploy Helm Chart
```shell
helm repo add maxxblow https://maxxblow.de/charts
helm repo update
helm upgrade --install gotosocial maxxblow/gotosocial --namespace gotosocial --create-namespace --set gotosocial.config.host='domain.tld' --set gotosocial.config.accountDomain='domain.tld'
```
## Create first User
```shell
kubectl exec -ti $CONTAINER_ID -- /gotosocial/gotosocial --config-path /config/config.yaml admin account create --username $USERNAME --email $USER_EMAIL --password $USER_PASS
```

```shell
kubectl exec -ti $CONTAINER_ID -- /gotosocial/gotosocial --config-path /config/config.yaml admin account confirm --username $USERNAME
```

```shell
kubectl exec -ti $CONTAINER_ID -- /gotosocial/gotosocial --config-path /config/config.yaml admin account promote --username $USERNAME
```

## General Parameters (WIP)
| Name                                                       | Description                                                                                                                                                                           | Value |
| ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| gotosocial.config.logLevel                                 | String. Log level to use throughout the application. Must be lower-case. | "info" |
| gotosocial.config.logDBQueries                             | Bool. Log database queries when log-level is set to debug or trace. | false |
| gotosocial.config.applicationName                          |  Application name to use internally. | "gotosocial" |
| gotosocial.config.landingPageUser                          | String. The user that will be shown instead of the landing page. if no user is set, the landing page will be shown. | "" |
| gotosocial.config.host                                     | String. Hostname that this server will be reachable at. Defaults to localhost for local testing, but you should *definitely* change this when running for real, or your server won't work at all. DO NOT change this after your server has already run once, or you will break things! | "localhost" |
| gotosocial.config.accountDomain                            | String. Domain to use when federating profiles. | "" |
| gotosocial.config.protocol                                 | String. Protocol to use for the server. Only change to http for local testing! | "https" |
| Values.gotosocial.config.bindAddress                       | String. Address to bind the GoToSocial server to. | "0.0.0.0" |
| service.port                                               | Int. Listen port for the GoToSocial webserver + API | 8080 |
| gotosocial.config.trustedProxies                           | Array of string. CIDRs or IP addresses of proxies that should be trusted when determining real client IP from behind a reverse proxy. | ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"] |

## Storage Parameters
| Name                                                       | Description                                                                                                                                                                           | Value |
| ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| gotosocial.persistence.enabled | Enabeles GoToSocial data persistence using PVC (should be set to true) | false |
| gotosocial.persistence.accessMode | PVC Access Mode for GoToSocial volume | "ReadWriteOnce" |
| gotosocial.persistence.size | PVC Storage Request for GoToSocial volume | "10Gi" |
| gotosocial.persistence.storageClass | PVC Storage Class for GoToSocial Primary data volume | "" |
## DATABASE CONFIG Parameters

### Global Database Options
| Name                                                       | Description                                                                                                                                                                           | Value |
| ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| gotosocial.config.db.cache.enabled | | true |
| gotosocial.config.db.cache.gts.accountMaxSize | | 100 |
| gotosocial.config.db.cache.gts.accountTTl | | "5m" |
| gotosocial.config.db.cache.gts.accountSweepFreq | | "10s" |
| gotosocial.config.db.cache.gts.blockMaxSize | | 100 |
| gotosocial.config.db.cache.gts.blockTTl | | "5m" |
| gotosocial.config.db.cache.gts.blockSweepFreq | | "10s" |
| gotosocial.config.db.cache.gts.domainBlockMaxSize | | 1000 |
| gotosocial.config.db.cache.gts.domainBlockTTl | | "24h" |
| gotosocial.config.db.cache.gts.domainBlockSweepFreq | | "1m" |
| gotosocial.config.db.cache.gts.emojiMaxSize | | 500 |
| gotosocial.config.db.cache.gts.emojiTTl | | "5m" |
| gotosocial.config.db.cache.gts.emojiSweepFreq | | "10s" |
| gotosocial.config.db.cache.gts.emojiCategoryMaxSize | | 100 |
| gotosocial.config.db.cache.gts.emojiCategoryTTl | | "5m" |
| gotosocial.config.db.cache.gts.emojiCategorySweepFreq | | "10s" |
| gotosocial.config.db.cache.gts.mentionMaxSize | | 500 |
| gotosocial.config.db.cache.gts.mentionTTl | | "5m" |
| gotosocial.config.db.cache.gts.mentionSweepFreq | | "10s" |
| gotosocial.config.db.cache.gts.notificationMaxSize | | 500 |
| gotosocial.config.db.cache.gts.notificationTTl | | "5m" |
| gotosocial.config.db.cache.gts.notificationSweepFreq | | "10s" |
| gotosocial.config.db.cache.gts.statusMaxSize | | 500 |
| gotosocial.config.db.cache.gts.statusTTl | | "5m" |
| gotosocial.config.db.cache.gts.statusSweepFreq | | "10s" |
| gotosocial.config.db.cache.gts.tombstoneMaxSize | | 100 |
| gotosocial.config.db.cache.gts.tombstoneTTl | | "5m" |
| gotosocial.config.db.cache.gts.tombstoneSweepFreq | | "10s" |
| gotosocial.config.db.cache.gts.userMaxSize | | 100 |
| gotosocial.config.db.cache.gts.userTTl | | "5m" |
| gotosocial.config.db.cache.gts.userSweepFreq | | "10s" |

### Postgres Packeged by Bitnami
If this is enabled, it will override the External Postgres and SQLite options.
| Name                                                       | Description                                                                                                                                                                           | Value |
| ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| postgresql.enabled | Enabled [Postgres Packaged by Bitnami](https://github.com/bitnami/charts/tree/main/bitnami/postgresql) | true |
| postgresql.image.pullPolicy| PostgreSQL image pull policy | Always |
| postgresql.auth.username | Name for a custom user to create | "gotosocial" |
| postgresql.auth.database | Name for a custom database to create | "gotosocial" |
| postgresql.auth.existingSecret | Name of existing secret to use for PostgreSQL credentials. auth.postgresPassword, auth.password, and auth.replicationPassword will be ignored and picked up from this secret. The secret might also contains the key ldap-password if LDAP is enabled. ldap.bind_password will be ignored and picked from this secret in this case. | gts-postgresql-secret |
| postgresql.auth.password | Password for the custom user to create. Ignored if auth.existingSecret with key password is provided | "" |
| postgresql.primary.persistence.enabled | Enable PostgreSQL Primary data persistence using PVC | true |
| postgresql.primary.persistence.size | PVC Storage Request for PostgreSQL volume | 10Gi |
| postgresql.primary.resources.requests.cpu | The requested cpu for the PostgreSQL Primary containers | 100 |
| postgresql.primary.resources.requests.memory | The requested memory for the PostgreSQL Primary containers | 128Mi |
| postgresql.primary.resources.limits.cpu | The limits cpu for the PostgreSQL Primary containers | 250 |
| postgresql.primary.resources.limits.memory | The limits memory for the PostgreSQL Primary containers | 512Mi |
| postgresql.volumePermissions | Enable init container that changes the owner and group of the persistent volume | false |

You can find other config Options in the Bitnami Chart for Postgresql [https://github.com/bitnami/charts/tree/main/bitnami/postgresql](https://github.com/bitnami/charts/tree/main/bitnami/postgresql)

### External Postgres
If this is enabled and `postgresql.enabled` is disabled, it will override the SQLite options.
| Name                                                       | Description                                                                                                                                                                           | Value |
| ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| externalPostgresql.enabled | Enables external Postgres access | false |
| externalPostgresql.host | String. Database address or parameters. | "" |
| externalPostgresql.port | Int. Port for database connection. | 5432 |
| externalPostgresql.username | String. Username for the database connection. | "" |
| externalPostgresql.database | String. Name of the database to use within the provided database type. | "" |
| externalPostgresql.tls_mode | String. Disable, enable, or require SSL/TLS connection to the database | "disable" |
| externalPostgresql.ca_cert | String. Path to a CA certificate on the host machine for db certificate validation. | "" |
| externalPostgresql.password | String. Password to use for the database connection | "" |
| externalPostgresql.existingSecret | | "" |
| externalPostgresql.existingSecretPasswordKey | "" |

### sqlite
If this is enabled and `postgresql.enabled` and `externalPostgresql.enabled` are disabled, it will override the SQLite options.
| Name                                                       | Description                                                                                                                                                                           | Value |
| ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| gotosocial.config.db.sqlite_address | String. Database address or parameters. | "/gotosocial/storage/sqlite.db" |
## WEB CONFIG Parameters
| Name                                                       | Description                                                                                                                                                                           | Value |
| ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| gotosocial.config.web.templateBaseDir | String. Directory from which gotosocial will attempt to load html templates (.tmpl files) | "./web/template/" |
| gotosocial.config.web.assetBaseDir | String. Directory from which gotosocial will attempt to serve static web assets (images, scripts). | "./web/assets/" |

## INSTANCE CONFIG Parameters
| Name                                                       | Description                                                                                                                                                                           | Value |
| ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| gotosocial.config.instance.instanceExposePeers          | Bool. Allow unauthenticated users to make queries to /api/v1/instance/peers?filter=open | false |
| gotosocial.config.instance.instanceExposeSuspended      | Bool. Allow unauthenticated users to make queries to /api/v1/instance/peers?filter=suspended | false |
| gotosocial.config.instance.instanceExposePublicTimeline | Bool. Allow unauthenticated users to make queries to /api/v1/timelines/public | false |
| gotosocial.config.web.instanceDeliverToSharedInboxes    | Bool. This flag tweaks whether GoToSocial will deliver ActivityPub messages | true |

## MEDIA CONFIG Parameters
| Name                                                       | Description                                                                                                                                                                           | Value |
| ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| gotosocial.config.media.imageMaxSize | Int. Maximum allowed image upload size in bytes. | 10485760 |
| gotosocial.config.media.videoMaxSize | Int. Maximum allowed video upload size in bytes. | 41943040 |
| gotosocial.config.media.descriptionMinChars | Int. Minimum amount of characters required as an image or video description. | 0 |
| gotosocial.config.media.descriptionMaxChars | Int. Maximum amount of characters permitted in an image or video description. | 500 |
| gotosocial.config.media.mediaRemoteCacheDays | Int. Number of days to cache media from remote instances before they are removed from the cache. | 30 |
| gotosocial.config.media.emojiLocalMaxSize | Int. Max size in bytes of emojis uploaded to this instance via the admin API. | 51200 |
| gotosocial.config.media.emojiRemoteMaxSize | Int. Max size in bytes of emojis to download from other instances. | 102400 |

## STORAGE CONFIG Parameters
| gotosocial.config.storage.backend | String. Type of storage backend to use. | "local" |
| gotosocial.config.storage.localBasePath | String. Directory to use as a base path for storing files. | "/gotosocial/storage" |
| gotosocial.config.storage.s3.enabled | Enabled or Disables the User of s3 Storage | false |
| gotosocial.config.storage.s3.s3Endpoint | String. API endpoint of the S3 compatible service. | "" |
| gotosocial.config.storage.s3.s3Proxy | Bool. If data stored in S3 should be proxied through GoToSocial instead of redirecting to a presigned URL. | false |
| gotosocial.config.storage.s3.s3AccessKey | String. Access key part of the S3 credentials. | "" |
| gotosocial.config.storage.s3.s3SecretKey | String. Secret key part of the S3 credentials. | "" |
| gotosocial.config.storage.s3.s3Bucket | Only required when running with the s3 storage backend. | "" |

## STATUSES CONFIG Parameters
| gotosocial.config.statuses.maxChars | Int. Maximum amount of characters permitted for a new status. | 5000 |
| gotosocial.config.statuses.cwMaxChars | Int. Maximum amount of characters allowed in the CW/subject header of a status. | 100 |
| gotosocial.config.statuses.pollMaxOptions | Int. Maximum amount of options to permit when creating a new poll. | 6 |
| gotosocial.config.statuses.pollOptionMaxChars | Int. Maximum amount of characters to permit per poll option when creating a new poll. | 50 |
| gotosocial.config.statuses.mediaMaxFiles | Int. Maximum amount of media files that can be attached to a new status. | 6 |

## LETSENCRYPT CONFIG Parameters
| gotosocial.config.letsencrypt.enabled | Bool. Whether or not letsencrypt should be enabled for the server. | false |
| gotosocial.config.letsencrypt.port | Int. Port to listen for letsencrypt certificate challenges on. | 80 |
| gotosocial.config.letsencrypt.certDir | String. Directory in which to store LetsEncrypt certificates. | "/gotosocial/storage/certs" |
| gotosocial.config.letsencrypt.emailAddress | String. Email address to use when registering LetsEncrypt certs. | "" |

## OIDC CONFIG Parameters
| gotosocial.config.oidc.enabled | Bool. Enable authentication with external OIDC provider. | false |
| gotosocial.config.oidc.idpName | String. Name of the oidc idp (identity provider). | "" |
| gotosocial.config.oidc.skipVerification | Bool. Skip the normal verification flow of tokens returned from the OIDC provider. | false |
| gotosocial.config.oidc.issuer | String. The OIDC issuer URI. This is where GtS will redirect users to for login. | "" |
| gotosocial.config.oidc.clientID | String. The ID for this client as registered with the OIDC provider. | "" |
| gotosocial.config.oidc.clientSecret | String. The secret for this client as registered with the OIDC provider. | "" |
| gotosocial.config.oidc.oidcScopes | Array of string. Scopes to request from the OIDC provider. | [] |
| gotosocial.config.oidc.linkExisting | Bool. Link OIDC authenticated users to existing ones based on their email address. | false |

## SMTP CONFIG Parameters
| gotosocial.config.smtp.host | String. The hostname of the smtp server you want to use. | "" |
| gotosocial.config.smtp.port | Int. Port to use to connect to the smtp server. | 0 |
| gotosocial.config.smtp.userName| String. Username to use when authenticating with the smtp server. | "" |
| gotosocial.config.smtp.password | String. Password to use when authenticating with the smtp server. | "" |
| gotosocial.config.smtp.existingSecretName | String. Secret to get the Secretkey from. | "" |
| gotosocial.config.smtp.existingSecretKey | String. SecretKey to get the Password from | "" |
| gotosocial.config.smtp.from | String. 'From' address for sent emails. | "" |

## SYSLOG CONFIG Parameters
| gotosocial.config.syslog.enabled | Bool. Enable the syslog logging hook. Logs will be mirrored to the configured destination. | false |
| gotosocial.config.syslog.protocol | String. Protocol to use when directing logs to syslog. Leave empty to connect to local syslog. | "udp" |
| gotosocial.config.syslog.address | String. Address:port to send syslog logs to. Leave empty to connect to local syslog. | "localhost:514" |

## ADVANCED SETTINGS Parameters
| gotosocial.config.advanced.cookiesSamesite | String. Value of the SameSite attribute of cookies set by GoToSocial. | "lax" |
| gotosocial.config.advanced.rateLimitRequest | Int. Amount of requests to permit from a single IP address within a span of 5 minutes. | 1000 |