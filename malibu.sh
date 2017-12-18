#!/bin/bash
#
# Malibu - automated integration testing for Streisand
#

# Set errexit option to exit immediately on any non-zero status return
set -e

echo -e "\n\033[38;5;255m\033[48;5;234m\033[1m  M A L I B U  \033[0m\n"

# Run a playbook to get set up for integration tests
ansible-playbook playbooks/integration-test.yml

pushd streisand
  # Deploy a new Streisand instance in Linode
  deploy/streisand-new-cloud-server.sh --provider linode --site-config /tmp/travis-linode-site.yml

  # Run the integration tests against the Linode instance
  ansible-playbook -e "streisand_ip=$(cat generated-docs/server-ip.txt)" playbooks/test-client.yml
popd

# Run a playbook to delete the instances created above
ansible-playbook playbooks/cleanup.yml
