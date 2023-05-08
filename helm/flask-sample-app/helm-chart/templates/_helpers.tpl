{{- define "flask-sample.name" -}}
{{- default .Chart.Name .Values.microservice.name | trimSuffix "-" }}
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
{{- define "flask-sample.labels" -}}
helm.sh/chart: {{ include "flask-sample.chart" . }}
{{ include "flask-sample.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
microservice: {{ .Values.microservice.name }}
environment: {{ .Values.microservice.environment }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "flask-sample.selectorLabels" -}}
app.kubernetes.io/name: {{ include "flask-sample.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
microservice: {{ .Values.microservice.name }}
environment: {{ .Values.microservice.environment }}
{{- end }}

{{/*
Deployment annotations
*/}}
{{- define "flask-sample.deployment.annotations" -}}
{{- if .Values.prometheusMetrics }}
prometheus.io/path: "/metrics"
prometheus.io/scheme: "http"
prometheus.io/scrape: "true"
prometheus.io/port: "{{ .Values.microservice.port }}"
{{- end }}
{{- end }}

{{/*
Ingress annotations
*/}}
{{- define "flask-sample.ingress.annotations" -}}
acme.cert-manager.io/http01-edit-in-place: 'true'
cert-manager.io/cluster-issuer: letsencrypt-prod
kubernetes.io/tls-acme: 'true'
nginx.ingress.kubernetes.io/force-ssl-redirect: 'true'
{{- end }}

{{- define "flask-sample.basek8sdomain" -}}
k8s.stavco9.com
{{- end }}