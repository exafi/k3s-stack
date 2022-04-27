{{/*
This template serves as a blueprint for all PersistentVolumeClaim objects that are created
within the common library.
*/}}
{{- define "seaweedfs.classes.local-ca" -}}
{{- $values := .Values.persistence -}}
{{- if hasKey . "ObjectValues" -}}
  {{- with .ObjectValues.issuer -}}
    {{- $values = . -}}
  {{- end -}}
{{ end -}}
{{- $name := include "common.names.fullname" . -}}
{{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
  {{- if not (eq $values.nameOverride "-") -}}
    {{- $name = printf "%v-%v" $name $values.nameOverride -}}
  {{ end -}}
{{ end }}
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: {{ $name }}-selfsigned-issuer
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: {{ $name }}
spec:
  isCA: true
  commonName: {{ $name }}
  secretName: {{ $name }}-secret
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: {{ $name }}-selfsigned-issuer
    kind: Issuer
    group: cert-manager.io
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: {{ $name }}-issuer
spec:
  ca:
    secretName: {{ $name }}-secret
{{ end -}}
