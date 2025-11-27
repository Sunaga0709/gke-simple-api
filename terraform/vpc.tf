resource "google_project_service" "activate_compute" {
  project                    = local.project_id
  service                    = "compute.googleapis.com"
  disable_dependent_services = true
}

module "vpc" {
  source     = "terraform-google-modules/network/google"
  version    = "~> 13.0"
  project_id = local.project_id

  network_name            = "${local.service_name}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  shared_vpc_host         = false

  subnets = [
    {
      subnet_name           = "${local.service_name}-subnet"
      subnet_private_access = true
      subnet_ip             = "10.0.0.0/24"
      subnet_flow_logs      = false
      subnet_region         = local.region
      description           = "subnet"
    }
  ]

  secondary_ranges = {
    "${local.service_name}-subnet" = [
      {
        range_name    = "gke-pods"
        ip_cidr_range = "10.10.0.0/16"
      },
      {
        range_name    = "gke-services"
        ip_cidr_range = "10.20.0.0/20"
      }
    ]
  }

  routes = []

  ingress_rules = [
    {
      name          = "allow-gclb-healthcheck"
      description   = "Allow Google LB healthcheck"
      source_ranges = ["35.191.0.0/16", "130.211.0.0/22"] # GCLB IP
      # target_tags   = ["gke-node"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["80", "443", "7878", "30000-32767"]
        }
      ]
    }
  ]
  egress_rules = []

  depends_on = [google_project_service.activate_compute]
}
