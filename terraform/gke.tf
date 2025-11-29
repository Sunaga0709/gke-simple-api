resource "google_project_service" "activate_gke" {
  project                    = local.project_id
  service                    = "container.googleapis.com"
  disable_dependent_services = true
}

module "gke" {
  source              = "terraform-google-modules/kubernetes-engine/google"
  version             = "~> 41.0"
  project_id          = local.project_id
  name                = local.service_name
  region              = local.region
  network             = module.vpc.network_name
  subnetwork          = "${local.service_name}-subnet"
  ip_range_pods       = "gke-pods"
  ip_range_services   = "gke-services"
  deletion_protection = false

  remove_default_node_pool = true
  # create_service_account   = false
  service_account = google_service_account.gke_nodes.email

  node_pools = [
    {
      name         = "default-pool"
      machine_type = "e2-small"
      min_count    = 1
      max_count    = 1
      disk_size_gb = 50
      disk_type    = "pd-balanced"
      image_type   = "COS_CONTAINERD"
      auto_upgrade = true
      auto_repair  = true
    }
  ]

  node_pools_oauth_scopes = {
    default-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  depends_on = [
    google_project_service.activate_gke,
    google_service_account.gke_nodes
  ]
}
