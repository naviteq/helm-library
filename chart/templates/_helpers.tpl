{{/*
Create the name of the service account to use
*/}}
{{- define "library.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Render an array of env variables. The input can be a map or a slice.
Values can be templates using the "common.tplvalues.render" helper, but changes to scope are not processed.
Usage:
{{ include "library.toEnvArray" ( dict "envVars" .Values.envVars "context" $ ) }}
*/}}
{{- define "library.toEnvArray" -}}
{{- if kindIs "map" .envVars }}
{{- range $key, $val := .envVars }}
- name: {{ $key }}
{{- if kindIs "string" $val }}
  value: "{{ include "common.tplvalues.render" (dict "value" $val "context" $.context) }}"
{{- else if kindIs "map" $val }}
{{ include "common.tplvalues.render" (dict "value" (omit $val "name") "context" $.context) | indent 2 }}
{{- end -}}
{{- end -}}
{{- else if kindIs "slice" .envVars }}
{{ include "common.tplvalues.render" (dict "value" .envVars "context" $.context) }}
{{- end }}
{{- end -}}

{{/*
Internal helper — renders a single CRD resource document from a dict entry.
Used by ESO, KEDA, GCP, AWS, and Gateway API templates to avoid duplication.

Parameters (dict):
  name       - resource name suffix (will be prefixed with fullname)
  res        - the dict entry from values (with .labels, .annotations, .spec)
  kind       - Kubernetes Kind string
  apiVersion - full apiVersion string
  namespaced - bool; if true, namespace is added to metadata
  context    - the root Helm context ($)
*/}}
{{- define "library._crdResource" -}}
{{- $name := .name -}}
{{- $res := .res -}}
{{- $kind := .kind -}}
{{- $apiVersion := .apiVersion -}}
{{- $ctx := .context -}}
{{- $namespaced := .namespaced -}}
---
apiVersion: {{ $apiVersion }}
kind: {{ $kind }}
metadata:
  name: {{ printf "%s-%s" (include "common.names.fullname" $ctx) $name }}
  {{- if $namespaced }}
  namespace: {{ include "common.names.namespace" $ctx | quote }}
  {{- end }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" $ctx.Values.commonLabels "context" $ctx ) | nindent 4 }}
    {{- if $res.labels }}
    {{- include "common.tplvalues.render" ( dict "value" $res.labels "context" $ctx ) | nindent 4 }}
    {{- end }}
  {{- if or $ctx.Values.commonAnnotations $res.annotations }}
  annotations:
    {{- if $ctx.Values.commonAnnotations }}
    {{- include "common.tplvalues.render" ( dict "value" $ctx.Values.commonAnnotations "context" $ctx ) | nindent 4 }}
    {{- end }}
    {{- if $res.annotations }}
    {{- include "common.tplvalues.render" ( dict "value" $res.annotations "context" $ctx ) | nindent 4 }}
    {{- end }}
  {{- end }}
{{- if $res.spec }}
spec: {{- include "common.tplvalues.render" ( dict "value" $res.spec "context" $ctx ) | nindent 2 }}
{{- end }}
{{- end -}}

{{- define "library.image" -}}
{{- $registryName := default .imageRoot.registry ((.global).imageRegistry) -}}
{{- $repositoryName := .imageRoot.repository -}}
{{- $separator := ":" -}}
{{- $termination := .imageRoot.tag | toString -}}

{{- if not .imageRoot.tag }}
  {{- if .chart }}
    {{- $termination = .chart.AppVersion | toString -}}
  {{- end -}}
{{- end -}}
{{- if .imageRoot.digest }}
    {{- $separator = "@" -}}
    {{- $termination = .imageRoot.digest | toString -}}
{{- end -}}
{{- if $registryName }}
    {{- printf "%s/%s%s%s" $registryName $repositoryName $separator $termination -}}
{{- else -}}
    {{- printf "%s%s%s"  $repositoryName $separator $termination -}}
{{- end -}}
{{- end -}}
