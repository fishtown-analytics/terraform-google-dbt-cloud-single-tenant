provider "google" {
  project = var.project_name
  region  = var.region
}

module "single_tenant_staging" {

  source = "../../"

  namespace           = var.namespace
  environment         = var.environment
  region              = var.region
  vpc_id              = google_compute_network.network.id
  vpc_name            = google_compute_network.network.name
  private_subnet_name = google_compute_subnetwork.private_subnet.name
  k8s_node_count      = 2
  k8s_node_type       = "e2-standard-2"
  domain_name         = "singletenantgcp.getdbt.com"
  hosted_zone_name    = "gcp-single-tenant"

  # fill out with secure password before applying
  db_password = ""

  create_admin_console_script = true
  
}
