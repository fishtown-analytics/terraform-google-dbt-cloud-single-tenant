data "google_dns_managed_zone" "dns_zone" {
  name = var.hosted_zone_name
}

resource "google_dns_record_set" "cname" {
  name         = "${var.environment}.${var.domain_name}."
  managed_zone = data.google_dns_managed_zone.dns_zone.name
  type         = "CNAME"
  ttl          = 60
  rrdatas      = ["${var.environment}.${var.domain_name}."]
}
