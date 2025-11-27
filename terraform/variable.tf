locals {
  project_id        = "gke-simple-api"
  region            = "asia-northeast1"
  location          = "asia-northeast1"
  service_name      = "simple-api"
  domain            = "tsunaga2.xyz"
  eso_ksa_pricinpal = "serviceAccount:${local.project_id}.svc.id.goog[external-secrets/simple-api-simple-api-eso-ksa]"
  github_repo       = "Sunaga0709/gke-simple-api"
}
