{{/*
Chart name and fullname
*/}}
{{- define "garage.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "garage.fullname" -}}
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

{{- define "garage.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "garage.labels" -}}
helm.sh/chart: {{ include "garage.chart" . }}
{{ include "garage.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "garage.selectorLabels" -}}
app.kubernetes.io/name: {{ include "garage.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Name of the ServiceAccount to use.
*/}}
{{- define "garage.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- $baseName := .Values.serviceAccount.name | default (printf "sa-%s" (include "garage.fullname" .)) -}}
{{- $baseName | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Names for the ingress / HTTPRoute objects (prefixed for readability, overridable
via .Values.<kind>.name). These name the routing object only — the backend still
targets the Service (garage.fullname).
*/}}
{{- define "garage.ingressName" -}}
{{- $baseName := .Values.ingress.name | default (printf "ingress-%s" (include "garage.fullname" .)) -}}
{{- $baseName | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "garage.httpRouteName" -}}
{{- $baseName := .Values.httpRoute.name | default (printf "httproute-%s" (include "garage.fullname" .)) -}}
{{- $baseName | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Auto-generated RPC secret (inter-node clustering auth; loopback-only on a single
node, so it is never consumed externally). `lookup` reuses the previously stored
value on `helm upgrade` to avoid a needless Secret diff — this is churn
avoidance, not a correctness requirement: the node's identity and cluster layout
live in the metadata volume, independent of this secret, so regenerating it does
not lose data or orphan the layout. The admin_token, by contrast, is a required,
operator-provided value (see admin.token) so it is known up front.
*/}}
{{- define "garage.rpcSecret" -}}
{{- $existing := (lookup "v1" "Secret" .Release.Namespace (include "garage.fullname" .)) -}}
{{- if $existing -}}
{{- index $existing.data "rpc_secret" | b64dec -}}
{{- else -}}
{{- sha256sum (printf "%s-rpc-%s" .Release.Name (randAlphaNum 32)) -}}
{{- end -}}
{{- end }}
