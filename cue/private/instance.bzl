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

def _file_from_label_keyed_string_dict_key(k):
    # NB: The Targets in a label_keyed_string_dict attribute have the key's
    # source file in a depset, as opposed being represented directly as in a
    # label_list attribute.
    files = k.files.to_list()
    if len(files) != 1:
        fail(msg = "Unexpected number of files in target {}: {}".format(k, len(files)))
    return files[0]

def _collect_direct_file_sources(ctx):
    files = list(ctx.files.srcs)
    for k, _ in ctx.attr.qualified_srcs.items():
        file = _file_from_label_keyed_string_dict_key(k)
        if file not in files:
            files.append(file)
    return files

def _cue_instance_runfiles_impl(ctx):
    instance = ctx.attr.instance[CUEInstanceInfo]
    return [
        DefaultInfo(runfiles = ctx.runfiles(
            files = _collect_direct_file_sources(ctx),
            transitive_files = depset(
                transitive = [instance.transitive_files],
            ),
        )),
    ]

def _add_common_source_consuming_attrs_to(attrs):
    attrs.update({
        "qualified_srcs": attr.label_keyed_string_dict(
            doc = """Additional input files that are not part of a CUE package, each together with a qualifier.

The qualifier overrides CUE's normal guessing at a file's type from
its file extension. Specify it here without the trailing colon
character.""",
            allow_files = True,
        ),
        "srcs": attr.label_list(
            doc = "Additional input files that are not part of a CUE package.",
            allow_files = True,
        ),
    })
    return attrs

_cue_instance_runfiles = rule(
    implementation = _cue_instance_runfiles_impl,
    attrs = _add_common_source_consuming_attrs_to({
        "instance": attr.label(
            doc = """CUE instance to export.

This value must refer either to a target using the cue_instance rule
or another rule that yields a CUEInstanceInfo provider.""",
            providers = [CUEInstanceInfo],
            mandatory = True,
        ),
    }),
)

def _declare_cue_run_binary(name, runfiles_name, tags = []):
    native.config_setting(
        name = name + "_lacks_runfiles_directory",
        constraint_values = [
            Label("@platforms//os:windows"),
        ],
    )
    cue_run_name = name + "_cue_run_from_runfiles"
    native.sh_binary(
        name = cue_run_name,
        # NB: On Windows, we don't expect to have a runfiles directory
        # available, so instead we rely on a runfiles manifest to tell
        # us which files should be present where. We use a ZIP archive
        # to collect and project these runfiles into the right place.
        srcs = select({
            ":{}_lacks_runfiles_directory".format(name): [Label("//cue:cue-run-from-archived-runfiles")],
            "//conditions:default": [Label("//cue:cue-run-from-runfiles")],
        }),
        data = [":" + runfiles_name] + select({
            ":{}_lacks_runfiles_directory".format(name): ["@bazel_tools//tools/zip:zipper"],
            "//conditions:default": [],
        }),
        deps = ["@bazel_tools//tools/bash/runfiles"],
        tags = tags,
    )
    return cue_run_name

def prepare_instance_consuming_rule(name, **kwargs):
    """Prepare a rule for consuming a CUE instance.

    Args:
        name:   The name of the rule.
        **kwargs: Additional keyword arguments for the rule.

    Returns:
        A dictionary of keyword arguments for the rule.
    """
    instance = kwargs["instance"]
    qualified_srcs = kwargs.get("qualified_srcs", {})
    srcs = kwargs.get("srcs", [])
    tags = kwargs.get("tags", [])

    runfiles_name = name + "_cue_runfiles"
    _cue_instance_runfiles(
        name = runfiles_name,
        instance = instance,
        srcs = srcs,
        qualified_srcs = qualified_srcs,
        tags = tags,
    )
    return kwargs | {
        "cue_run": ":" + _declare_cue_run_binary(name, runfiles_name, tags),
    }
