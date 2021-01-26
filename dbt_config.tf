resource "local_file" "script" {
  count    = var.create_admin_console_script ? 1 : 0
  filename = "./dbt_config.sh"
  content  = <<EOT
gcloud container clusters get-credentials ${var.namespace}-${var.environment}-cluster --region ${var.region} --project ${data.google_project.project.name}
kubectl config set-context --current --namespace=${var.existing_namespace ? var.custom_namespace : kubernetes_namespace.dbt_cloud.0.metadata.0.name}
curl https://kots.io/install | bash
kubectl kots install dbt-cloud-v1${var.release_channel} --namespace ${var.existing_namespace ? var.custom_namespace : kubernetes_namespace.dbt_cloud.0.metadata.0.name} --shared-password ${var.admin_console_password} --config-values ${local_file.config.0.filename}
EOT
}

resource "local_file" "config" {
  count    = var.create_admin_console_script ? 1 : 0
  filename = "./config.yaml"
  content  = <<EOT
apiVersion: kots.io/v1beta1
kind: ConfigValues
metadata:
  creationTimestamp: null
  name: dbt-cloud
spec:
  values:
    app_memory:
      value: ${var.app_memory}
    app_replicas:
      value: "${var.app_replicas}"
    artifacts_s3_bucket:
      value: ${var.artifacts_s3_bucket}
    aws_access_key_id:
      value: ${var.aws_access_key_id}
    aws_secret_access_key:
      value: ${var.aws_secret_access_key}
    azure_storage_connection_string: {}
    database_dbname:
      value: "${var.namespace}${var.environment}"
    database_embedded_storage_gb:
      value: "10"
    database_hostname:
      value: "${google_sql_database_instance.dbt_cloud_db_instance.private_ip_address}"
    database_password:
      value: "${google_sql_user.db_user.password}"
    database_port:
      value: "5432"
    database_sslmode:
      value: require
    database_storage_class:
      value: default
    database_user:
      value: "${google_sql_user.db_user.name}"
    datadog_enabled:
      value: "${var.datadog_enabled == true ? 1 : 0}"
    db_type:
      default: external
      value: external
    disable_anonymous_tracking:
      value: "0"
    django_debug_mode:
      value: "0"
    django_superuser_password:
      value: ${var.superuser_password}
    enable_okta:
      value: "0"
    encryption_method:
      default: rsa
      value: rsa
    github_api_url: {}
    github_app_client_id: {}
    github_app_client_secret: {}
    github_app_configure_url: {}
    github_app_id: {}
    github_app_install_url: {}
    github_base_url: {}
    github_enabled:
      value: "0"
    github_private_key_pem: {}
    google_api_url:
      value: https://www.googleapis.com
    google_settings_type:
      default: defaults
    hostname:
      value: ${var.domain_affix == "" ? var.environment : var.domain_affix}.${var.domain_name}
    ide_storage_class:
      value: ${var.ide_storage_class}
    imageRegistry:
      value: registry.replicated.com/dbt-cloud-v1/
    kms_key_id:
      value: ""
    nginx_memory:
      value: ${var.nginx_memory}
    rsa_private_key:
      value: "${tls_private_key.rsa_key.private_key_pem}"
    rsa_public_key:
      value: "${tls_private_key.rsa_key.public_key_pem}"
    run_logs_s3_bucket:
      value: ${var.logs_s3_bucket}
    s3_endpoint_url:
      value: https://s3.${var.region}.amazonaws.com
    s3_region:
      value: ${var.region}
    saml_private_key: {}
    saml_public_cert: {}
    scaling_settings_type:
      default: defaults
    scheduler_memory:
      value: ${var.scheduler_memory}
    slack_enabled:
      value: "0"
    slack_key: {}
    slack_secret: {}
    smtp_auth_enabled:
      value: "1"
    smtp_enabled:
      value: "0"
    smtp_host:
      value: ""
    smtp_password:
      value: ""
    smtp_port:
      value: "587"
    smtp_tls_enabled:
      value: "1"
    smtp_username:
      value: ""
    storage_method:
      default: s3
    system_from_email_address:
      value: ""
status: {}
EOT
}
