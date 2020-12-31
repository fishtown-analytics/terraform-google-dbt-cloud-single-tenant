provider "kubernetes" {
  host                   = module.kubernetes_cluster.endpoint
  cluster_ca_certificate = base64decode(module.kubernetes_cluster.ca_certificate)
  token                  = data.google_client_config.provider.access_token
  load_config_file       = false
}

module "kubernetes_cluster" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "12.2.0"

  name              = "${var.namespace}-${var.environment}-cluster"
  network           = var.vpc_name
  project_id        = data.google_project.project.name
  region            = var.region
  release_channel   = "STABLE"
  subnetwork        = var.private_subnet_name
  ip_range_pods     = var.ip_range_pods_name
  ip_range_services = var.ip_range_services_name

  regional = true

  horizontal_pod_autoscaling = false

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = var.k8s_node_type
      node_locations     = var.k8s_node_count > 2 ? "${element(local.zones, 0)},${element(local.zones, 1)},${element(local.zones, 2)}" : "${element(local.zones, 0)},${element(local.zones, 1)}"
      initial_node_count = var.k8s_node_count > 2 ? floor(var.k8s_node_count / 3) : 1
      min_count          = var.k8s_node_count > 2 ? floor(var.k8s_node_count / 3) : 1
      max_count          = var.k8s_node_count > 2 ? ceil(var.k8s_node_count / 3) : 1
      disk_size_gb       = 100

    },
  ]
}

resource "kubernetes_namespace" "dbt_cloud" {
  count = var.existing_namespace ? 0 : 1
  metadata {
    name = var.custom_namespace == "" ? "dbt-cloud-${var.namespace}-${var.environment}" : var.custom_namespace
  }
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "dbt_cloud_db_instance" {
  name             = "${var.namespace}${var.environment}${random_id.db_name_suffix.hex}"
  database_version = "POSTGRES_12"

  region = var.region

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier      = "db-f1-micro"
    disk_size = 10

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_id
      require_ssl     = false
    }
  }
}

resource "google_sql_database" "dbt_cloud_db" {
  name     = "${var.namespace}${var.environment}"
  instance = google_sql_database_instance.dbt_cloud_db_instance.name
}

resource "google_sql_user" "db_user" {
  instance = google_sql_database_instance.dbt_cloud_db_instance.name
  name     = "${var.namespace}${var.environment}"
  password = var.db_password
}

resource "google_sql_ssl_cert" "db_cert" {
  common_name = "${var.namespace}-${var.environment}-sql-cert"
  instance    = google_sql_database_instance.dbt_cloud_db_instance.name
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.vpc_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.vpc_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_compute_global_address" "static_ip" {
  name = "dbt-cloud-ip"
}

resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "google_project" "project" {}

data "google_client_config" "provider" {}

data "google_compute_zones" "zones" {
  region = var.region
}

locals {
  zones = data.google_compute_zones.zones.names
}
