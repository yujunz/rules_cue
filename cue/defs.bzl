"Public API re-exports"

def version(name):
    native.genrule(
        name = name,
        cmd = "$(CUE_BIN) version",
        toolchains = ["@rules_cue//cue:resolved_toolchain"],
    )

# https://github.com/seh/rules_cue/blob/515c284b28313e90d4b0c6b914eecf93919bfea4/cue/cue.bzl#L14C1-L22C1
CUEModuleInfo = provider(
    doc = "Collects files from cue_module targets for use by referring cue_instance targets.",
    fields = {
        "module_file": """The "module.cue" file in the module directory.""",
        # TODO(seh): Consider abandoning this field in favor of using cue_instance for these.
        "external_package_sources": "The set of files in this CUE module defining external packages.",
    },
)

# https://github.com/seh/rules_cue/blob/515c284b28313e90d4b0c6b914eecf93919bfea4/cue/cue.bzl#L278C1-L320C1
def _cue_module_impl(ctx):
    module_file = ctx.file.file
    expected_module_file = "module.cue"
    if module_file.basename != expected_module_file:
        fail(msg = """supplied CUE module file is not named "{}"; got "{}" instead""".format(expected_module_file, module_file.basename))

    directory = module_file.dirname
    expected_module_directory = "cue.mod"
    if directory != expected_module_directory:
        fail(msg = """supplied CUE module directory is not named "{}"; got "{}" instead""".format(expected_module_directory, directory))

    return [
        CUEModuleInfo(
            module_file = module_file,
            external_package_sources = depset(
                direct = ctx.files.srcs,
            ),
        ),
    ]

_cue_module = rule(
    implementation = _cue_module_impl,
    attrs = {
        "file": attr.label(
            doc = "module.cue file for this CUE module.",
            allow_single_file = [".cue"],
            mandatory = True,
        ),
        "srcs": attr.label_list(
            doc = """Source files defining external packages from the "gen," "pkg," and "usr" directories.""",
            allow_files = [".cue"],
        ),
    },
)

def cue_module(name = "cue.mod", **kwargs):
    file = kwargs.pop("file", "module.cue")

    _cue_module(
        name = name,
        file = file,
        **kwargs
    )
