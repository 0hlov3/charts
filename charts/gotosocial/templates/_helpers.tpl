{{/*
Expand the name of the chart.
*/}}
{{- define "gotosocial.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gotosocial.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gotosocial.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gotosocial.labels" -}}
helm.sh/chart: {{ include "gotosocial.chart" . }}
{{ include "gotosocial.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gotosocial.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gotosocial.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gotosocial.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "gotosocial.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "gotosocial.postgresql.fullname" -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{/*
Set postgres host
*/}}
{{- define "gotosocial.postgresql.host" -}}
{{- if .Values.postgresql.enabled -}}
{{- template "gotosocial.postgresql.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Create Volumeclaim Name
*/}}
{{- define "gotosocial.volume.claimName" -}}
{{- if and .Values.gotosocial.persistence.enabled (ne .Values.gotosocial.persistence.existingClaim "") -}}
{{ .Values.gotosocial.persistence.existingClaim }}
{{- else -}}
{{ printf "%s-%s" (include "gotosocial.fullname" .) "data" }}
{{- end -}}
{{- end -}}