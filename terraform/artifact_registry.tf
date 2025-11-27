resource "google_project_service" "activate_artifact_registry" {
  project                    = local.project_id
  service                    = "artifactregistry.googleapis.com"
  disable_dependent_services = true
}

resource "google_artifact_registry_repository" "artifact_registry" {
  location      = local.location
  repository_id = local.service_name
  description   = "Docker image registory"
  format        = "DOCKER"

  depends_on = [google_project_service.activate_artifact_registry]
}
