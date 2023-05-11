{{- define "namespace-on-boarding.name" -}}
{{- printf "%s-%s" .Values.namespace.project .Values.namespace.environment | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "flask-sample.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "namespace-on-boarding.labels" -}}
helm.sh/chart: {{ include "flask-sample.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
project: {{ .Values.namespace.project }}
environment: {{ .Values.namespace.environment }}
{{- end }}