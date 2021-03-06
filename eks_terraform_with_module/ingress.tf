// Route53 zone이 이미 생성되어 있어야 한다.
// ingress.tfvars에서 본인이 이미 생성한 Route53 도메인 이름을 넣어줘야 함
data "aws_route53_zone" "base_domain" {
  name = var.dns_base_domain
}


// ACM 서비스를 이용한 SSL 인증서 발급
// DNS Validation
resource "aws_acm_certificate" "eks_domain_cert" {
  domain_name               = var.dns_base_domain
  subject_alternative_names = ["*.${var.dns_base_domain}"]
  validation_method         = "DNS"

  tags = {
    Name            = var.dns_base_domain
    iac_environment = var.iac_environment_tag
  }
}

// aws_route53_record 리소스
resource "aws_route53_record" "eks_domain_cert_validation_dns" {
  name    = tolist(aws_acm_certificate.eks_domain_cert.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.eks_domain_cert.domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.base_domain.id
  records = [tolist(aws_acm_certificate.eks_domain_cert.domain_validation_options)[0].resource_record_value]
  ttl     = 60

// DNS Validation check
}
resource "aws_acm_certificate_validation" "eks_domain_cert_validation" {
  certificate_arn         = aws_acm_certificate.eks_domain_cert.arn
  validation_record_fqdns = [aws_route53_record.eks_domain_cert_validation_dns.fqdn]
}

// Helm을 이용한 Ingress Controller 배포
// nginx-ingress를 배포
resource "helm_release" "ingress_gateway" {
  name       = var.ingress_gateway_chart_name
  chart      = var.ingress_gateway_chart_name
  repository = var.ingress_gateway_chart_repo
  version    = var.ingress_gateway_chart_version

// dynamic, content는 아래에 설명이 나와있다.
// https://www.terraform.io/docs/language/expressions/dynamic-blocks.html
  dynamic "set" {
    for_each = var.ingress_gateway_annotations
    content {
      name  = set.key
      value = set.value
      type  = "string"
    }
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
    value = aws_acm_certificate.eks_domain_cert.id
  }
}

# create base domain for EKS Cluster
data "kubernetes_service" "ingress_gateway" {
  metadata {
    name = join("-", [helm_release.ingress_gateway.chart, helm_release.ingress_gateway.name])
  }
  // eks-cluster가 생성된 이후에 해당 data를 생성한다. dependency 정의
  depends_on = [module.eks-cluster]
}

// aws_elb_hosted_zond_id data를 가져옴
data "aws_elb_hosted_zone_id" "elb_zone_id" {}

// eks_domain, A Record
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "eks_domain" {
  zone_id = data.aws_route53_zone.base_domain.id
  name    = var.dns_base_domain
  type    = "A"

  // alias block 유무에 따라 alias record인지 아닌지 확인할 수 있다.
  alias {
    name                      = data.kubernetes_service.ingress_gateway.load_balancer_ingress.0.hostname
    zone_id                   = data.aws_elb_hosted_zone_id.elb_zone_id.id
    evaluate_target_health    = true
  }
}