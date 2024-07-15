"Public API re-exports"

def version(name):
    native.genrule(
        name = name,
        cmd = "$(CUE_BIN) version",
        toolchains = ["@rules_cue//cue:resolved_toolchain"],
    )
