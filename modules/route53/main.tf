# Fetch hosted zones

data "aws_route53_zone" "public" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = var.dns_record.name
  type    = var.dns_record.type

  alias {
    name                   = var.alias_name
    zone_id                = var.alias_zone_id
    evaluate_target_health = true
  }
}
