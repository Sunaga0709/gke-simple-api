resource "google_service_account" "gke_nodes" {
  account_id   = "gke-node-sa"
  display_name = "Service account for GKE nodes"
}

resource "google_project_iam_member" "gke_nodes_logging" {
  project = local.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"

  depends_on = [google_service_account.gke_nodes]
}

resource "google_project_iam_member" "gke_nodes_monitoring" {
  project = local.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"

  depends_on = [google_service_account.gke_nodes]
}

resource "google_project_iam_member" "gke_nodes_ar" {
  project = local.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"

  depends_on = [google_service_account.gke_nodes]
}

resource "google_service_account" "eso_secret_manager" {
  account_id   = "eso-secret-manager"
  display_name = "Service account for ESO secret manager"
}

resource "google_project_iam_member" "eso_secret_manager_accessor" {
  project = local.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.eso_secret_manager.email}"

  depends_on = [google_service_account.eso_secret_manager]
}

resource "google_service_account_iam_member" "eso_wiu" {
  service_account_id = google_service_account.eso_secret_manager.name
  role               = "roles/iam.workloadIdentityUser"
  member             = local.eso_ksa_pricinpal
}

resource "google_service_account" "github_ci" {
  account_id   = "cicd-build"
  display_name = " Service account for GitHub Actions"
}

resource "google_project_iam_member" "github_ar_w" {
  project = local.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.github_ci.email}"
}

resource "google_service_account_iam_member" "github_ci_wif" {
  service_account_id = google_service_account.github_ci.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_wi_pool.name}/attribute.repository/${local.github_repo}"
}
