#!/bin/bash
#
# Malibu - automated integration testing for Streisand
#

# Set errexit option to exit immediately on any non-zero status return
set -e

echo -e "\n\033[38;5;255m\033[48;5;234m\033[1m  M A L I B U  \033[0m\n"

ansible-playbook playbooks/integration-test.yml

pushd streisand
  deploy/streisand-new-cloud-server.sh --provider linode --site-config /tmp/travis-linode-site.yml
  cat generated-docs/gateway-password.txt
popd

