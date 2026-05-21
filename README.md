# baseline-gate

End-to-end Infrastructure-as-Code on Google Cloud — a portfolio project demonstrating
production-shaped practices (remote state, pre-commit guardrails, least-privilege auth,
cost discipline) at seed-stage scale.

> **Constraints driving every decision here:** a fixed **$200** credit budget and a hard
> **June 23 2026** expiry. Choices favour the cheapest defensible option, not the most
> elaborate one.

## Architecture

> _Stub — fills in as modules land._

Target shape (Project #1): a VPC network, a **zonal** GKE cluster, a Cloud SQL instance,
and a containerised app, all provisioned via Terraform with remote state in GCS.

```
envs/dev/        # root module for the dev environment (provider, backend, vars)
modules/
  network/       # VPC, subnets, firewall
  gke/           # zonal GKE cluster
  sql/           # Cloud SQL instance
  app/           # app workload
scripts/         # bootstrap / teardown helpers
```

## Setup

| | |
|---|---|
| **GCP project** | `baseline-gate` (project #409082580695) |
| **Region / zone** | `us-central1` / `us-central1-a` |
| **Remote state** | `gs://baseline-gate-tf-state`, prefix `envs/dev`, versioning on |
| **Terraform** | `>= 1.5.0`; google / google-beta providers `~> 6.0` |

```bash
cd envs/dev
cp terraform.tfvars.example terraform.tfvars   # real tfvars is gitignored
terraform init
terraform plan
```

### Authentication model

- **Local development:** the developer's own user credentials via
  `gcloud auth application-default login`. No key file on disk.
- **CI/CD (planned):** the `terraform-runner` service account via **Workload Identity
  Federation** — keyless, no long-lived secret anywhere. (`iamcredentials` API already enabled.)
- **No long-lived service-account JSON keys are used,** by design. See decisions log.

## Decisions log

| Decision | Rationale | Revisit |
|---|---|---|
| **Region `us-central1`** | Cheapest line items, widest feature catalogue; latency irrelevant for a portfolio. | — |
| **Zonal GKE cluster** | Avoids the ~$73/mo management fee a second regional cluster would incur. | If HA ever matters. |
| **Remote state in GCS, created out-of-band** | Chicken-and-egg: state backend can't manage the bucket holding its own state. Created manually, versioning + lifecycle set. Documented exception. | — |
| **No SA JSON key — keyless auth** | Long-lived keys leak, never rotate, and are an anti-pattern reviewers flag. Local = user ADC; CI = WIF. _(Corrected: an earlier plan to download an SA key was dropped; the key was never created.)_ | — |
| **`roles/editor` on `terraform-runner`** | Pragmatic for early phases; avoids per-resource IAM churn while the surface is changing. | **Phase 6** — tighten to least-privilege. |
| **`roles/billing.viewer` dropped from SA** | The SA provisions no billing resources; it never calls the Billing API. | — |
| **`google-beta` provider included up front** | On the roadmap (GKE features often require it); adding now avoids later churn. | — |
| **Single consolidated repo** | An earlier setup left Terraform in a parent folder while the GitHub repo lived in a nested clone, so pre-commit hooks were wired to the wrong repo. Consolidated into one repo at the GitHub root. | — |

## Cost estimate

> _Placeholder — populated before the first `apply` that creates billable resources._
> Running tally against the **$200 / June 23** budget. Budget alerts configured at
> $25 / $50 / $100 / $150 / $180 / $200 (email + Pub/Sub `budget-alerts`).
> **TODO:** confirm alerts are attached to `baseline-gate`, not another project.

## Status

**Project #1 — Phase 1: Foundation & guardrails** (in progress)

- [x] Remote state backend (GCS, versioned)
- [x] `envs/dev` root module — provider, backend, variables, outputs stub
- [x] `terraform init` green against remote state
- [x] pre-commit guardrails (`fmt`, `validate`, `tflint`, `trivy`, `detect-private-key`)
- [ ] tflint + trivy binaries installed locally (required before first commit)
- [ ] CLAUDE.md committed to repo root
- [ ] First commit through pre-commit hooks
