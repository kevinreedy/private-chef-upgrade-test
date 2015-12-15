#!/usr/bin/env bats

@test "chef-server-ctl status is good" {
  run /usr/bin/chef-server-ctl status
  [ "$status" -eq 0 ]
}

@test "chef-server-ctl test is good" {
  run /usr/bin/chef-server-ctl test
  [ "$status" -eq 0 ]
}
