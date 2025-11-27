resource "google_project_service" "activate_secret" {
  project                    = local.project_id
  service                    = "secretmanager.googleapis.com"
  disable_dependent_services = true
}

data "sops_file" "secret" {
  source_file = "secrets/secret.json"
}

resource "google_secret_manager_secret" "secret" {
  project   = local.project_id
  secret_id = "${local.service_name}-secret"
  replication {
    user_managed {
      replicas {
        location = local.region
      }
    }
  }

  depends_on = [google_project_service.activate_secret]
}

resource "google_secret_manager_secret_version" "secret_v1" {
  secret      = google_secret_manager_secret.secret.id
  secret_data = data.sops_file.secret.raw
}
