variable "project_id" {
  description = "GCP project ID to deploy into."
  type        = string
}

variable "region" {
  description = "Default region for regional resources."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Default zone for zonal resources (e.g. zonal GKE, to avoid the regional cluster management fee)."
  type        = string
  default     = "us-central1-a"
}
