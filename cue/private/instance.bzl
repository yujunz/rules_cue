"cue_instance rule forked from https://github.com/seh/rules_cue/blob/main/cue/cue.bzl"

load("@bazel_skylib//lib:paths.bzl", "paths")
load("//cue/private:future.bzl", _runfile_path = "runfile_path")
load("//cue/private:module.bzl", "CUEModuleInfo")

CUEInstanceInfo = provider(
    doc = "Collects files and references from cue_instance targets for use in downstream consuming targets.",
    fields = {
        "directory_path": """Directory path (a "short path") to the CUE instance.""",
        "files": "The CUE files defining this instance.",
        "module": "The CUE module within which this instance sits.",
        "package_name": "Name of the CUE package to load for this instance.",
        "transitive_files": "The set of files (including other instances) referenced by this instance.",
    },
)

def _cue_module_root_directory_path(ctx, module):
    return paths.dirname(paths.dirname(_runfile_path(ctx, module.module_file)))

def _cue_instance_directory_path(ctx):
    if ctx.file.directory_of:
        f = ctx.file.directory_of
        runfile_path = _runfile_path(ctx, f)
        return runfile_path if f.is_directory else paths.dirname(runfile_path)
    return paths.dirname(_runfile_path(ctx, ctx.files.srcs[0]))

def _cue_instance_impl(ctx):
    ancestor_instance = None
    if CUEModuleInfo in ctx.attr.ancestor:
        module = ctx.attr.ancestor[CUEModuleInfo]
    else:
        ancestor_instance = ctx.attr.ancestor[CUEInstanceInfo]
        module = ancestor_instance.module
        for dep in ctx.attr.deps:
            instance = dep[CUEInstanceInfo]
            if instance.module != module:
                fail(msg = """dependency {} of instance {} is not part of CUE module "{}"; got "{}" instead""".format(dep, ctx.label, module, dep.module))

    instance_directory_path = _cue_instance_directory_path(ctx)
    module_root_directory = _cue_module_root_directory_path(ctx, module)
    if not (instance_directory_path == module_root_directory or
            # The CUE module may be at the root of the Bazel workspace.
            not module_root_directory or
            instance_directory_path.startswith(module_root_directory + "/")):
        fail(msg = "directory {} for instance {} is not dominated by the module root directory {}".format(
            instance_directory_path,
            ctx.label,
            module_root_directory,
        ))
    return [
        CUEInstanceInfo(
            directory_path = instance_directory_path,
            files = ctx.files.srcs,
            module = module,
            package_name = ctx.attr.package_name or paths.basename(instance_directory_path),
            transitive_files = depset(
                direct = ctx.files.srcs +
                         ([module.module_file] if not ancestor_instance else []),
                transitive = [instance.transitive_files for instance in (
                                 [dep[CUEInstanceInfo] for dep in ctx.attr.deps] +
                                 ([ancestor_instance] if ancestor_instance else [])
                             )] +
                             ([module.external_package_sources] if not ancestor_instance else []),
            ),
        ),
    ]

cue_instance = rule(
    implementation = _cue_instance_impl,
    attrs = {
        "ancestor": attr.label(
            doc = """Containing CUE instance or module root.

This value must refer either to a dominating target using the
cue_instance rule (or another rule that yields a CUEInstanceInfo
provider) or a dominating target using the cue_module rule (or another
rule that yields a CUEModuleInfo provider).
""",
            providers = [[CUEInstanceInfo], [CUEModuleInfo]],
            mandatory = True,
        ),
        "deps": attr.label_list(
            doc = """cue_instance targets to include in the evaluation.

These instances are those mentioned in import declarations in this
instance's CUE files.""",
            providers = [CUEInstanceInfo],
        ),
        "directory_of": attr.label(
            doc = """Directory designator to use as the instance directory.

If the given target is a directory, use that directly. If the given
target is a file, use the file's containing directory.

If left unspecified, use the directory containing the first CUE file
nominated in this cue_instance's "srcs" attribute.""",
            allow_single_file = True,
        ),
        "package_name": attr.string(
            doc = """Name of the CUE package to load for this instance.

If left unspecified, use the basename of the containing directory as
the CUE pacakge name.""",
        ),
        "srcs": attr.label_list(
            doc = "CUE input files that are part of the nominated CUE package.",
            mandatory = True,
            allow_empty = False,
            allow_files = [".cue"],
        ),
    },
)
