#required
variable "namespace" {
  type        = string
  description = "Used as an identifier for various infrastructure components within the module. Usually single word that or the name of the organization. For exmaple: 'fishtownanalytics'"
}
variable "environment" {
  type        = string
  description = "The name of the environment for the deployment. For example: 'dev', 'prod', 'uat', 'standard', 'etc'"
}
variable "region" {
  type        = string
  description = "The region where the infrastructure is hosted."
}
variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the infrastructure is deployed."
}
variable "vpc_name" {
  type        = string
  description = "The name of the VPC where the infrastructure is deployed."
}
variable "private_subnet_name" {
  type        = string
  description = "The name of the private subnet where the GKE cluster is deployed."
}
variable "domain_name" {
  type        = string
  description = "The base URL of the dbt Cloud instance. This is generally affixed to the `environment` variable."
}
variable "hosted_zone_name" {
  type        = string
  description = "The name of the hosted zone where the corresponding DNS record lives."
}
variable "k8s_node_count" {
  type        = number
  description = "The number of Kubernetes nodes that will be created for the GKE worker group. Generally 2 nodes are recommended but it is recommended that you reach out to Fishtown Analytics to complete the capacity planning exercise prior to setting this."
}
variable "k8s_node_type" {
  type        = string
  description = "The GCP instance type of the Kubernetes nodes that will be created for the GKE node pool. It is recommended that you reach out to Fishtown Analytics to complete the capacity planning exercise prior to setting this."
}
variable "db_password" {
  type        = string
  description = "Password for RDS database. It is highly recommended that a secure password be generated and stored in a vault."
}

#optional
variable "ip_range_pods_name" {
  type        = string
  default     = "pods"
  description = "The name of the secondary IP range in the private subnet to be assigned to pods. This should be changed if the range is named something other than `pods` in the network setup."
}
variable "ip_range_services_name" {
  type        = string
  default     = "services"
  description = "The name of the secondary IP range in the private subnet to be assigned to services. This should be changed if the range is named something other than `services` in the network setup."
}
variable "custom_namespace" {
  type        = string
  default     = ""
  description = "If set this variable will create a custom K8s namespace for dbt Cloud. If not set the created namespace defaults to `dbt-cloud-<namespace>-<environment>`."
}
variable "existing_namespace" {
  type        = bool
  default     = false
  description = "If set to `true`this will install dbt Cloud components into an existing namespace denoted by the `custom_namespace` field. This is not recommended as it is preferred to install dbt Cloud into a dedicated namespace."
}
variable "create_admin_console_script" {
  type        = bool
  default     = false
  description = "If set to true will generate a script to automatically spin up the KOTS admin console with desired values and outputs from the module. The relevant variables below are suffixed with 'Admin Console Script' in their descriptions. These variables can also be left blank and manually entered into the script after applying if desired."
}
variable "aws_access_key_id" {
  type        = string
  default     = "<ENTER_AWS_ACCESS_KEY>"
  description = "Admin Console Script - The AWS access key for an IAM identity with admin access that will be used for encryption. This is added to the config that is automatically uploaded to the KOTS admin console via the script."
}
variable "aws_secret_access_key" {
  type        = string
  default     = "<ENTER_AWS_SECRET_KEY>"
  description = "Admin Console Script - The AWS secret key for an IAM identity with admin access that will be used for encryption. This is added to the config that is automatically uploaded to the KOTS admin console via the script."
}
variable "admin_console_password" {
  type        = string
  default     = "<ENTER_ADMIN_CONSOLE_PASSWORD>"
  description = "Admin Console Script - The desired password for the KOTS admin console. This is added to the script and used when spinning the admin console."
}
variable "superuser_password" {
  type        = string
  default     = "<ENTER_SUPER_USER_PASSWORD>"
  description = "Admin Console Script - The superuser password for the dbt Cloud application. This is added to the config that is automatically uploaded to the KOTS admin console via the script."
}
variable "datadog_enabled" {
  type        = bool
  default     = false
  description = "If set to `true` this will enable dbt Cloud to send metrics to Datadog. Note that this requires the installation of a Datadog Agent in the K8s cluster where dbt Cloud is deployed."
}
variable "domain_affix" {
  type        = string
  default     = ""
  description = "The affix of the URL, affixed to the `domain_name` variable, that the dbt Cloud deployment will resolve to. If left blank the affix will default to the value of the `environment` variable."
}
variable "release_channel" {
  type        = string
  default     = ""
  description = "Admin Console Script - The license channel for customer deployment. This should be left unset unless instructed by Fishtown Analytics."
}
variable "app_memory" {
  type        = string
  default     = "1Gi"
  description = "Admin Console Script - The memory dedicated to the application pods for dbt Cloud. This is added to the config that is automatically uploaded to the KOTS admin console via the script. This value should never be set to less than default. It is recommended that you reach out to Fishtown Analytics to complete the capacity planning exercise prior to modifying this."
}
variable "app_replicas" {
  type        = number
  default     = 2
  description = "Admin Console Script - The number of application pods for dbt Cloud. This is added to the config that is automatically uploaded to the KOTS admin console via the script. This value should never be set to less than default. It is recommended that you reach out to Fishtown Analytics to complete the capacity planning exercise prior to modifying this."
}
variable "nginx_memory" {
  type        = string
  default     = "512Mi"
  description = "Admin Console Script - The amount of memory dedicated to nginx for dbt Cloud. This is added to the config that is automatically uploaded to the KOTS admin console via the script. This value should never be set to less than default. It is recommended that you reach out to Fishtown Analytics to complete the capacity planning exercise prior to modifying this."
}
variable "scheduler_memory" {
  type        = string
  default     = "512Mi"
  description = "Admin Console Script - The amount of memory dedicated to the scheduler for dbt Cloud. This is added to the config that is automatically uploaded to the KOTS admin console via the script. This value should never be set to less than default. It is recommended that you reach out to Fishtown Analytics to complete the capacity planning exercise prior to modifying this."
}
variable "ide_storage_class" {
  type        = string
  default     = "standard"
  description = "Admin Console Script - The EFS provisioner storage class name used for the IDE. Only change if creating a custom EFS provisioner."
}

variable "artifacts_s3_bucket" {
  type    = string
  default = ""
}
variable "logs_s3_bucket" {
  type    = string
  default = ""
}
