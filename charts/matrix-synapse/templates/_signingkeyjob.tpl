{{/*
Generate the name of the signing key job to use
*/}}
{{- define "matrix-synapse.signingKeyFullName" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "signingkey-%s" .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
  {{- $name := default .Chart.Name .Values.nameOverride -}}
  {{- if contains .Release.Name $name -}}
    {{- printf "signingkey-%s" .Release.Name | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- printf "signingkey-%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Check and return whether signingkey.job.enabled is true, while also validating configuration.
*/}}
{{- define "matrix-synapse.checkSigningKeyConfiguration" -}}
{{- if and .Values.signingkey.job.enabled .Values.signingkey.existingSecret -}}
{{- fail "Error: You cannot enable both signingkey.job and signingkey.existingSecret. Please choose one." -}}
{{- end }}
{{- if .Values.signingkey.job.enabled -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "matrix-synapse.signingKeylabels" -}}
{{ include "matrix-synapse.labels" . }}
app.kubernetes.io/component: "signingkey"
{{- end -}}