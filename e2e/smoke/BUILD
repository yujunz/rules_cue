"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""

load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load("@bazel_skylib//rules:write_file.bzl", "write_file")

genrule(
    name = "version",
    srcs = [],
    outs = ["version"],
    cmd = "$(CUE_BIN) version > $@",
    toolchains = [
        "@rules_cue//cue:resolved_toolchain",
    ],
)

write_file(
    name = "verison_golden",
    out = "version.golden",
    content = [
        """cue version v0.9.2

go version go1.22.4
      -buildmode exe
       -compiler gc
       -trimpath true
     CGO_ENABLED 0
          GOARCH amd64
            GOOS linux
         GOAMD64 v1
cue.lang.version v0.9.2
""",
    ],
)

diff_test(
    name = "diff_test",
    file1 = ":version",
    file2 = ":verison_golden",
)
