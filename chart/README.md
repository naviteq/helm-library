# naviteq-library-chart

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: library](https://img.shields.io/badge/Type-library-informational?style=flat-square)

Naviteq reusable Helm chart

## Usage

Add as a dependency in `Chart.yaml`:

```yaml
dependencies:
  - name: naviteq-helm-library
    version: "*"
    repository: "oci://../chart"
    import-values:
      - defaults
```

Call the single entry point in your `templates/app.yaml`:

```yaml
{{ include "library.app" . }}
```

## Values

### Global

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.imageRegistry` | Global Docker image registry | `""` |
| `global.imagePullSecrets` | Global Docker registry secret names | `[]` |
| `global.storageClass` | Global StorageClass for Persistent Volumes | `""` |

### Common

| Parameter | Description | Default |
|-----------|-------------|---------|
| `kubeVersion` | Force target Kubernetes version | `""` |
| `nameOverride` | Partial override of the fullname template | `""` |
| `fullnameOverride` | Full override of the fullname template | `""` |
| `namespaceOverride` | Full override of the namespace | `""` |
| `clusterDomain` | Kubernetes cluster domain | `cluster.local` |
| `annotations` | Additional annotations on the Deployment/StatefulSet | `{}` |
| `labels` | Additional labels on the Deployment/StatefulSet | `{project: demo}` |
| `commonLabels` | Labels added to all deployed resources | `{}` |
| `commonAnnotations` | Annotations added to all deployed resources | `{}` |

### Image

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.registry` | Image registry | `docker.io` |
| `image.repository` | Image repository | `""` |
| `image.tag` | Image tag | `""` |
| `image.digest` | Image digest — overrides tag if set | `""` |
| `image.pullPolicy` | Image pull policy | `null` (auto-detect) |
| `image.pullSecrets` | Image pull secret names | `[]` |

### Workload

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `revisionHistoryLimit` | Old ReplicaSets to retain | `30` |
| `command` | Override container command | `[]` |
| `args` | Override container args | `[]` |
| `updateStrategy.type` | Deployment strategy (`RollingUpdate`, `Recreate`) | `RollingUpdate` |
| `updateStrategy.rollingUpdate` | Rolling update config | `{}` |
| `podRestartPolicy` | Pod restart policy | `Always` |
| `terminationGracePeriodSeconds` | Grace period for pod termination | `""` |
| `priorityClassName` | Pod priority class name | `""` |
| `schedulerName` | Alternate scheduler name | `""` |
| `hostAliases` | Additional `/etc/hosts` entries | `[]` |

### Diagnostic mode

| Parameter | Description | Default |
|-----------|-------------|---------|
| `diagnosticMode.enabled` | Disable all probes and override command | `false` |
| `diagnosticMode.command` | Command override | `[sleep]` |
| `diagnosticMode.args` | Args override | `[infinity]` |

### Ports

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ports` | Container ports to expose | `[{name: http, containerPort: 8080, protocol: TCP}]` |

### Probes

All three probes share the same structure — set `enabled: true` and add probe spec fields directly.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `livenessProbe.enabled` | Enable liveness probe | `false` |
| `readinessProbe.enabled` | Enable readiness probe | `false` |
| `startupProbe.enabled` | Enable startup probe | `false` |

```yaml
livenessProbe:
  enabled: true
  httpGet:
    path: /healthz
    port: http
  initialDelaySeconds: 10
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3
  successThreshold: 1
```

### Security contexts

| Parameter | Description | Default |
|-----------|-------------|---------|
| `podSecurityContext.enabled` | Enable pod-level security context | `false` |
| `podSecurityContext.fsGroup` | fsGroup | `0` |
| `containerSecurityContext.enabled` | Enable container-level security context | `false` |
| `containerSecurityContext.runAsUser` | UID to run the container as | `1001` |
| `containerSecurityContext.runAsNonRoot` | Require non-root user | `true` |

### Resources

> **`resources.requests.cpu` and `resources.requests.memory` are required** — the chart will fail without them.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.requests` | Resource requests | `{}` |
| `resources.limits` | Resource limits | `{}` |

### Environment variables

| Parameter | Description | Default |
|-----------|-------------|---------|
| `envVars` | Key-value env vars (supports `valueFrom`) | `null` |
| `envVarsConfigMap` | ConfigMap to inject as env vars | `""` |
| `envVarsSecret` | Secret to inject as env vars | `""` |

### Scheduling

| Parameter | Description | Default |
|-----------|-------------|---------|
| `nodeSelector` | Node labels for pod assignment | `{}` |
| `tolerations` | Tolerations | `[]` |
| `affinity` | Full affinity spec (overrides presets below) | `{}` |
| `podAffinityPreset` | Pod affinity preset (`soft`, `hard`) | `""` |
| `podAntiAffinityPreset` | Pod anti-affinity preset (`soft`, `hard`) | `soft` |
| `nodeAffinityPreset.type` | Node affinity preset type (`soft`, `hard`) | `""` |
| `nodeAffinityPreset.key` | Node label key to match | `""` |
| `nodeAffinityPreset.values` | Node label values to match | `[]` |
| `topologySpreadConstraints` | Topology spread constraints | `[]` |

### Pod metadata

| Parameter | Description | Default |
|-----------|-------------|---------|
| `podLabels` | Additional pod labels | `{}` |
| `podAnnotations` | Additional pod annotations | `{}` |

### Extra workload config

| Parameter | Description | Default |
|-----------|-------------|---------|
| `extraVolumes` | Extra volumes | `[]` |
| `extraVolumeMounts` | Extra volume mounts for the main container | `[]` |
| `sidecars` | Additional sidecar containers | `[]` |
| `initContainers` | Additional init containers | `[]` |
| `lifecycleHooks` | Lifecycle hooks for the main container | `{}` |

### StatefulSet

Set `statefulSet.enabled: true` to use a StatefulSet instead of a Deployment. All pod-level config (resources, affinity, probes, volumes) is shared.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `statefulSet.enabled` | Use StatefulSet instead of Deployment | `false` |
| `statefulSet.serviceName` | Headless Service name (defaults to fullname) | `""` |
| `statefulSet.podManagementPolicy` | `OrderedReady` or `Parallel` | `OrderedReady` |
| `statefulSet.minReadySeconds` | Minimum seconds a new pod must be ready | `0` |
| `statefulSet.ordinals` | Pod ordinal numbering config (k8s 1.26+) | `{}` |
| `statefulSet.persistentVolumeClaimRetentionPolicy` | PVC retention policy (k8s 1.23+) | `{}` |
| `statefulSet.volumeClaimTemplates` | PVC templates; include `mountPath` for container mounts | `[]` |

### ConfigMaps

Dict-keyed. Each key creates one ConfigMap named `<fullname>-<key>`.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `configMaps.<name>.data` | Key-value data | `{}` |
| `configMaps.<name>.mounted` | Mount into the container | `false` |
| `configMaps.<name>.mountPath` | Mount path inside the container | `""` |
| `configMaps.<name>.subPath` | Mount a single key as a file | `""` |
| `configMaps.<name>.annotations` | Additional annotations | `{}` |
| `configMaps.<name>.labels` | Additional labels | `{}` |

### Secret

A single managed Secret per release.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `secret.type` | Secret type | `Opaque` |
| `secret.data` | Base64-encoded key-value pairs | `{}` |
| `secret.stringData` | Plain-text key-value pairs (encoded by Kubernetes) | `{}` |
| `secret.mounted` | Mount into the container | `false` |
| `secret.mountPath` | Mount path | `""` |
| `secret.subPath` | Mount a single key as a file | `""` |
| `secret.defaultMode` | File permission bits for mounted files (octal) | `null` |
| `secret.items` | Project specific keys to specific paths | `[]` |
| `secret.annotations` | Additional annotations | `{}` |
| `secret.labels` | Additional labels | `{}` |

### Service

> The Service renders only if both `ports` and `service.ports` are non-empty.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.ports` | Port definitions | `[{name: http, protocol: TCP, port: 80, targetPort: http}]` |
| `service.sessionAffinity` | `ClientIP` or `None` | `None` |
| `service.clusterIP` | Static cluster IP | `""` |
| `service.loadBalancerIP` | Load balancer IP | `""` |
| `service.loadBalancerSourceRanges` | Allowed source CIDR ranges | `[]` |
| `service.externalTrafficPolicy` | External traffic policy | `Cluster` |
| `service.annotations` | Additional annotations | `{}` |
| `service.test` | Path for Helm test probe | `/` |

### Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable Ingress | `false` |
| `ingress.hostname` | Default hostname | `app.local` |
| `ingress.path` | Default path | `/` |
| `ingress.pathType` | Path type | `ImplementationSpecific` |
| `ingress.apiVersion` | Override API version | `""` |
| `ingress.ingressClassName` | IngressClass name | `""` |
| `ingress.tls` | Enable TLS for the default hostname | `false` |
| `ingress.selfSigned` | Generate self-signed TLS cert | `false` |
| `ingress.existingSecret` | Existing TLS secret name | `""` |
| `ingress.annotations` | Additional annotations | `{}` |
| `ingress.extraHosts` | Additional hostnames | `[]` |
| `ingress.extraPaths` | Additional paths under the main host | `[]` |
| `ingress.extraTls` | TLS config for additional hostnames | `[]` |
| `ingress.extraRules` | Additional ingress rules | `[]` |
| `ingress.secrets` | TLS secrets to create | `[]` |

### HorizontalPodAutoscaler

> When `keda.scaledObjects` is non-empty, HPA is automatically suppressed.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `autoscaling.enabled` | Deploy an HPA | `false` |
| `autoscaling.minReplicas` | Minimum replicas | `1` |
| `autoscaling.maxReplicas` | Maximum replicas | `5` |
| `autoscaling.targetCPU` | CPU utilization target (%) | `80` |
| `autoscaling.targetMemory` | Memory utilization target (%) | `80` |
| `autoscaling.metrics` | Additional custom metrics | `[]` |

### PodDisruptionBudget

| Parameter | Description | Default |
|-----------|-------------|---------|
| `pdb.create` | Create a PDB | `true` |
| `pdb.minAvailable` | Min pods available (int or percentage) | `""` |
| `pdb.maxUnavailable` | Max pods unavailable (int or percentage); defaults to `1` when both are empty | `""` |

### ServiceAccount

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceAccount.create` | Create a ServiceAccount | `false` |
| `serviceAccount.name` | Name (auto-generated when `create: true` and empty) | `""` |
| `serviceAccount.automountServiceAccountToken` | Auto-mount the service account token | `true` |
| `serviceAccount.annotations` | Additional annotations | `{}` |
| `serviceAccount.labels` | Additional labels | `{}` |

### RBAC

| Parameter | Description | Default |
|-----------|-------------|---------|
| `rbac.create` | Create RBAC resources | `false` |
| `rbac.rules` | Rules for the Role (namespace-scoped); empty = no Role/RoleBinding | `[]` |
| `rbac.clusterRules` | Rules for the ClusterRole (cluster-scoped); empty = no ClusterRole | `[]` |
| `rbac.extraSubjects` | Additional subjects for RoleBinding/ClusterRoleBinding | `[]` |
| `rbac.annotations` | Additional annotations | `{}` |
| `rbac.labels` | Additional labels | `{}` |

### ServiceMonitor

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceMonitor.enabled` | Deploy a Prometheus Operator ServiceMonitor | `false` |
| `serviceMonitor.namespace` | Namespace where Prometheus is running | `""` |
| `serviceMonitor.labels` | Additional labels | `{}` |
| `serviceMonitor.annotations` | Additional annotations | `{}` |
| `serviceMonitor.jobLabel` | Label on the target service used as the Prometheus job name | `""` |
| `serviceMonitor.honorLabels` | Honor metric labels on collisions | `false` |
| `serviceMonitor.interval` | Scrape interval | `""` |
| `serviceMonitor.scrapeTimeout` | Scrape timeout | `""` |
| `serviceMonitor.port` | Port to scrape | `http` |
| `serviceMonitor.path` | Metrics path | `/metrics` |
| `serviceMonitor.metricRelabelings` | Metric relabeling rules | `[]` |
| `serviceMonitor.relabelings` | General relabeling rules | `[]` |
| `serviceMonitor.selector` | Prometheus instance selector labels | `{}` |
| `serviceMonitor.namespaceSelector` | Namespace selector | `{}` |

### PodMonitor

| Parameter | Description | Default |
|-----------|-------------|---------|
| `podMonitor.enabled` | Deploy a Prometheus Operator PodMonitor | `false` |
| `podMonitor.namespace` | Namespace where Prometheus is running | `""` |
| `podMonitor.jobLabel` | Job label | `""` |
| `podMonitor.port` | Port to scrape | `http` |
| `podMonitor.path` | Metrics path | `/metrics` |
| `podMonitor.interval` | Scrape interval | `30s` |
| `podMonitor.scrapeTimeout` | Scrape timeout | `10s` |
| `podMonitor.labels` | Additional labels | `{}` |
| `podMonitor.relabelings` | General relabeling rules | `{}` |
| `podMonitor.metricRelabelings` | Metric relabeling rules | `[]` |
| `podMonitor.namespaceSelector` | Namespace selector | `{}` |
| `podMonitor.selector` | Pod selector | `{}` |

---

## External Secrets Operator (ESO)

All ESO resources are disabled by default (empty dict = no resources rendered). Each dict key becomes the resource name suffix: `<fullname>-<key>`. Every entry accepts `.labels`, `.annotations`, and `.spec`.

ref: https://external-secrets.io/latest/

| Parameter | Kind | apiVersion | Scope | Default |
|-----------|------|------------|-------|---------|
| `eso.externalSecrets` | ExternalSecret | `external-secrets.io/v1` | namespaced | `{}` |
| `eso.secretStores` | SecretStore | `external-secrets.io/v1` | namespaced | `{}` |
| `eso.clusterSecretStores` | ClusterSecretStore | `external-secrets.io/v1` | cluster | `{}` |
| `eso.clusterExternalSecrets` | ClusterExternalSecret | `external-secrets.io/v1` | cluster | `{}` |
| `eso.pushSecrets` | PushSecret | `external-secrets.io/v1alpha1` | namespaced | `{}` |
| `eso.clusterPushSecrets` | ClusterPushSecret | `external-secrets.io/v1alpha1` | cluster | `{}` |

### ESO Generators

All `generators.external-secrets.io/v1alpha1` unless noted.

| Parameter | Kind | Scope | Default |
|-----------|------|-------|---------|
| `eso.generators.acrAccessToken` | ACRAccessToken | namespaced | `{}` |
| `eso.generators.ecrAuthorizationTokens` | ECRAuthorizationToken | namespaced | `{}` |
| `eso.generators.stsSessionTokens` | STSSessionToken | namespaced | `{}` |
| `eso.generators.gcrAccessTokens` | GCRAccessToken | namespaced | `{}` |
| `eso.generators.passwords` | Password | namespaced | `{}` |
| `eso.generators.fakes` | Fake | namespaced | `{}` |
| `eso.generators.uuids` | UUID | namespaced | `{}` |
| `eso.generators.clusterGenerators` | ClusterGenerator (`external-secrets.io/v1alpha1`) | cluster | `{}` |

---

## KEDA

All resource dicts are disabled by default. Each dict key becomes `<fullname>-<key>`. When `keda.scaledObjects` is non-empty, `autoscaling` (HPA) is automatically suppressed.

ref: https://keda.sh/docs/latest/

| Parameter | Kind | apiVersion | Scope | Default |
|-----------|------|------------|-------|---------|
| `keda.scaledObjects` | ScaledObject | `keda.sh/v1alpha1` | namespaced | `{}` |
| `keda.scaledJobs` | ScaledJob | `keda.sh/v1alpha1` | namespaced | `{}` |
| `keda.triggerAuthentications` | TriggerAuthentication | `keda.sh/v1alpha1` | namespaced | `{}` |
| `keda.clusterTriggerAuthentications` | ClusterTriggerAuthentication | `keda.sh/v1alpha1` | cluster | `{}` |

---

## GCP (Google Kubernetes Engine)

All disabled by default. Each dict key becomes `<fullname>-<key>`.

| Parameter | Kind | apiVersion | Scope | Default |
|-----------|------|------------|-------|---------|
| `gcp.backendConfigs` | BackendConfig | `cloud.google.com/v1` | namespaced | `{}` |
| `gcp.frontendConfigs` | FrontendConfig | `networking.gke.io/v1beta1` | namespaced | `{}` |
| `gcp.managedCertificates` | ManagedCertificate | `networking.gke.io/v1` | namespaced | `{}` |

**BackendConfig** — CDN, security policies, IAP, connection draining, timeouts per Service port. Associate via annotation: `cloud.google.com/backend-config: '{"default": "<fullname>-<key>"}'`

**FrontendConfig** — SSL policies, HTTP→HTTPS redirects. Associate via annotation: `networking.gke.io/v1beta1.FrontendConfig: <fullname>-<key>`

**ManagedCertificate** — GCP-managed TLS certs provisioned and renewed automatically. Associate via annotation: `networking.gke.io/managed-certificates: <fullname>-<key>`

---

## AWS (Elastic Kubernetes Service)

All disabled by default. Each dict key becomes `<fullname>-<key>`.

| Parameter | Kind | apiVersion | Scope | Default |
|-----------|------|------------|-------|---------|
| `aws.eniConfigs` | ENIConfig | `crd.k8s.amazonaws.com/v1alpha1` | cluster | `{}` |
| `aws.ingressClassParams` | IngressClassParams | `elbv2.k8s.aws/v1beta1` | cluster | `{}` |
| `aws.targetGroupBindings` | TargetGroupBinding | `elbv2.k8s.aws/v1beta1` | namespaced | `{}` |
| `aws.securityGroupPolicies` | SecurityGroupPolicy | `vpcresources.k8s.aws/v1beta1` | namespaced | `{}` |

**ENIConfig** — Custom networking: maps an availability zone to a specific subnet and security groups for secondary pod ENIs. Requires `AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true` on the `aws-node` DaemonSet.

**IngressClassParams** — AWS Load Balancer Controller ingress class config: scheme, IP address type, load balancer attributes, tags. Reference from an IngressClass via `spec.parameters.apiGroup: elbv2.k8s.aws`.

**TargetGroupBinding** — Binds a Kubernetes Service to an existing AWS Target Group, allowing an ALB/NLB managed outside Kubernetes to route traffic to pod IPs.

**SecurityGroupPolicy** — Assigns AWS Security Groups to pods by label selector. Requires `ENABLE_POD_ENI=true` on the `aws-node` DaemonSet and the VPC Resource Controller add-on.

---

## Kubernetes Gateway API

All disabled by default. Each dict key becomes `<fullname>-<key>`.

| Parameter | Kind | apiVersion | Scope | Default |
|-----------|------|------------|-------|---------|
| `apiGateway.gateways` | Gateway | `gateway.networking.k8s.io/v1` | namespaced | `{}` |
| `apiGateway.httpRoutes` | HTTPRoute | `gateway.networking.k8s.io/v1` | namespaced | `{}` |
| `apiGateway.tlsRoutes` | TLSRoute | `gateway.networking.k8s.io/v1alpha2` | namespaced | `{}` |
| `apiGateway.tcpRoutes` | TCPRoute | `gateway.networking.k8s.io/v1alpha2` | namespaced | `{}` |
| `apiGateway.grpcRoutes` | GRPCRoute | `gateway.networking.k8s.io/v1` | namespaced | `{}` |

ref: https://gateway-api.sigs.k8s.io/

---

## Production preset

`exports.production` is a ready-made overlay with HA settings. Consumer charts can selectively merge it into their own values.

> `resources.requests.cpu` and `resources.requests.memory` must always be set explicitly per workload — the preset intentionally does not provide them.

| Parameter | Preset value |
|-----------|-------------|
| `replicaCount` | `2` |
| `revisionHistoryLimit` | `5` |
| `podAntiAffinityPreset` | `hard` |
| `updateStrategy.type` | `RollingUpdate` |
| `updateStrategy.rollingUpdate.maxSurge` | `1` |
| `updateStrategy.rollingUpdate.maxUnavailable` | `0` |
| `terminationGracePeriodSeconds` | `60` |
| `podSecurityContext.enabled` | `true` |
| `podSecurityContext.fsGroup` | `1001` |
| `podSecurityContext.runAsNonRoot` | `true` |
| `podSecurityContext.seccompProfile.type` | `RuntimeDefault` |
| `containerSecurityContext.enabled` | `true` |
| `containerSecurityContext.runAsUser` | `1001` |
| `containerSecurityContext.runAsNonRoot` | `true` |
| `containerSecurityContext.readOnlyRootFilesystem` | `true` |
| `containerSecurityContext.allowPrivilegeEscalation` | `false` |
| `containerSecurityContext.capabilities.drop` | `[ALL]` |
| `pdb.create` | `true` |
| `pdb.minAvailable` | `1` |
| `autoscaling.minReplicas` | `2` |
| `autoscaling.maxReplicas` | `10` |
| `autoscaling.targetCPU` | `70` |
| `autoscaling.targetMemory` | `80` |
