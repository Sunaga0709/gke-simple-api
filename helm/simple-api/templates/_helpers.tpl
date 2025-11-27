{{- define "simple-api.name" -}}
simple-api
{{- end }}

{{- define "simple-api.fullname" -}}
{{ include "simple-api.name" . }}-{{ .Release.Name }}
{{- end }}
