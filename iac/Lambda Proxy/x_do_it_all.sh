#!/usr/bin/env sh

./0_clean_up.sh
#./1_delete_default_vpc.sh
./2_deploy.sh
./3_deploy_again_to_fix.sh
./4_deploy_nginx.sh
./5_deploy_test_service.sh
./6_wire_up_services.sh
./y_output.sh