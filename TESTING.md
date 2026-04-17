# Testing

This chart is a **Helm library** — it cannot be rendered directly. Testing happens through
`test-consumer/`, a minimal consumer chart that depends on the library via a local `file://`
reference.

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Helm | ≥ 3.12 | https://helm.sh/docs/intro/install/ |
| helm-unittest plugin | ≥ 1.0 | `helm plugin install https://github.com/helm-unittest/helm-unittest` |
| kubeconform | any | `brew install kubeconform` |
| task | any | `brew install go-task` |

## Setup (once)

Download chart dependencies before running tests for the first time, or after changing `Chart.yaml`:

```bash
task setup
```

This runs `helm dependency update` for both `chart/` (downloads Bitnami Common) and
`test-consumer/` (links the library chart and imports its default values).

> The `charts/` directories are build artifacts and are git-ignored.

## Running tests

```bash
# Full suite: lint + unit tests + schema validation
task test

# Individual steps
task lint          # helm lint the library chart
task unit-test     # helm-unittest (logic and structure)
task validate      # kubeconform (Kubernetes schema validation)

# Render all templates with every feature enabled (visual inspection)
task template

# Override Kubernetes version for schema validation (default: 1.34.0)
task validate K8S_VERSION=1.30.0
```

## Test layers

| Layer | Tool | What it checks |
|-------|------|----------------|
| `task lint` | `helm lint` | Template syntax, required fields |
| `task unit-test` | `helm-unittest` | Resource presence/absence, values, required validation |
| `task validate` | `kubeconform` | Every rendered field matches the official k8s schema |

### Why three layers?

- **lint** catches Helm template errors early (e.g. malformed YAML, missing values)
- **unit-test** verifies chart logic (e.g. "HPA only renders when `autoscaling.enabled: true`")
- **validate** confirms the rendered YAML is valid Kubernetes — catches wrong field names,
  wrong types, or invalid structures that lint and unit tests cannot detect

## Test structure

```
test-consumer/
  ci/                              # Values files (scenarios)
    01-defaults.yaml               # Minimum required: image + resources
    02-statefulset.yaml            # StatefulSet mode with a PVC
    03-full.yaml                   # Every feature enabled at once
    04-eso.yaml                    # All ESO resource types + generators
    05-keda.yaml                   # All KEDA resource types
    06-gcp.yaml                    # GCP/GKE-specific resources
    07-aws.yaml                    # AWS/EKS-specific resources
    08-gateway.yaml                # Kubernetes Gateway API resources
  tests/                           # helm-unittest suites
    deployment_test.yaml           # Deployment rendering, image, replicas, required validation
    statefulset_test.yaml          # StatefulSet, volumeClaimTemplates, container mounts
    service_ingress_test.yaml      # Service, Ingress, PodDisruptionBudget
    rbac_test.yaml                 # ServiceAccount, Role, RoleBinding, ClusterRole, ClusterRoleBinding
    config_test.yaml               # ConfigMap, Secret, HorizontalPodAutoscaler
    external_secrets_test.yaml     # ESO: ExternalSecret, SecretStore, ClusterSecretStore, etc.
    keda_test.yaml                 # KEDA: ScaledObject, ScaledJob, TriggerAuthentication
    gcp_test.yaml                  # GCP: BackendConfig, FrontendConfig, ManagedCertificate
    aws_test.yaml                  # AWS: ENIConfig, IngressClassParams, TargetGroupBinding, SecurityGroupPolicy
    gateway_test.yaml              # Gateway API: Gateway, HTTPRoute, TLSRoute, TCPRoute, GRPCRoute
```

### Values files

| File | Purpose | Doc count |
|------|---------|-----------|
| `ci/01-defaults.yaml` | Minimal scenario (image + resources only) | 3 |
| `ci/02-statefulset.yaml` | StatefulSet mode with a PVC | 3 |
| `ci/03-full.yaml` | All standard features on | 13 |
| `ci/04-eso.yaml` | All ESO resource types + 12 generators | 22 |
| `ci/05-keda.yaml` | All KEDA resource types | 7 |
| `ci/06-gcp.yaml` | GCP/GKE-specific CRDs | 6 |
| `ci/07-aws.yaml` | AWS/EKS-specific CRDs | 7 |
| `ci/08-gateway.yaml` | Kubernetes Gateway API CRDs | 8 |

Document order for `ci/01-defaults.yaml`: Deployment(0) → PDB(1) → Service(2)
Document order for `ci/02-statefulset.yaml`: StatefulSet(0) → PDB(1) → Service(2)

### Assertion strategy

- **`containsDocument`** — checks a document with the given `kind` + `apiVersion` exists.
  Always include `apiVersion` and `any: true`, otherwise the assertion only checks document 0.
- **`hasDocuments: count: N`** — used to assert a resource is absent by verifying the total
  document count stays at the expected baseline (3 for minimal, 13 for full).
- **`equal` with `documentIndex`** — used only in the minimal `ci/01-defaults.yaml` and
  `ci/02-statefulset.yaml` scenarios where document order is fixed and predictable.
- **`isKind` with `documentIndex`** — used to assert workload type (Deployment vs StatefulSet).
- **`failedTemplate`** — verifies that Helm fails with the expected error when required values
  (`resources.requests.memory`, `resources.requests.cpu`) are missing.

### Known apiVersions

| Kind | apiVersion |
|------|------------|
| ConfigMap, Secret, ServiceAccount, Service | `v1` |
| Deployment, StatefulSet | `apps/v1` |
| PodDisruptionBudget | `policy/v1` |
| HorizontalPodAutoscaler | `autoscaling/v2` |
| Ingress | `networking.k8s.io/v1` |
| Role, RoleBinding, ClusterRole, ClusterRoleBinding | `rbac.authorization.k8s.io/v1` |
| ExternalSecret, SecretStore, ClusterSecretStore, ClusterExternalSecret, PushSecret, ClusterPushSecret | `external-secrets.io/v1` |
| ScaledObject, ScaledJob, TriggerAuthentication, ClusterTriggerAuthentication | `keda.sh/v1alpha1` |
| BackendConfig | `cloud.google.com/v1` |
| FrontendConfig | `networking.gke.io/v1beta1` |
| ManagedCertificate | `networking.gke.io/v1` |
| ENIConfig | `crd.k8s.amazonaws.com/v1alpha1` |
| IngressClassParams | `elbv2.k8s.aws/v1beta1` |
| TargetGroupBinding | `elbv2.k8s.aws/v1beta1` |
| SecurityGroupPolicy | `vpcresources.k8s.aws/v1beta1` |
| Gateway | `gateway.networking.k8s.io/v1` |
| HTTPRoute, GRPCRoute | `gateway.networking.k8s.io/v1` |
| TLSRoute, TCPRoute | `gateway.networking.k8s.io/v1alpha2` |
| ACRAccessToken, ECRAuthorizationToken, STSSessionToken, GCRAccessToken, GithubAccessToken, VaultDynamicSecret, Webhook, Password, MFA, SSHKey, Fake, UUID, ClusterGenerator | `generators.external-secrets.io/v1alpha1` |

## Run a single test suite

```bash
helm unittest test-consumer/ --file tests/deployment_test.yaml
helm unittest test-consumer/ --file tests/external_secrets_test.yaml
helm unittest test-consumer/ --file tests/gateway_test.yaml
```

## Adding tests for a new feature

1. If the feature requires new values, add them to `ci/03-full.yaml`.
2. Add a `containsDocument` assertion to the relevant test file to verify the resource renders.
3. To assert it is off by default, use `hasDocuments: count: 3` with `ci/01-defaults.yaml`.
4. For value-level assertions, prefer adding a dedicated minimal scenario in `ci/` where the
   document order is known, then use `documentIndex`.

### Example

```yaml
# tests/my_resource_test.yaml
suite: MyResource
templates:
  - app.yaml
tests:
  - it: not rendered by default
    values:
      - ../ci/01-defaults.yaml
    asserts:
      - hasDocuments:
          count: 3  # Deployment + PDB + Service only

  - it: renders when enabled
    values:
      - ../ci/03-full.yaml
    asserts:
      - containsDocument:
          kind: MyResource
          apiVersion: some.group/v1
          any: true
```

## Validating rendered output manually

```bash
# Minimal
helm template test-app test-consumer/ -f test-consumer/ci/01-defaults.yaml

# StatefulSet
helm template test-app test-consumer/ -f test-consumer/ci/02-statefulset.yaml

# Everything
helm template test-app test-consumer/ -f test-consumer/ci/03-full.yaml

# With debug output
helm template test-app test-consumer/ -f test-consumer/ci/03-full.yaml --debug
```

## Required values

The library enforces these values at render time via `required`. Helm will fail if either is missing:

| Value | Error message |
|-------|--------------|
| `resources.requests.memory` | `resources.requests.memory is required` |
| `resources.requests.cpu` | `resources.requests.cpu is required` |

This applies to both Deployment and StatefulSet workloads.
