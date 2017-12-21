#!/bin/bash
#
# Malibu - automated integration testing for Streisand
#

# Set errexit option to exit immediately on any non-zero status return
set -e

cleanup() {
  # Capture the return status previous to the cleanup
  returnStatus=$?
  # Run a playbook to delete created instances
  ansible-playbook -e "server_id=$server_id" playbooks/cleanup.yml
  # Exit with the captured status
  exit $rv
}

# Ensure cleanup is called on exit
trap "cleanup" INT TERM EXIT

echo -e "\n\033[38;5;255m\033[48;5;234m\033[1m  M A L I B U  \033[0m\n"

# Run a playbook to get set up for integration tests
ansible-playbook playbooks/integration-test.yml

pushd streisand
  # Deploy a new Streisand instance in Linode
  deploy/streisand-new-cloud-server.sh --provider linode --site-config /tmp/travis-linode-site.yml

  server_ip=$(jq .ipv4 integration-data/linode.metadata.json)
  server_id=$(jq .id integration-data/linode.metadata.json)

  # Run the integration tests against the Linode instance
  ansible-playbook -i ../inventory -e "streisand_ip=$server_ip" playbooks/test-client.yml
popd

