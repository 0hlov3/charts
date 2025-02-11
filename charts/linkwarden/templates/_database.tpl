{{/*
Check if Database is enabled
*/}}
{{- define "linkwarden.checkdatabaseenabled" -}}
{{- if not .Values.externalPostgresql.enabled -}}
{{- fail "Error: You must specify enable and configure externalPostgresql." -}}
{{- end -}}
{{- end -}}

{{/*
POSTGRES_HOST
*/}}
{{- define "linkwarden.postgres_host" -}}
{{- if and (ne .Values.externalPostgresql.existingSecret.name "") (ne .Values.externalPostgresql.existingSecret.keys.host "") -}}
valueFrom:
  secretKeyRef:
    name: {{ .Values.externalPostgresql.existingSecret.name |quote }}
    key: {{ .Values.externalPostgresql.existingSecret.keys.host |quote  }}
{{- else if ne .Values.externalPostgresql.host "" -}}
value: {{ .Values.externalPostgresql.host |quote  }}
{{- else -}}
{{- fail "Error: Please Configure a PostgreSQL Host" -}}
{{- end -}}
{{- end -}}

{{/*
POSTGRES_PORT
*/}}
{{- define "linkwarden.postgres_port" -}}
{{- if and (ne .Values.externalPostgresql.existingSecret.name "") (ne .Values.externalPostgresql.existingSecret.keys.port "") -}}
valueFrom:
  secretKeyRef:
    name: {{ .Values.externalPostgresql.existingSecret.name |quote }}
    key: {{ .Values.externalPostgresql.existingSecret.keys.port |quote  }}
{{- else if ne .Values.externalPostgresql.port "" -}}
value: {{ .Values.externalPostgresql.port |quote  }}
{{- else -}}
{{- fail "Error: Please Configure a PostgreSQL port" -}}
{{- end -}}
{{- end -}}

{{/*
POSTGRES_DATABASE
*/}}
{{- define "linkwarden.postgres_database" -}}
{{- if and (ne .Values.externalPostgresql.existingSecret.name "") (ne .Values.externalPostgresql.existingSecret.keys.database "") -}}
valueFrom:
  secretKeyRef:
    name: {{ .Values.externalPostgresql.existingSecret.name |quote }}
    key: {{ .Values.externalPostgresql.existingSecret.keys.database |quote  }}
{{- else if ne .Values.externalPostgresql.database "" -}}
value: {{ .Values.externalPostgresql.database |quote  }}
{{- else -}}
{{- fail "Error: Please Configure a PostgreSQL database" -}}
{{- end -}}
{{- end -}}

{{/*
POSTGRES_USERNAME
*/}}
{{- define "linkwarden.postgres_username" -}}
{{- if and (ne .Values.externalPostgresql.existingSecret.name "") (ne .Values.externalPostgresql.existingSecret.keys.username "") -}}
valueFrom:
  secretKeyRef:
    name: {{ .Values.externalPostgresql.existingSecret.name |quote }}
    key: {{ .Values.externalPostgresql.existingSecret.keys.username |quote  }}
{{- else if ne .Values.externalPostgresql.username "" -}}
value: {{ .Values.externalPostgresql.username |quote  }}
{{- else -}}
{{- fail "Error: Please Configure a PostgreSQL username" -}}
{{- end -}}
{{- end -}}

{{/*
POSTGRES_PASSWORD
*/}}
{{- define "linkwarden.postgres_password" -}}
{{- if and (ne .Values.externalPostgresql.existingSecret.name "") (ne .Values.externalPostgresql.existingSecret.keys.password "") -}}
valueFrom:
  secretKeyRef:
    name: {{ .Values.externalPostgresql.existingSecret.name |quote }}
    key: {{ .Values.externalPostgresql.existingSecret.keys.password |quote  }}
{{- else if ne .Values.externalPostgresql.password "" -}}
value: {{ .Values.externalPostgresql.password |quote  }}
{{- else -}}
{{- fail "Error: Please Configure a PostgreSQL password" -}}
{{- end -}}
{{- end -}}