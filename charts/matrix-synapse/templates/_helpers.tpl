{{/*
Expand the name of the chart.
*/}}
{{- define "matrix-synapse.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default worker name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "matrix-synapse.workername" -}}
{{- printf "%s-%s" .global.Release.Name .worker | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "matrix-synapse.fullname" -}}
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
{{- define "matrix-synapse.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "matrix-synapse.labels" -}}
helm.sh/chart: {{ include "matrix-synapse.chart" . }}
{{ include "matrix-synapse.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "matrix-synapse.selectorLabels" -}}
app.kubernetes.io/name: {{ include "matrix-synapse.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "matrix-synapse.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "matrix-synapse.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "matrix-synapse.redis.fullname" -}}
{{- printf "%s-%s" .Release.Name "redis" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Set redis host
*/}}
{{- define "matrix-synapse.redis.host" -}}
{{- if .Values.redis.enabled -}}
{{- printf "%s-%s" (include "matrix-synapse.redis.fullname" .) "master" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{ required "A valid externalRedis.host is required" .Values.externalRedis.host }}
{{- end -}}
{{- end -}}

{{/*
Set redis secret
*/}}
{{- define "matrix-synapse.redis.secret" -}}
{{- if .Values.redis.enabled -}}
{{- template "matrix-synapse.redis.fullname" . -}}
{{- else -}}
{{- template "matrix-synapse.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Set redis port
*/}}
{{- define "matrix-synapse.redis.port" -}}
{{- if .Values.redis.enabled -}}
{{- .Values.redis.master.service.port | default 6379 }}
{{- else -}}
{{ required "A valid externalRedis.port is required" .Values.externalRedis.port }}
{{- end -}}
{{- end -}}