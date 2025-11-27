resource "google_project_service" "activate_dns" {
  project                    = local.project_id
  service                    = "dns.googleapis.com"
  disable_dependent_services = true
}

module "dns" {
  source      = "terraform-google-modules/cloud-dns/google"
  version     = "~> 6.0"
  project_id  = local.project_id
  name        = "${local.service_name}-zone"
  domain      = "${local.domain}."
  type        = "public"
  description = "Public DNS zone"

  recordsets = [
    {
      name    = ""
      type    = "A"
      ttl     = 300
      records = ["34.111.216.168"] # Cloud Load Balancing IP
    }
  ]

  depends_on = [google_project_service.activate_dns]
}
