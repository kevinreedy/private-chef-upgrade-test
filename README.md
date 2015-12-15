private-chef-upgrade-test
=========================

This is a quick kitchen suite I put together to test upgrading Private Chef 11 to Chef 12.

For all of you with slow connections, you can download Chef Server packages to `data/` to skip downloading during converge.

Provisioning is done with a shell script to simulate a manual Chef Server upgrade. I highly recommend using [Chef Ingredient](https://github.com/chef-cookbooks/chef-ingredient) to install or upgrade any CHEF products in your infrastructure.
