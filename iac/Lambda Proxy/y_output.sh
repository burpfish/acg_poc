#!/usr/bin/env sh


terraform output -json > output.json
#TF_OUTPUT=$(awk '{ printf "%s", $0 }' output.json)


echo ""
echo ""
echo "Redirect DNS: $(jq -r '.go_here_and_redirect_burfordfc.value' output.json)"
echo ""
echo "http:"
echo " - s3 via lambda: $(jq -r '.alb_http.value' output.json)"
echo " - nginx: $(jq -r '.nginx_http.value' output.json)"
echo " - service: $(jq -r '.service_http.value' output.json)"
echo ""
echo "alb_https / oidc:"
echo " - s3 via lambda: https://api.burfordfc.com/s3/index.html"
echo " - nginx: https://api.burfordfc.com/nginx/index.html"
echo " - service: https://api.burfordfc.com/test-service/hello-world"
echo ""
echo "Password: $(jq -r '.main_deployment.value.password' output.json)"
echo "User: $(jq -r '.main_deployment.value.username' output.json)"