{{/*
SMTP_HOST
*/}}
{{- define "matrix-synapse.smtp_host" -}}
{{- if and (ne .Values.config.server.email.existingSecret.name "") (ne .Values.config.server.email.existingSecret.keys.smtp_host "") -}}
valueFrom:
  secretKeyRef:
    name: {{ .Values.config.server.email.existingSecret.name |quote }}
    key: {{ .Values.config.server.email.existingSecret.keys.smtp_host |quote  }}
{{- else if ne .Values.config.server.email.smtp_host "" -}}
value: {{ .Values.config.server.email.smtp_host |quote  }}
{{ else -}}
{{- fail "Error: email enabled but no smtp_host given." -}}
{{- end -}}
{{- end -}}

{{/*
SMTP_PORT
*/}}
{{- define "matrix-synapse.smtp_port" -}}
{{- if and (ne .Values.config.server.email.existingSecret.name "") (ne .Values.config.server.email.existingSecret.keys.smtp_port "") -}}
valueFrom:
  secretKeyRef:
    name: {{ .Values.config.server.email.existingSecret.name |quote }}
    key: {{ .Values.config.server.email.existingSecret.keys.smtp_port |quote  }}
{{- else if ne .Values.config.server.email.smtp_port "" -}}
value: {{ .Values.config.server.email.smtp_port |quote  }}
{{ else -}}
{{- fail "Error: email enabled but no smtp_port given." -}}
{{- end -}}
{{- end -}}

{{/*
SMTP_USER
*/}}
{{- define "matrix-synapse.smtp_user" -}}
{{- if and (ne .Values.config.server.email.existingSecret.name "") (ne .Values.config.server.email.existingSecret.keys.smtp_user "") -}}
valueFrom:
  secretKeyRef:
    name: {{ .Values.config.server.email.existingSecret.name |quote }}
    key: {{ .Values.config.server.email.existingSecret.keys.smtp_user |quote  }}
{{- else if ne .Values.config.server.email.smtp_user "" -}}
value: {{ .Values.config.server.email.smtp_user |quote  }}
{{ else -}}
{{- fail "Error: email enabled but no smtp_user given." -}}
{{- end -}}
{{- end -}}

{{/*
SMTP_PASS
*/}}
{{- define "matrix-synapse.smtp_pass" -}}
{{- if and (ne .Values.config.server.email.existingSecret.name "") (ne .Values.config.server.email.existingSecret.keys.smtp_pass "") -}}
valueFrom:
  secretKeyRef:
    name: {{ .Values.config.server.email.existingSecret.name |quote }}
    key: {{ .Values.config.server.email.existingSecret.keys.smtp_pass |quote  }}
{{- else if ne .Values.config.server.email.smtp_pass "" -}}
value: {{ .Values.config.server.email.smtp_pass |quote  }}
{{ else -}}
{{- fail "Error: email enabled but no smtp_pass given." -}}
{{- end -}}
{{- end -}}