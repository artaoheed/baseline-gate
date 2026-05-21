terraform {
  backend "gcs" {
    bucket = "baseline-gate-tf-state"
    prefix = "envs/dev"
  }
}
