resource "google_iam_workload_identity_pool" "github_wi_pool" {
  project                   = local.project_id
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub pool"
}

resource "google_iam_workload_identity_pool_provider" "github_wi_provider" {
  project                            = local.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_wi_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-pool-provider"
  display_name                       = "GitHub pool provider"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"        = "assertion.aud"
    "attribute.repository" = "assertion.repository"
  }
  attribute_condition = <<EOT
  attribute.repository == "${local.github_repo}" &&
  assertion.ref == "refs/heads/main"
EOT
}
