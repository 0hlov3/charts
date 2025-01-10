{{/*
registration_shared_secret
*/}}
{{- define "matrix-synapse.registration_shared_secret" -}}
{{- if and (ne .Values.config.registration.existingSecret.name "") (ne .Values.config.registration.existingSecret.keys.registration_shared_secret "") -}}
valueFrom:
  secretKeyRef:
    name: {{ .Values.config.registration.existingSecret.name |quote }}
    key: {{ .Values.config.registration.existingSecret.keys.registration_shared_secret |quote  }}
{{- else if ne .Values.config.registration.registration_shared_secret "" -}}
value: {{ .Values.config.registration.registration_shared_secret |quote  }}
{{- else -}}
value: {{ randAlphaNum 24 }}
{{- end -}}
{{- end -}}

{{/*
macaroon_secret_key
*/}}
{{- define "matrix-synapse.macaroon_secret_key" -}}
{{- if and (ne .Values.config.apiConfiguration.existingSecret.name "") (ne .Values.config.apiConfiguration.existingSecret.keys.macaroon_secret_key "") -}}
valueFrom:
  secretKeyRef:
    name: {{ .Values.config.registration.existingSecret.name |quote }}
    key: {{ .Values.config.registration.existingSecret.keys.registration_shared_secret |quote  }}
{{- else if ne .Values.config.apiConfiguration.macaroon_secret_key "" -}}
value: {{ .Values.config.apiConfiguration.macaroon_secret_key |quote  }}
{{- else -}}
value: {{ randAlphaNum 24 }}
{{- end -}}
{{- end -}}