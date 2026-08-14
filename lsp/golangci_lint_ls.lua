return {
  cmd = { "golangci-lint-langserver" },
  root_markers = { ".git", "go.mod" },
  init_options = {
    command = {
      "golangci-lint",
      "run",
      "--output.text.path",
      "/dev/null",
      "--output.json.path",
      "stdout",
      "--show-stats=false",
      "--issues-exit-code",
      "1",
      "--new-from-rev",
      "refs/remotes/origin/HEAD",
      "--build-tags",
      "cron,api,unit,integration,functional,functional_1,functional_2,functional_3,functional_4,functional_5,functional_6,functional_http,functional_grpc",
      "--timeout",
      "10s",
    },
  },
}
