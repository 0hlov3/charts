# Etherpad Helm Chart

This chart deploys the official Etherpad Docker image.

## Upgrading from chart 0.3.0 / Etherpad 2.7.2 to chart 0.4.1 / Etherpad 3.3.6

This chart targets `etherpad/etherpad:3.3.6`. Etherpad 3.3.4 through 3.3.6 are
security and bug-fix releases with no changes to the Docker image's
`settings.json.docker` template (env vars, ports, volumes, and the container
user are unchanged from 3.3.3), so if you are already on a 3.3.3-based chart
install, no configuration changes are required. Notably:

- 3.3.4 fixes a stored XSS in the `createDiffHTML` API output (GHSA-6vx2-3gwr-958v).
- 3.3.6 fixes an OIDC login bypass for accounts configured without a password
  (GHSA-62cj-9j72-mfrh).

If you are upgrading from chart `0.3.0` (Etherpad `2.7.2`), the following
behavior changes apply even if you do not touch your `values.yaml`:

### Security contexts are now hardened by default

Previously:

```yaml
podSecurityContext: {}
securityContext: {}
```

The chart now ships:

```yaml
podSecurityContext:
  seccompProfile:
    type: RuntimeDefault

securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
  runAsNonRoot: true
  runAsUser: 5001
```

This only changes your deployment if you were **not** already overriding
`podSecurityContext`/`securityContext` in your own values file — if you copied
the old defaults verbatim into your overrides, you keep the old (unrestricted)
behavior until you remove that override.

`runAsUser: 5001` is required, not optional, alongside `runAsNonRoot: true`.
The official `etherpad/etherpad` image's Dockerfile declares `USER etherpad` —
a named user, not a numeric UID — and Kubernetes cannot verify `runAsNonRoot`
against a named user. Without an explicit numeric `runAsUser`, the kubelet
refuses to start the pod with:

```text
Error: container has runAsNonRoot and image has non-numeric user (etherpad),
cannot verify user is non-root
```

This was verified against a real cluster (`kind`, Kubernetes 1.36): the pod
sits in `CreateContainerConfigError` until `runAsUser` is set. UID `5001`
resolves to the image's own `etherpad` user (GID `0`), so the default value
matches the image exactly and needs no further configuration. **If you run a
custom or forked Etherpad image with a different UID**, override
`securityContext.runAsUser` to match it, or set
`securityContext.runAsNonRoot: false` if that image must run as root.

### Socket.IO buffer size default increased

```
etherpad.advanced.socketioMaxHttpBufferSize: 10000 → 1000000
```

This follows Etherpad's current upstream Docker default (`SOCKETIO_MAX_HTTP_BUFFER_SIZE`
now defaults to `1000000`/1 MB rather than `10000`). If you rely on the old,
much smaller limit (e.g. to bound per-message memory more aggressively), set
`etherpad.advanced.socketioMaxHttpBufferSize` explicitly.

### `showSettingsInAdminPage` now actually takes effect

The chart previously emitted a misspelled environment variable
(`HOW_SETTINGS_IN_ADMIN_PAGE` instead of `SHOW_SETTINGS_IN_ADMIN_PAGE`), so
`etherpad.advanced.showSettingsInAdminPage` was silently ignored — Etherpad
always used its own built-in default (`true`) regardless of this value. The
chart now sets the correctly named `SHOW_SETTINGS_IN_ADMIN_PAGE` variable. If
you had explicitly set:

```yaml
etherpad:
  advanced:
    showSettingsInAdminPage: false
```

it had no effect before this upgrade; after upgrading, `/admin`'s settings.json
view will actually be hidden as configured. Double check this value reflects
what you intend.

### Authentication

Etherpad 3.x defaults `AUTHENTICATION_METHOD` to `sso` (the built-in OpenID
Connect provider), a change from the implicit legacy API-key behavior on the
2.x line. Existing `APIKEY.txt`/API-key consumers upgrading from 2.7.2 may
need:

```yaml
etherpad:
  advanced:
    authenticationMethod: apikey
```

### IP logging

`etherpad.logging.disableIPLogging` (boolean) is retained for compatibility.
It is no longer sent to Etherpad as `DISABLE_IP_LOGGING`; instead the chart
maps it to Etherpad 3.x's current `IP_LOGGING` variable (`true` → `anonymous`,
`false` → `full`), matching the deprecated-fallback mapping Etherpad itself
documents in `settings.json.docker`. Set `etherpad.logging.ipLogging` directly
(`anonymous`, `truncated`, or `full`) if you need a value other than these two.

### Other upgrade steps

- Back up the Etherpad database before upgrading. For PostgreSQL, take a `pg_dump` or equivalent operational backup. Etherpad stores pad content, revisions, chat, sessions, and related metadata in the configured database.
- Verify third-party plugins against Etherpad 3.x. The chart does not install plugins at runtime or mount `/opt/etherpad-lite/src/plugin_packages`; use a custom image if you need preinstalled plugins.
- If Etherpad is behind an Ingress or reverse proxy, set `etherpad.advanced.trustProxy=true` only when the proxy is trusted and correctly manages `X-Forwarded-*` headers. Etherpad 3.2+ honors `X-Forwarded-Prefix` and `X-Ingress-Path` when `trustProxy` is enabled.
- The official image exposes port `9001` and runs as an unprivileged `etherpad` user. The image currently uses UID `5001` and GID `0`; this chart pins `securityContext.runAsUser: 5001` to match, which is required for `runAsNonRoot: true` to work against this image's named (non-numeric) `USER` declaration.
- The chart does not persist or mount `/opt/etherpad-lite`, `/opt/etherpad-lite/var`, `/opt/etherpad-lite/settings.json`, or `/opt/etherpad-lite/src/plugin_packages`. With the default DirtyDB backend, data is ephemeral; use PostgreSQL for production.

## Configuration Notes

- Etherpad settings are supplied through environment variables consumed by the upstream `settings.json.docker` template.
- `showSettingsInAdminPage` renders as `SHOW_SETTINGS_IN_ADMIN_PAGE`.
- `etherpad.logging.disableIPLogging` is preserved for chart compatibility and rendered as the newer `IP_LOGGING` variable unless `etherpad.logging.ipLogging` is explicitly set.
- `etherpad.advanced.tidyHTML` is kept as a deprecated values key for compatibility but is not rendered because Etherpad 3.3.x no longer exposes `TIDY_HTML` in `settings.json.docker`. It has no effect with Etherpad 3.3.6.
- Probes use Etherpad's `/health` endpoint. Startup probing is intentionally tolerant to allow database connection and startup work to finish.

### PostgreSQL configuration

The chart supports exactly three database modes, chosen by two independent
booleans:

| `postgresql.enabled` | `externalPostgresql.enabled` | Result |
|---|---|---|
| `false` | `false` | Etherpad's default DirtyDB backend (ephemeral, no `DB_*` vars rendered) |
| `false` | `true`  | Externally managed PostgreSQL (any provider) |
| `true`  | `false` | Bundled Bitnami PostgreSQL subchart |
| `true`  | `true`  | **Invalid.** The chart fails to render with an explicit error — enabling both would deploy an unused bundled PostgreSQL instance (and its persistent storage) while Etherpad actually connects to the external database. Set exactly one to `true`. |

Verified/supported:

- Discrete fields — `externalPostgresql.host`/`port`/`database`/`username`/`password` (or `externalPostgresql.existingSecret`) render Etherpad's standard `DB_TYPE`/`DB_HOST`/`DB_PORT`/`DB_NAME`/`DB_USER`/`DB_PASS` variables. This is the only verified way to configure an external PostgreSQL database through the stock image. `externalPostgresql.host` is used exactly as given — the chart makes no assumptions about the database running in the same Helm release/namespace, so any Service DNS name (short name or FQDN) from any PostgreSQL provider or operator works.
- External existing Secret — set `externalPostgresql.existingSecret` to a pre-created Secret name and Etherpad reads both `DB_USER` and `DB_PASS` from it via `secretKeyRef`, instead of the literal `username`/`password` values. The Secret keys default to `username`/`password` for backward compatibility, but are configurable via `externalPostgresql.existingSecretUsernameKey`/`existingSecretPasswordKey` if your Secret uses different key names. The chart never copies these credentials into a chart-managed Secret or ConfigMap.
- Bundled PostgreSQL (`postgresql.enabled: true`) — the chart always wires `DB_PASS` through a `secretKeyRef` against the Bitnami `postgresql` subchart's own Secret (`<release>-postgresql`, key `password`), whether that Secret's password was auto-generated by the subchart or set explicitly via `postgresql.auth.password`. The bundled PostgreSQL password is never inlined into the Etherpad Deployment as plain text. Set `postgresql.auth.existingSecret` to use your own pre-created Secret instead (same `password` key expectation).
- `extraEnv` — a generic list of extra Kubernetes `EnvVar` objects appended to the Etherpad container, for provider-specific settings this chart doesn't (and shouldn't) model directly. For example, Etherpad's PostgreSQL driver (`node-postgres`, via `ueberdb2`) reads the standard libpq `PGSSLMODE` environment variable when no explicit `ssl` setting is present in `settings.json`, so `extraEnv` can be used to set it. **This is not a chart-verified TLS feature** — whether it actually satisfies your PostgreSQL server/operator's TLS requirements depends on your setup and must be tested end-to-end; the chart makes no claims about which `PGSSLMODE` values work or that certificate verification is possible (the stock image has no way to supply a custom CA/client cert/key for the database connection).

Deprecated/unsupported:

- `externalPostgresql.useConnectionString` — **do not enable this.** It was intended to render a PostgreSQL connection string via Etherpad's `DB_URL` variable, but `DB_URL` is not consumed by Etherpad 3.3.6's PostgreSQL driver (`ueberdb2` 6.1.16 passes `dbSettings` straight into `pg.Pool`, which only recognizes a `connectionString` key, not `url`). There is no supported way to configure PostgreSQL via a connection string through the stock Etherpad Docker image's environment-variable interface — only the discrete `DB_*` variables are honored. To prevent silently deploying a broken database configuration, the chart fails to render (`helm template`/`helm install`/`helm upgrade` all abort with an explicit error) if `externalPostgresql.useConnectionString: true` is set. The value is kept in `values.yaml` for backward compatibility with existing overrides, but it must be `false` (the default); use the discrete fields above instead.

#### Example: external PostgreSQL with an existing Secret

```yaml
postgresql:
  enabled: false

externalPostgresql:
  enabled: true
  host: postgres.example.internal
  port: "5432"
  database: etherpad
  existingSecret: etherpad-postgres-credentials
  existingSecretUsernameKey: username   # defaults shown; override if your Secret differs
  existingSecretPasswordKey: password
```

#### Example: generic external PostgreSQL functionality with a CloudNativePG-provisioned database

This is a plain usage of the generic external PostgreSQL support above — the
chart has no CloudNativePG-specific code, values, or assumptions. It works
here only because CloudNativePG's default `<cluster>-app` Secret happens to
use `username`/`password` as its key names, which are also this chart's
defaults; the same configuration shape works with any other operator or
managed PostgreSQL service that exposes a stable Service name and a Secret
with username/password keys. Assuming a CloudNativePG `Cluster` named
`etherpad-postgresql` with its default `-rw` read/write Service and `-app`
credentials Secret:

```yaml
postgresql:
  enabled: false

externalPostgresql:
  enabled: true
  host: etherpad-postgresql-rw        # the Cluster's read/write Service;
                                       # use the FQDN (etherpad-postgresql-rw.<namespace>.svc.cluster.local)
                                       # if Etherpad and the database are in different namespaces
  port: "5432"
  database: etherpad
  existingSecret: etherpad-postgresql-app
  existingSecretUsernameKey: username
  existingSecretPasswordKey: password

# Optional: see the extraEnv note above before relying on this for TLS.
# extraEnv:
#   - name: PGSSLMODE
#     value: require
```

## Parameters

### Global parameters

| Name               | Description                                                                             | Value |
| ------------------ | --------------------------------------------------------------------------------------- | ----- |
| `replicaCount`     | Number of Etherpad pod replicas to run                                                  | `1`   |
| `imagePullSecrets` | Names of existing Secrets to use for pulling the Etherpad image from a private registry | `[]`  |
| `nameOverride`     | Override for the chart name used when generating resource names                         | `""`  |
| `fullnameOverride` | Override for the fully qualified release name used to generate resource names           | `""`  |

### Image parameters

| Name               | Description                                                       | Value               |
| ------------------ | ----------------------------------------------------------------- | ------------------- |
| `image`            | Etherpad container image                                          |                     |
| `image.repository` | Etherpad container image repository                               | `etherpad/etherpad` |
| `image.pullPolicy` | Etherpad image pull policy                                        | `IfNotPresent`      |
| `image.tag`        | Etherpad image tag. Defaults to the chart's appVersion when empty | `""`                |

### Etherpad general settings

| Name                                               | Description                                                                                                                     | Value                        |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| `etherpad.general.title`                           | The name of the Etherpad instance, shown in the UI                                                                              | `Etherpad`                   |
| `etherpad.general.favicon`                         | Favicon: either the default name or a fully specified URL to your own favicon                                                   | `null`                       |
| `etherpad.general.defaultPadText`                  | The default text of a newly created pad (see values.yaml for the full default text)                                             | `"Welcome to Etherpad! ..."` |
| `etherpad.general.ip`                              | IP address Etherpad binds to inside the container. Change to :: for IPv6                                                        | `0.0.0.0`                    |
| `etherpad.general.port`                            | TCP port Etherpad listens on inside the container                                                                               | `9001`                       |
| `etherpad.general.admin.password`                  | Plain-text password for the built-in "admin" user. Leave empty to skip creating it. Ignored when existingSecret.enabled is true | `""`                         |
| `etherpad.general.admin.existingSecret`            | Read the admin password from an existing Secret instead of the plain-text value above                                           |                              |
| `etherpad.general.admin.existingSecret.enabled`    | Read ADMIN_PASSWORD from existingSecret.secretName/secretKey instead of etherpad.general.admin.password                         | `false`                      |
| `etherpad.general.admin.existingSecret.secretName` | Name of the existing Secret containing the admin password                                                                       | `etherpad`                   |
| `etherpad.general.admin.existingSecret.secretKey`  | Key inside existingSecret.secretName that holds the admin password                                                              | `admin-password`             |
| `etherpad.general.userPassword`                    | Plain-text password for the built-in first "user" account. Leave empty to skip creating it                                      | `""`                         |

### Etherpad pad options

| Name                                   | Description                                                                                                       | Value   |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | ------- |
| `etherpad.padOptions`                  | Default behavior/appearance applied to every pad; users may still override some of these per-pad in their browser |         |
| `etherpad.padOptions.NoColors`         | Disable authorship colors in the editor                                                                           | `false` |
| `etherpad.padOptions.showControls`     | Show the pad's toolbar/editbar controls                                                                           | `true`  |
| `etherpad.padOptions.showChat`         | Show the chat panel                                                                                               | `true`  |
| `etherpad.padOptions.showLineNumbers`  | Show line numbers in the editor                                                                                   | `true`  |
| `etherpad.padOptions.useMonospaceFont` | Use a monospace font in the editor                                                                                | `false` |
| `etherpad.padOptions.userName`         | Default display name shown for anonymous users. Set to false to disable                                           | `false` |
| `etherpad.padOptions.userColor`        | Default authorship color for anonymous users. Set to false to disable                                             | `false` |
| `etherpad.padOptions.rtl`              | Render pad content right-to-left                                                                                  | `false` |
| `etherpad.padOptions.alwaysShowChat`   | Keep the chat panel open by default                                                                               | `false` |
| `etherpad.padOptions.chatAndUsers`     | Show the combined chat-and-users panel                                                                            | `false` |
| `etherpad.padOptions.lang`             | Default UI language (e.g. en-gb)                                                                                  | `en-gb` |
| `etherpad.padOptions.lowercasePadIDs`  | Force pad IDs to lowercase                                                                                        | `false` |

### Etherpad keyboard shortcuts

| Name                                  | Description                                                        | Value  |
| ------------------------------------- | ------------------------------------------------------------------ | ------ |
| `etherpad.shortcuts`                  | Enable/disable individual pad editor keyboard shortcuts            |        |
| `etherpad.shortcuts.enabledAltF9`     | Alt+F9: focus the File Menu and/or editbar                         | `true` |
| `etherpad.shortcuts.enabledAltC`      | Alt+C: focus the Chat window                                       | `true` |
| `etherpad.shortcuts.enabledCmdS`      | Cmd/Ctrl+S: save a revision                                        | `true` |
| `etherpad.shortcuts.enabledCmdZ`      | Cmd/Ctrl+Z: undo                                                   | `true` |
| `etherpad.shortcuts.enabledCmdY`      | Cmd/Ctrl+Y: redo                                                   | `true` |
| `etherpad.shortcuts.enabledCmdI`      | Cmd/Ctrl+I: italic                                                 | `true` |
| `etherpad.shortcuts.enabledCmdB`      | Cmd/Ctrl+B: bold                                                   | `true` |
| `etherpad.shortcuts.enabledCmdU`      | Cmd/Ctrl+U: underline                                              | `true` |
| `etherpad.shortcuts.enabledCmdH`      | Cmd/Ctrl+H: backspace                                              | `true` |
| `etherpad.shortcuts.enabledCmd5`      | Cmd/Ctrl+5: strike through                                         | `true` |
| `etherpad.shortcuts.enabledCmdShift1` | Cmd/Ctrl+Shift+1: ordered list                                     | `true` |
| `etherpad.shortcuts.enabledCmdShift2` | Cmd/Ctrl+Shift+2: show a gritter popup with the line's author      | `true` |
| `etherpad.shortcuts.enabledCmdShiftL` | Cmd/Ctrl+Shift+L: unordered list                                   | `true` |
| `etherpad.shortcuts.enabledCmdShiftN` | Cmd/Ctrl+Shift+N: ordered list                                     | `true` |
| `etherpad.shortcuts.enabledCmdShiftC` | Cmd/Ctrl+Shift+C: clear authorship colors                          | `true` |
| `etherpad.shortcuts.enabledDELETE`    | Delete key shortcut handling in the editor                         | `true` |
| `etherpad.shortcuts.enabledRETURN`    | Return/Enter key shortcut handling in the editor                   | `true` |
| `etherpad.shortcuts.enabledESC`       | Esc: avoid reconnecting the pad (needed on Mozilla versions 14-19) | `true` |
| `etherpad.shortcuts.enabledTAB`       | Tab: indent                                                        | `true` |
| `etherpad.shortcuts.enabledCTRLHOME`  | Ctrl+Home: scroll to top of pad                                    | `true` |
| `etherpad.shortcuts.enabledPAGEUP`    | Page Up: scroll the pad up                                         | `true` |
| `etherpad.shortcuts.enabledPAGEDOWN`  | Page Down: scroll the pad down                                     | `true` |

### Etherpad skins

| Name                          | Description                                                                     | Value                                                     |
| ----------------------------- | ------------------------------------------------------------------------------- | --------------------------------------------------------- |
| `etherpad.skins.skinName`     | Skin to use: no-skin, colibris, or an existing directory under src/static/skins | `colibris`                                                |
| `etherpad.skins.skinVariants` | Space-separated list of skin variants (colibris skin only)                      | `super-light-toolbar super-light-editor light-background` |

### Etherpad logging

| Name                                | Description                                                                                                                                      | Value   |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | ------- |
| `etherpad.logging.logLevel`         | Server log verbosity. One of DEBUG, INFO, WARN, ERROR                                                                                            | `INFO`  |
| `etherpad.logging.disableIPLogging` | Deprecated compatibility toggle: true maps to etherpad.logging.ipLogging=anonymous, false maps to full. Ignored when ipLogging is set explicitly | `false` |
| `etherpad.logging.ipLogging`        | Client IP logging mode: anonymous, truncated, or full. Leave empty to derive the value from disableIPLogging                                     | `""`    |

### Etherpad cookie settings

| Name                                     | Description                                                                                 | Value       |
| ---------------------------------------- | ------------------------------------------------------------------------------------------- | ----------- |
| `etherpad.cookie.keyRotationInterval`    | How often (in milliseconds) the cookie signing key is rotated                               | `86400000`  |
| `etherpad.cookie.sameSite`               | Value of the SameSite cookie attribute                                                      | `Lax`       |
| `etherpad.cookie.sessionLifetime`        | How long (in milliseconds) a session cookie remains valid before the user must log in again | `864000000` |
| `etherpad.cookie.sessionRefreshInterval` | How often (in milliseconds) the session cookie's expiration is refreshed                    | `86400000`  |

### Etherpad advanced settings

| Name                                             | Description                                                                                                                                                                    | Value      |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------- |
| `etherpad.advanced.showSettingsInAdminPage`      | Show the raw settings.json content on the /admin/settings page                                                                                                                 | `true`     |
| `etherpad.advanced.authenticationMethod`         | Authentication method used by the server: sso (built-in OpenID Connect provider, Etherpad 3.x default) or apikey (legacy APIKEY.txt-based API auth)                            | `sso`      |
| `etherpad.advanced.trustProxy`                   | Trust X-Forwarded-* headers from a reverse proxy in front of Etherpad (e.g. for TLS termination). Only enable when the proxy is trusted and sets these headers correctly       | `false`    |
| `etherpad.advanced.importMaxFileSize`            | Maximum allowed file size when importing a pad, in bytes (default: 50 MB)                                                                                                      | `52428800` |
| `etherpad.advanced.importExportMaxReqPerIp`      | Maximum number of import/export calls allowed per IP within the rate-limit window                                                                                              | `10`       |
| `etherpad.advanced.importExportRateLimitWindow`  | Time window (in milliseconds) used to estimate the import/export call rate                                                                                                     | `90000`    |
| `etherpad.advanced.commitRateLimitDuration`      | Duration (in seconds) of the rate-limit window for pad commits by individual users/IPs                                                                                         | `1`        |
| `etherpad.advanced.commitRateLimitPoints`        | Maximum number of pad changes allowed per IP during the rate-limit window                                                                                                      | `10`       |
| `etherpad.advanced.suppressErrorsInPadText`      | Suppress internal errors from being shown inside the default pad text                                                                                                          | `false`    |
| `etherpad.advanced.requireSession`               | Require a session to access any pad, effectively restricting access to group pads only                                                                                         | `false`    |
| `etherpad.advanced.editOnly`                     | Allow editing existing pads but disallow creating new ones outside of the API                                                                                                  | `false`    |
| `etherpad.advanced.minify`                       | Minify CSS/JS served to clients. Improves load performance but hinders frontend debugging                                                                                      | `true`     |
| `etherpad.advanced.maxAge`                       | How long (in seconds) clients may cache served JavaScript. Set to 0 to disable caching (default: 6 hours)                                                                      | `21600`    |
| `etherpad.advanced.soffice`                      | Absolute path to the soffice (LibreOffice) executable, used for DOC/ODT/RTF export and PDF import. Set to null to disable those conversions (not bundled in the default image) | `nil`      |
| `etherpad.advanced.docxExport`                   | Export DOCX files via LibreOffice when true; falls back to legacy .doc output when false. Requires soffice to be set                                                           | `true`     |
| `etherpad.advanced.tidyHTML`                     | Deprecated and unused: Etherpad 3.3.x's Docker settings template no longer exposes TIDY_HTML. Kept only for values-file compatibility; has no effect                           | `nil`      |
| `etherpad.advanced.allowUnknownFileEnds`         | Allow importing file types other than the natively supported ones (txt, doc, docx, rtf, odt, html, htm)                                                                        | `true`     |
| `etherpad.advanced.requireAuthentication`        | Require authentication for all users. Note: /admin always requires authentication regardless of this setting                                                                   | `false`    |
| `etherpad.advanced.requireAuthorization`         | Require authorization by a plugin/module, or a user with is_admin set                                                                                                          | `false`    |
| `etherpad.advanced.automaticReconnectionTimeout` | Seconds before the client automatically reconnects after a "Force reconnect" message. Set to 0 to disable automatic reconnection                                               | `0`        |
| `etherpad.advanced.focusLinePercentageAbove`     | Extra viewport height (as a fraction, e.g. 0.5) to scroll when the caret line is above the viewport. Set to 0 to disable                                                       | `0`        |
| `etherpad.advanced.focusLinePercentageBelow`     | Extra viewport height (as a fraction, e.g. 0.5) to scroll when the caret line is below the viewport. Set to 0 to disable                                                       | `0`        |
| `etherpad.advanced.focusLinePercentageArrowUp`   | Extra viewport height to scroll when the user presses arrow-up at the top of the viewport. Set to 0 for Etherpad's default handling                                            | `0`        |
| `etherpad.advanced.focusLineDuration`            | Duration (in milliseconds) of the scroll-into-view animation. Set to 0 to disable animation                                                                                    | `0`        |
| `etherpad.advanced.focusLineCaretScroll`         | Scroll the viewport when the caret is placed on the last line of the pad                                                                                                       | `false`    |
| `etherpad.advanced.socketioMaxHttpBufferSize`    | Maximum size (in bytes) of a single Socket.IO message. Larger messages cause the connection to be closed to prevent memory-exhaustion (DoS) attacks                            | `1000000`  |
| `etherpad.advanced.loadTest`                     | Allow load-testing tools to hit this instance. WARNING: disables security protections; never enable in production                                                              | `false`    |
| `etherpad.advanced.dumpOnUncleanExit`            | Dump Node.js objects that prevent a clean process exit. WARNING: has a significant performance impact                                                                          | `false`    |
| `etherpad.advanced.exposeVersion`                | Expose the Etherpad version in the web UI and the Server HTTP header. Do not enable on production instances                                                                    | `false`    |

### External PostgreSQL parameters

| Name                                           | Description                                                                                                                                                                                                                        | Value                  |
| ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------- |
| `externalPostgresql.enabled`                   | Use an externally managed PostgreSQL database instead of Etherpad's default DirtyDB backend or the bundled Bitnami subchart. Mutually exclusive with postgresql.enabled                                                            | `false`                |
| `externalPostgresql.host`                      | Hostname or Kubernetes Service DNS name of the external PostgreSQL server (any provider/operator; no assumptions are made about naming or namespace)                                                                               | `etherpad.example.com` |
| `externalPostgresql.port`                      | TCP port of the external PostgreSQL server                                                                                                                                                                                         | `5432`                 |
| `externalPostgresql.database`                  | Name of the database Etherpad connects to                                                                                                                                                                                          | `etherpad`             |
| `externalPostgresql.username`                  | Plain-text database username. Ignored when existingSecret is set                                                                                                                                                                   | `etherpad`             |
| `externalPostgresql.password`                  | Plain-text database password. Ignored when existingSecret is set. Avoid in production; prefer existingSecret                                                                                                                       | `etherpad`             |
| `externalPostgresql.existingSecret`            | Name of an existing Secret containing the database username/password. DB_USER and DB_PASS are read from it via secretKeyRef instead of the literal values above; no chart-managed Secret is created                                | `""`                   |
| `externalPostgresql.existingSecretUsernameKey` | Key inside externalPostgresql.existingSecret that holds the database username                                                                                                                                                      | `username`             |
| `externalPostgresql.existingSecretPasswordKey` | Key inside externalPostgresql.existingSecret that holds the database password                                                                                                                                                      | `password`             |
| `externalPostgresql.useConnectionString`       | Deprecated/unsupported: DB_URL is not honored by Etherpad's PostgreSQL driver on the stock image. Must stay false; setting it to true makes the chart fail to render instead of silently deploying a broken database configuration | `false`                |

### Bundled PostgreSQL parameters (Bitnami dependency)

| Name                             | Description                                                                                                                                                                                                                               | Value      |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| `postgresql.enabled`             | Deploy PostgreSQL using the bundled Bitnami subchart instead of Etherpad's default DirtyDB backend or an external database. Mutually exclusive with externalPostgresql.enabled                                                            | `false`    |
| `postgresql.auth.username`       | Username for the PostgreSQL database Etherpad connects to (created by the Bitnami subchart)                                                                                                                                               | `etherpad` |
| `postgresql.auth.database`       | Name of the PostgreSQL database created by the Bitnami subchart for Etherpad                                                                                                                                                              | `etherpad` |
| `postgresql.auth.existingSecret` | Name of an existing Secret for the bundled PostgreSQL credentials, as understood by the Bitnami subchart. Leave empty to use the subchart's own auto-generated password, which Etherpad still reads via secretKeyRef rather than inlining | `""`       |

### Service account parameters

| Name                         | Description                                                                                                               | Value  |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------- | ------ |
| `serviceAccount`             | ServiceAccount options                                                                                                    |        |
| `serviceAccount.create`      | Create a ServiceAccount for the Etherpad pod                                                                              | `true` |
| `serviceAccount.annotations` | Annotations to add to the ServiceAccount                                                                                  | `{}`   |
| `serviceAccount.name`        | Name of the ServiceAccount to use. Auto-generated from the fullname template when empty and serviceAccount.create is true | `""`   |

### Pod parameters

| Name                 | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                     | Value |
| -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| `podAnnotations`     | Annotations to add to the Etherpad pod                                                                                                                                                                                                                                                                                                                                                                                                                          | `{}`  |
| `podSecurityContext` | Pod-level security context, applied to the whole Etherpad pod                                                                                                                                                                                                                                                                                                                                                                                                   | `{}`  |
| `securityContext`    | Container-level security context for the Etherpad container. Defaults are hardened to run the upstream image as non-root (all capabilities dropped, no privilege escalation, runAsNonRoot). The official image's Dockerfile declares a named USER (etherpad, UID 5001) rather than a numeric one, and Kubernetes cannot verify runAsNonRoot against a named user, so runAsUser must be set explicitly or the pod fails to start with CreateContainerConfigError | `{}`  |

### Extra environment variables

| Name       | Description                                                                                                                                                   | Value |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| `extraEnv` | Additional Kubernetes EnvVar objects appended to the Etherpad container, supporting both plain `value` and `valueFrom.secretKeyRef`/`configMapKeyRef` entries | `[]`  |

### Probes

| Name             | Description                                                                                                                                                                 | Value |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| `startupProbe`   | Startup probe configuration (Kubernetes Probe object). Checks Etherpad's /health endpoint; tolerant failureThreshold to allow time for database connection and startup work | `{}`  |
| `readinessProbe` | Readiness probe configuration (Kubernetes Probe object). Checks Etherpad's /health endpoint                                                                                 | `{}`  |
| `livenessProbe`  | Liveness probe configuration (Kubernetes Probe object). Checks Etherpad's /health endpoint                                                                                  | `{}`  |

### Service parameters

| Name           | Description                         | Value       |
| -------------- | ----------------------------------- | ----------- |
| `service.type` | Kubernetes Service type             | `ClusterIP` |
| `service.port` | Service port Etherpad is exposed on | `80`        |

### Ingress parameters

| Name                  | Description                                              | Value   |
| --------------------- | -------------------------------------------------------- | ------- |
| `ingress.enabled`     | Enable Ingress for the Etherpad web UI                   | `false` |
| `ingress.className`   | IngressClass to use (Kubernetes >=1.18)                  | `""`    |
| `ingress.annotations` | Additional annotations for the Ingress                   | `{}`    |
| `ingress.hosts`       | Ingress host and path rules                              | `[]`    |
| `ingress.tls`         | TLS configuration for the Ingress (secretName and hosts) | `[]`    |

### Resource parameters

| Name        | Description                                                    | Value |
| ----------- | -------------------------------------------------------------- | ----- |
| `resources` | CPU/Memory resource requests/limits for the Etherpad container | `{}`  |

### Scheduling parameters

| Name           | Description                                              | Value |
| -------------- | -------------------------------------------------------- | ----- |
| `nodeSelector` | Node labels for Etherpad pod assignment                  | `{}`  |
| `tolerations`  | Tolerations for Etherpad pod assignment                  | `[]`  |
| `affinity`     | Affinity/anti-affinity rules for Etherpad pod assignment | `{}`  |
