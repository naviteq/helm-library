{{- /* Rule groups for monitoring.alertRules.<key>.groupsTemplate; thresholds come from values. */}}
{{- define "test-consumer.ruleGroups" -}}
groups:
  - name: test-consumer-thresholds
    rules:
      - alert: TestConsumerErrorRatioHigh
        expr: rate(http_errors_total[5m]) / rate(http_requests_total[5m]) > {{ .Values.errorRatio | default 0.05 }}
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: {{ `"{{ $labels.instance }} error ratio above threshold"` }}
{{- end -}}
