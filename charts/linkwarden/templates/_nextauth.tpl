{{/*
NEXTAUTH_SECRET
*/}}
{{- define "linkwarden.nextauth_secret" -}}
{{- if and (ne .Values.env.nextauth.existingSecret.name "") (ne .Values.env.nextauth.existingSecret.key "") -}}
valueFrom:
  secretKeyRef:
    name: {{ .Values.env.nextauth.existingSecret.name |quote }}
    key: {{ .Values.env.nextauth.existingSecret.key |quote  }}
{{- else if ne .Values.env.nextauth.secret "" -}}
value: {{ .Values.env.nextauth.secret |quote  }}
{{- else -}}
{{- fail "Error: Please Configure a .Values.env.nextauth.secret" -}}
{{- end -}}
{{- end -}}