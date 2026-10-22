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
not lose data or orphan the layout.
*/}}
{{- define "garage.rpcSecret" -}}
{{- $existing := (lookup "v1" "Secret" .Release.Namespace (include "garage.fullname" .)) | default dict -}}
{{- $data := $existing.data | default dict -}}
{{- if hasKey $data "rpc_secret" -}}
{{- index $data "rpc_secret" | b64dec -}}
{{- else -}}
{{- sha256sum (printf "%s-rpc-%s" .Release.Name (randAlphaNum 32)) -}}
{{- end -}}
{{- end }}

{{/*
Whether .Values.environment sets GARAGE_<name> or GARAGE_<name>_FILE itself,
e.g. to read a secret from a mounted file. Garage refuses to start when both the
plain and the _FILE variable are set, so the chart then leaves that secret to
the environment. Call with (dict "root" $ "name" "ADMIN_TOKEN").
*/}}
{{- define "garage.envSets" -}}
{{- $names := list (printf "GARAGE_%s" .name) (printf "GARAGE_%s_FILE" .name) -}}
{{- range .root.Values.environment -}}
{{- if has .name $names }}true{{ end -}}
{{- end -}}
{{- end }}

{{/*
Whether the chart generates the RPC secret and stores it in its own Secret.
*/}}
{{- define "garage.rpcSecretFromChart" -}}
{{- if not (or .Values.garage.existingRpcSecret.name (include "garage.envSets" (dict "root" . "name" "RPC_SECRET"))) }}true{{ end -}}
{{- end }}

{{/*
Secrets are never values of this chart: they come from an existing Secret or
from .Values.environment, and each from at most one of them. Only the generated
RPC secret is stored in the chart's own Secret.
*/}}
{{- define "garage.validateSecrets" -}}
{{- if and .Values.garage.existingRpcSecret.name (include "garage.envSets" (dict "root" . "name" "RPC_SECRET")) -}}
{{- fail "set either garage.existingRpcSecret.name or GARAGE_RPC_SECRET(_FILE) in environment, not both" -}}
{{- end -}}
{{- if and .Values.admin.existingSecret.name (include "garage.envSets" (dict "root" . "name" "ADMIN_TOKEN")) -}}
{{- fail "set either admin.existingSecret.name or GARAGE_ADMIN_TOKEN(_FILE) in environment, not both" -}}
{{- end -}}
{{- if and .Values.bootstrap.enabled (not .Values.bootstrap.existingSecret.name) -}}
{{- fail "bootstrap.existingSecret.name is required when bootstrap.enabled=true" -}}
{{- end -}}
{{- end }}
