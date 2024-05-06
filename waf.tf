locals {

  acl_id = "ip-restriction"
  metric_name = "iprestriction"

  cidr_whitelist = [
    "96.248.90.33/32",
    "3.121.56.176/32"
  ]
}

resource "aws_waf_web_acl" "waf_acl" {
  name        = "${local.acl_id}_waf_acl"
  metric_name = "${local.metric_name}wafacl"

  default_action {
    type = "BLOCK"
  }

  rules {
    priority = 10
    rule_id  = aws_waf_rule.ip_whitelist.id

    action {
      type = "ALLOW"
    }
  }

  depends_on = [
    "aws_waf_rule.ip_whitelist",
    "aws_waf_ipset.ip_whitelist"
  ]
}

resource "aws_waf_rule" "ip_whitelist" {

  name        = "${local. acl_id}_ip_whitelist_rule"
  metric_name = "${local.metric_name}ipwhitelist"
  
  depends_on = ["aws_waf_ipset.ip_whitelist"]
  
  predicates {
    data_id = aws_waf_ipset.ip_whitelist.id
    negated = false
    type    = "IPMatch"
  }

}

resource "aws_waf_ipset" "ip_whitelist" {
  name = "${local. acl_id}_match_ip_whitelist"
  

  dynamic "ip_set_descriptors" {
    for_each = toset(local.cidr_whitelist)

    content {
      type  = "IPV4"
      value = ip_set_descriptors.key
    }
  }
}