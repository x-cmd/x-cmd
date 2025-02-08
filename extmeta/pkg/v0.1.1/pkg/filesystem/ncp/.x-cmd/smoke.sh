# shellcheck    shell=dash
x touch ncp_test
if ! ncp ncp_test ncp_test_2  2>&1;then
  pkg:error "fail to get version"
  return 1
fi
x rmrf ncp_test ncp_test_2
