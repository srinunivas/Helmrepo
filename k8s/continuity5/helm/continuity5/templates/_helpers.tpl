{{/*
Expand the name of the chart.
*/}}
{{- define "continuity5.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the name of the chart for frontend.
*/}}
{{- define "continuity5.frontend.name" -}}
{{- $name := default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- printf "%s-%s" $name "frontend" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "continuity5.fullname" -}}
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
{{- define "continuity5.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "continuity5.labels" -}}
helm.sh/chart: {{ include "continuity5.chart" . }}
{{ include "continuity5.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: continuity5
{{- end }}

{{/*
Frontend labels
*/}}
{{- define "continuity5.frontend.labels" -}}
helm.sh/chart: {{ include "continuity5.chart" . }}
{{ include "continuity5.frontend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: continuity5
{{- end }}

{{/*
Selector labels
*/}}
{{- define "continuity5.selectorLabels" -}}
app.kubernetes.io/name: {{ include "continuity5.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Frontend Selector labels
*/}}
{{- define "continuity5.frontend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "continuity5.frontend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "continuity5.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "continuity5.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Create a subscribe configuration for dapr
*/}}
{{- define "continuity5.subscribe" -}}
[
  {
    "pubsubname": "{{ .dapr.pubsub }}",
    "topic": "{{ .input.topic }}",
    "route": "/api"
    {{- if and (hasKey .input "rawPayload") .input.rawPayload -}} 
    ,
    "metadata": {
      "rawPayload": "true"
    }
    {{- end }}
  }
]
{{- end }}


{{/*
Create shared part of backend configuration based on component
*/}}
{{- define "continuity5.sharedConfiguration" -}}
debugjob
tcp-nodelay yes
tmpdir "./tmp"
logstdout
nolog
verbose {{ .verbose }}
log-interface {{ join " " .logInterface }}
dynload ./bin32/linux/Pairing
dynload ./bin32/linux/Filtering
dynload ./bin32/linux/Routing
dynload ./bin32/linux/Http
{{- if and (hasKey . "logProfile") .logProfile }}
log-profile all
{{- end }}
{{- if hasKey . "unit" }}
set UNIT "{{ .applicationCode }}"
{{- end }}
{{- if hasKey . "applicationCode" }}
set APPLICATION "{{ .applicationCode }}"
{{- end }}
{{- if hasKey . "systemId" }}
{{- if hasKey .systemId "prefix" }}
set SYSTEMID_PREFIX "{{ .systemId.prefix }}"
{{- end }}
{{- if hasKey .systemId "pattern" }}
set SYSTEMID_PATTERN "{{ .systemId.pattern }}"
{{- end }}
{{- if hasKey .systemId "forceNew" }}
set FORCE_NEW_SYSTEMID? {{ .systemId.forceNew }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create a routing rule file based on a route variable
*/}}
{{- define "continuity5.routingRule" -}}
set ST_NOHIT       = 0
set ST_HITS        = 1
set ST_PASSED      = 2
set ST_FAILED      = 3
set ST_BYPASSMODE  = 4
set ST_RECHECK     = 5
set ST_NOTREVIEWED = 6
set ST_NONBLOCKING = 7
set ST_NONCHECKING = 8
set ST_CANCEL      = 9
set ST_UNQUEUE     = 10
set ST_CLOSE       = 11
set ST_PENDING     = 12
set ST_ERROR       = 100
set ST_NOMESSAGE   = 101
{{- range $routeKey, $route := index . "outputs" }}
routemap {{ $routeKey }} for {{ if and (hasKey $route "isGroup") $route.isGroup -}}group{{- end }} msg{{ if and (hasKey $route "isGroup") $route.isGroup -}}s{{- end }} {
  set msg.qdesc.URI = unknown
  {{ $route.predicate }}
  default {{ $routeKey }}
}
{{ end }}
{{- end }}

{{/*
Create input connection points based on a input variable
*/}}
{{- define "continuity5.inputConnectionPoint" -}}
http-server HTTP_SERVER {{ index .Values.podAnnotations "dapr.io/app-port" }} \
        document-root www \
        webservice-uri-prefix /api \
        accept-stack 10 \
        select-timeout 200 \ 
        num-thread 10 \
        dapr_unwrap_cloud_event
    #    ip-binding 127.0.0.1 \
    #    enable-keep-alive no \
set QIN HTTP_SERVER
set QERROR HTTP_SERVER
set TRANSACTION_SIZE 1
{{- end }}

{{/*
Create output connection points based on a route variable
*/}}
{{- define "continuity5.ouputConnectionPoints" -}}
set ROUTING_RULE_FILE "/fircosoft/config/routing.rule"
{{- range $routeKey, $route := index . "outputs" }}
http-client HTTP_CLIENT_{{ $routeKey }} 127.0.0.1 3500 \
{{- if and (hasKey $route "rawPayload") $route.rawPayload }}
  /v1.0/publish/{{ $.dapr.pubsub }}/{{ $route.topic }}?metadata.rawPayload=true \
  default-content-type application/octet-stream
{{- else }}
  /v1.0/publish/{{ $.dapr.pubsub }}/{{ $route.topic }} \
  default-content-type application/json \
  dapr_wrap_cloud_event
{{- end }}
{{- end }}
queue-map QOUTS ERROR:HTTP_SERVER:"original"
{{- range $routeKey, $route := index . "outputs" -}}
  \
  {{ $routeKey }}:HTTP_CLIENT_{{ $routeKey }}:"{{ $route.format }}"
{{- end -}}
{{- end -}}
