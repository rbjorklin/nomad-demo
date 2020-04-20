resource "aws_route53_record" "hostname" {
  for_each = var.hosts_and_ips
  zone_id  = var.aws_r53_zone_id
  name     = each.key
  type     = "A"
  ttl      = "300"
  records  = [each.value]
}

resource "aws_route53_record" "loadbalancer" {
  zone_id = var.aws_r53_zone_id
  name    = "loadbalancer"
  type    = "A"
  ttl     = "300"
  records = values(var.hosts_and_ips)
}

resource "aws_route53_record" "graylog" {
  zone_id = var.aws_r53_zone_id
  name    = "graylog"
  type    = "CNAME"
  ttl     = "300"
  records = ["loadbalancer.${var.domain}"]
}

resource "aws_route53_record" "haproxy" {
  zone_id = var.aws_r53_zone_id
  name    = "haproxy"
  type    = "CNAME"
  ttl     = "300"
  records = ["loadbalancer.${var.domain}"]
}

resource "aws_route53_record" "nexus" {
  zone_id = var.aws_r53_zone_id
  name    = "nexus"
  type    = "CNAME"
  ttl     = "300"
  records = ["loadbalancer.${var.domain}"]
}

resource "aws_route53_record" "consul_ui" {
  zone_id = var.aws_r53_zone_id
  name    = "consul-ui"
  type    = "CNAME"
  ttl     = "300"
  records = ["loadbalancer.${var.domain}"]
}

resource "aws_route53_record" "nomad" {
  zone_id = var.aws_r53_zone_id
  name    = "nomad"
  type    = "CNAME"
  ttl     = "300"
  records = ["loadbalancer.${var.domain}"]
}

resource "aws_route53_record" "vault" {
  zone_id = var.aws_r53_zone_id
  name    = "vault"
  type    = "CNAME"
  ttl     = "300"
  records = ["loadbalancer.${var.domain}"]
}

resource "aws_route53_record" "teamcity" {
  zone_id = var.aws_r53_zone_id
  name    = "teamcity"
  type    = "CNAME"
  ttl     = "300"
  records = ["loadbalancer.${var.domain}"]
}

resource "aws_route53_record" "prometheus" {
  zone_id = var.aws_r53_zone_id
  name    = "prometheus"
  type    = "CNAME"
  ttl     = "300"
  records = ["loadbalancer.${var.domain}"]
}

resource "aws_route53_record" "alertmanager" {
  zone_id = var.aws_r53_zone_id
  name    = "alertmanager"
  type    = "CNAME"
  ttl     = "300"
  records = ["loadbalancer.${var.domain}"]
}

resource "aws_route53_record" "grafana" {
  zone_id = var.aws_r53_zone_id
  name    = "grafana"
  type    = "CNAME"
  ttl     = "300"
  records = ["loadbalancer.${var.domain}"]
}

resource "aws_route53_record" "jenkins" {
  zone_id = var.aws_r53_zone_id
  name    = "jenkins"
  type    = "CNAME"
  ttl     = "300"
  records = ["loadbalancer.${var.domain}"]
}

resource "aws_route53_record" "gitea" {
  zone_id = var.aws_r53_zone_id
  name    = "gitea"
  type    = "CNAME"
  ttl     = "300"
  records = ["loadbalancer.${var.domain}"]
}
