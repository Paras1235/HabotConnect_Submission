terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" { type = string }
variable "region" { type = string, default = "us-central1" }
variable "pipeline_sa_email" { type = string }
variable "kms_key_ring" { type = string }

# --- D0: RAW LANDING GCS BUCKET ---
resource "google_storage_bucket" "raw_landing" {
  name                        = "${var.project_id}-habot-raw-landing"
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  deletion_policy             = "retain"

  encryption {
    default_kms_key_name = var.kms_key_ring
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type          = "AbortIncompleteMultipartUpload"
    }
    condition {
      age = 1
    }
  }
}

# IAM Condition: Restrict pipeline service account strictly to incoming/ prefix
resource "google_storage_bucket_iam_member" "pipeline_writer" {
  bucket = google_storage_bucket.raw_landing.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${var.pipeline_sa_email}"
  
  condition {
    title       = "RestrictToIncomingPrefix"
    description = "Allows write access exclusively to the incoming/ prefix"
    expression  = "resource.name.startsWith('b/${google_storage_bucket.raw_landing.name}/o/incoming/')"
  }
}

# --- D1: STAGED / ENFORCED BIGQUERY DATASET ---
resource "google_bigquery_dataset" "staged_dataset" {
  dataset_id                  = "habot_staged_enforced"
  friendly_name               = "HabotConnect Staged Enforced Data"
  description                 = "Secured BigQuery dataset with CMEK and RLS"
  location                    = var.region
  default_encryption_configuration {
    kms_key_name = var.kms_key_ring
  }
  delete_contents_on_destroy = false
}

resource "google_bigquery_table" "staged_table" {
  dataset_id          = google_bigquery_dataset.staged_dataset.dataset_id
  table_id            = "student_support_records"
  deletion_protection = true

  time_partitioning {
    type  = "DAY"
    field = "submitted_at"
  }

  schema = file("${path.module}/schemas/bq_schema.json")
}

# BigQuery Row-Level Security Policy
resource "google_bigquery_row_access_policy" "region_scoped_access" {
  dataset_id = google_bigquery_dataset.staged_dataset.dataset_id
  table_id   = google_bigquery_table.staged_table.table_id
  row_access_policy_id = "region_scoped_access"
  predicate  = "assigned_region_owner = SESSION_USER() OR 'incident-response-breakglass@habotconnect.org' IN UNNEST(SESSION_USER_GROUPS())"
}