# Naviteq Helm Library Chart

A reusable Helm **library chart** providing shared Kubernetes building blocks for Naviteq application charts.

[![CI](https://github.com/naviteq/helm-library/actions/workflows/ci.yaml/badge.svg)](https://github.com/naviteq/helm-library/actions/workflows/ci.yaml)
[![Helm](https://img.shields.io/badge/Helm-%E2%89%A53.12-0F1689?logo=helm&logoColor=white)](https://helm.sh)
[![Chart Type](https://img.shields.io/badge/chart%20type-library-informational)](https://helm.sh/docs/topics/library_charts/)

> [!WARNING]
> **Pre-1.0 — values schema may change between minor versions.**
> Until this chart reaches `1.0.0`, the structure of `values.yaml` may change in any release.
> Pin your dependency to an exact version (e.g. `version: 0.0.2`) rather than a range to avoid surprises.

## Requirements

| Tool | Version |
|------|---------|
| [Helm](https://helm.sh) | ≥ 3.12 |
| Kubernetes | Tested against **1.34.0** (default) — see [TESTING.md](./TESTING.md) for overriding |

### Pinned dependency

This chart depends on [Bitnami Common](https://github.com/bitnami/charts/tree/main/bitnami/common) for shared template helpers:

| Dependency | Version | Source |
|-----------|---------|--------|
| `common` | `2.36.0` | `oci://registry-1.docker.io/bitnamicharts` |

## Consumption

This chart is published as an OCI artifact to **GitHub Container Registry (GHCR)** when a `vX.Y.Z` tag is pushed (see [`.github/workflows/helm-release.yaml`](./.github/workflows/helm-release.yaml)).

### OCI repository

```text
oci://ghcr.io/naviteq/helm-library/naviteq-library-chart
```

The package is published with public visibility — no authentication is required to pull it.

### Add as a dependency

In your application chart's `Chart.yaml`:

```yaml
dependencies:
  - name: naviteq-library-chart
    version: 0.0.2
    repository: oci://ghcr.io/naviteq/helm-library
    import-values:
      - defaults
```

Then download the dependency before rendering or installing your chart:

```bash
helm dependency update
```

## Minimal consumer example

The smallest possible application chart that uses this library is **three files**.

### `Chart.yaml`

```yaml
apiVersion: v2
name: my-app
description: My application chart
type: application
version: 0.1.0
appVersion: "1.0.0"
dependencies:
  - name: naviteq-library-chart
    version: 0.0.2
    repository: oci://ghcr.io/naviteq/helm-library
    import-values:
      - defaults
```

### `values.yaml`

```yaml
# Only required fields — everything else inherits library defaults
image:
  repository: nginx
  tag: "latest"

resources:
  requests:
    memory: 128Mi
    cpu: 100m
```

> **Required values:** the library will fail to render if `resources.requests.memory` or `resources.requests.cpu` are missing.

### `templates/app.yaml`

```yaml
{{- include "library.app" . }}
```

That single line expands to a complete set of Kubernetes manifests (Deployment + Service + PodDisruptionBudget by default; more resources render when their feature flags are enabled in `values.yaml`).

### Render and install

```bash
helm dependency update
helm template my-app .       # preview the rendered manifests
helm install my-app .        # apply to the cluster
```

## Feature matrix

The library provides templates for the following resource categories. Each is opt-in via flags in `values.yaml` (see [`chart/README.md`](./chart/README.md) for the full values reference).

| Category | Kubernetes Kinds | Source |
|----------|------------------|--------|
| **Workloads** | `Deployment`, `StatefulSet`, `Service`, `PodDisruptionBudget` | [`templates/workloads/`](./chart/templates/workloads) |
| **Autoscaling (native)** | `HorizontalPodAutoscaler` | [`templates/workloads/_hpa.yaml`](./chart/templates/workloads/_hpa.yaml) |
| **Autoscaling (KEDA)** | `ScaledObject`, `ScaledJob`, `TriggerAuthentication`, `ClusterTriggerAuthentication` | [`templates/keda/`](./chart/templates/keda) |
| **External Secrets (ESO)** | `ExternalSecret`, `ClusterExternalSecret`, `SecretStore`, `ClusterSecretStore`, `PushSecret`, `ClusterPushSecret`, ESO generators | [`templates/external-secrets/`](./chart/templates/external-secrets) |
| **RBAC** | `ServiceAccount`, `Role`, `RoleBinding`, `ClusterRole`, `ClusterRoleBinding` | [`templates/rbac/`](./chart/templates/rbac) |
| **Config** | `ConfigMap`, `Secret` | [`templates/config/`](./chart/templates/config) |
| **Expose (Ingress)** | `Ingress` | [`templates/expose/`](./chart/templates/expose) |
| **Gateway API** | `Gateway`, `HTTPRoute`, `GRPCRoute`, `TLSRoute`, `TCPRoute` | [`templates/gateway-api/`](./chart/templates/gateway-api) |
| **GCP** | `BackendConfig`, `FrontendConfig`, `ManagedCertificate` | [`templates/gcp/`](./chart/templates/gcp) |
| **AWS** | `ENIConfig`, `IngressClassParams`, `TargetGroupBinding`, `SecurityGroupPolicy` | [`templates/aws/`](./chart/templates/aws) |

## Documentation

- [`chart/README.md`](./chart/README.md) — full reference for every value in `values.yaml`.
- [`TESTING.md`](./TESTING.md) — local development and test workflow (`task setup`, `task test`, `task validate`).
- `CHANGELOG.md` — generated automatically by [release-please](https://github.com/googleapis/release-please) on the first release. Until then, see the repo's [Releases](https://github.com/naviteq/helm-library/releases) and [tags](https://github.com/naviteq/helm-library/tags) for version history.

## Contributing

1. **Open a pull request** against `main`. Branches use prefixes like `feat/`, `fix/`, `docs/`, `chore/`.
2. **Run `task test` locally** before pushing — CI runs the same suite (`lint` + unit tests via [helm-unittest](https://github.com/helm-unittest/helm-unittest) + schema validation via [kubeconform](https://github.com/yannh/kubeconform)) and will block the PR if it fails. See [`TESTING.md`](./TESTING.md) for setup.
3. **Use [Conventional Commits](https://www.conventionalcommits.org)** in your commit messages — [release-please](https://github.com/googleapis/release-please) reads them to decide the next version automatically:

   | Commit prefix | Effect on chart version |
   |---|---|
   | `feat: …` | minor bump (e.g. `0.0.2 → 0.1.0`) |
   | `fix: …` | patch bump (e.g. `0.0.2 → 0.0.3`) |
   | `docs: …`, `chore: …`, `refactor: …` | no release |
   | `feat!: …` or `BREAKING CHANGE:` in the body | major bump (e.g. `0.x.y → 1.0.0`) |

   **Do not bump versions manually** in `Chart.yaml` — release-please handles it.

## License

Licensed under the **Apache License 2.0** — see [`LICENSE`](./LICENSE).

Copyright © 2026 Naviteq.
