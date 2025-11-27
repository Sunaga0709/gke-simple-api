resource "google_project_service" "activate_kms" {
  project                    = local.project_id
  service                    = "cloudkms.googleapis.com"
  disable_dependent_services = true
}

resource "google_kms_key_ring" "sops" {
  name     = "sops-keyring"
  location = "global"

  depends_on = [google_project_service.activate_kms]
}

resource "google_kms_crypto_key" "sops" {
  name            = "sops-key"
  key_ring        = google_kms_key_ring.sops.id
  rotation_period = "7776000s"
}
