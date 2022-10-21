output main_deployment {
  sensitive = true
  value = module.main_deployment
}

output alb_http {
  value = "http://${module.main_deployment.lb.dns_name}/s3/index.html"
}

output alb_https {
  value = "https://api.burfordfc.com/s3/index.html"
}

output nginx_http {
  value = "http://${module.main_deployment.lb.dns_name}/nginx/index.html"
}

output nginx_https {
  value = "https://api.burfordfc.com/nginx/index.html"
}

output service_http {
  value = "http://${module.main_deployment.lb.dns_name}/test-service/hello-world"
}

output service_https {
  value = "https://api.burfordfc.com/test-service/hello-world"
}

output go_here_and_redirect_burfordfc {
  value = "https://my.ionos.co.uk/domain-dns-settings/burfordfc.com?linkId=ct.txt.domains.tools.dns to ${module.main_deployment.lb.dns_name}"
}

output iam {
  value = module.main_deployment.iam
}