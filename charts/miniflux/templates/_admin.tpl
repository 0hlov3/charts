{{/*
ADMIN_USERNAME
*/}}
{{- define "miniflux.admin_username" -}}
{{- if and (ne .Values.config.admin.existingSecret.name "") (ne .Values.config.admin.existingSecret.keys.name "") -}}
valueFrom:
  secretKeyRef:
    name: {{ .Values.config.admin.existingSecret.name |quote }}
    key: {{ .Values.config.admin.existingSecret.keys.name |quote  }}
{{- else if ne .Values.config.admin.name "" -}}
value: {{ .Values.config.admin.name |quote  }}
{{- else -}}
{{- fail "Error: Please Configure a Admin Name" -}}
{{- end -}}
{{- end -}}

{{/*
ADMIN_USERNAME
*/}}
{{- define "miniflux.admin_password" -}}
{{- if and (ne .Values.config.admin.existingSecret.name "") (ne .Values.config.admin.existingSecret.keys.password "") -}}
valueFrom:
  secretKeyRef:
    name: {{ .Values.config.admin.existingSecret.name |quote }}
    key: {{ .Values.config.admin.existingSecret.keys.password |quote  }}
{{- else if ne .Values.config.admin.password "" -}}
value: {{ .Values.config.admin.password |quote  }}
{{- else -}}
{{- fail "Error: Please Configure a Admin Password" -}}
{{- end -}}
{{- end -}}
