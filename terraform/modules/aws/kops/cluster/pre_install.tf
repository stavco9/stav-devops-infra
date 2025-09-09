module "oidc_provider_discovery_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.oidc_provider_discovery_bucket
  #acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_public_policy = true
  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false

  versioning = {
    enabled = true
  }

  tags = merge(local.tags, {
    Name = local.oidc_provider_discovery_bucket
  })
}

### DNS Zone

resource "aws_acm_certificate" "master_cert" {
  domain_name       = "api.${local.cluster_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.tags, {
    Name = "api.${local.cluster_name}"
  })
}

resource "aws_route53_record" "master_cert_validate" {
  for_each = {
    for dvo in aws_acm_certificate.master_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.dns_zone_id
}

resource "aws_acm_certificate_validation" "master_cert_validate" {
  certificate_arn         = aws_acm_certificate.master_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.master_cert_validate : record.fqdn]
}
