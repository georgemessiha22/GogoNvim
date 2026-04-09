return {
    init_options = {
        command = {
            "golangci-lint",
            "run",
            "--output.text.path", "/dev/null",
            "--output.json.path", "stdout",
            "--show-stats=false",
            "--issues-exit-code", "1",
            "--new-from-rev", "refs/remotes/origin",
            "--build-tags",
            "unit,integration,functional,functional_1,functional_2,functional_3,functional_4,functional_5,functional_6,functional_http,functional_grpc",
            "--timeout", "10s"
        },
    },
}
