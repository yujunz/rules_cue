"factory functions forked from https://github.com/seh/rules_cue/blob/main/cue/cue.bzl"

load("@bazel_skylib//lib:paths.bzl", "paths")
load("//cue/private:future.bzl", _runfile_path = "runfile_path")
load("//cue/private:config.bzl", "CUEConfigInfo")
load("//cue/private:instance.bzl", "CUEInstanceInfo")

def _cue_module_root_directory_path(ctx, module):
    return paths.dirname(paths.dirname(_runfile_path(ctx, module.module_file)))

def _add_common_output_producing_args_to(ctx, args, stamped_args_file):
    cue_config = ctx.attr._cue_config[CUEConfigInfo]
    stamping_enabled = ctx.attr.stamping_policy == "Force" or ctx.attr.stamping_policy == "Allow" and cue_config.stamp
    required_stamp_bindings = {}

    if ctx.attr.expression:
        args.add("--expression", ctx.attr.expression)
    for k, v in ctx.attr.inject.items():
        if len(k) == 0:
            fail(msg = "injected key must not empty")
        if stamping_enabled and v.startswith("{") and v.endswith("}"):
            required_stamp_bindings[k] = v[1:-1]
            continue
        args.add(
            "--inject",
            # Allow the empty string as a specified value.
            "{}={}".format(k, v),
        )
    for v in ctx.attr.inject_shorthand:
        if len(v) == 0:
            fail(msg = "injected value must not empty")
        args.add("--inject", v)
    if ctx.attr.list:
        args.add("--list")
    if ctx.attr.inject_vars:
        args.add("--inject-vars")
    if not ctx.attr.merge:
        args.add("--merge=false")
    if ctx.attr.package:
        args.add("--package", ctx.attr.package)
    for p in ctx.attr.path:
        if not p:
            fail(msg = "path element must not be empty")
        args.add("--path", p)
    if ctx.attr.with_context:
        args.add("--with-context")

    if len(required_stamp_bindings) == 0:
        # Create an empty file, in order to unify the command that
        # consumes extra arguments when stamping is in effect.
        ctx.actions.write(
            stamped_args_file,
            "",
        )
    else:
        stamp_placeholders_file = ctx.actions.declare_file("{}-stamp-bindings".format(ctx.label.name))
        ctx.actions.write(
            stamp_placeholders_file,
            "\n".join([k + "=" + v for k, v in required_stamp_bindings.items()]),
        )
        args = ctx.actions.args()
        args.add("-prefix", "--inject ")
        args.add("-output", stamped_args_file.path)
        args.add(stamp_placeholders_file.path)
        args.add(ctx.info_file.path)  # stable-status.txt
        args.add(ctx.version_file.path)  # volatile-status.txt
        ctx.actions.run(
            executable = ctx.executable._replacer,
            arguments = [args],
            inputs = [
                stamp_placeholders_file,
                ctx.info_file,
                ctx.version_file,
            ],
            outputs = [stamped_args_file],
            mnemonic = "CUEReplaceStampBindings",
            progress_message = "Replacing injection placeholders with stamped values for {}".format(ctx.label.name),
        )

def _make_output_producing_action(ctx, cue_command, mnemonic, description, augment_args = None, module_file = None, instance_directory_path = None, instance_package_name = None):
    cue_info = ctx.toolchains["//cue:toolchain_type"].cue
    args = ctx.actions.args()
    if module_file != None:
        args.add("-m", _runfile_path(ctx, module_file))
        if instance_directory_path:
            args.add("-i", instance_directory_path)
            if instance_package_name:
                args.add("-p", instance_package_name)
    elif instance_directory_path:
        fail(msg = "CUE instance directory path provided without a module directory path")
    elif instance_package_name:
        fail(msg = "CUE package name provided without an instance directory path")
    args.add(cue_info.target_tool_path)
    args.add(cue_command)
    stamped_args_file = ctx.actions.declare_file("%s-stamped-args" % ctx.label.name)
    args.add(stamped_args_file.path)
    args.add(ctx.outputs.result.path)
    _add_common_output_producing_args_to(ctx, args, stamped_args_file)

    if augment_args:
        augment_args(ctx, args)

    ctx.actions.run(
        executable = ctx.executable.cue_run,
        arguments = [args],
        inputs = [
            stamped_args_file,
        ],
        tools = [cue_info.tool],
        outputs = [ctx.outputs.result],
        mnemonic = mnemonic,
        progress_message = "Capturing the {} CUE configuration for target \"{}\"".format(description, ctx.label.name),
    )

def make_instance_consuming_action(ctx, cue_command, mnemonic, description, augment_args = None):
    """Creates an action that consumes a CUE instance and produces a result.

    Args:
        ctx: ctx
        cue_command: str
        mnemonic: str
        description: str
        augment_args: function
    """

    instance = ctx.attr.instance[CUEInstanceInfo]

    # NB: If the input path is equal to the starting path, the
    # "paths.relativize" function returns the input path unchanged, as
    # opposed to returning "." to indicate that it's the same
    # directory.
    module_root_directory = _cue_module_root_directory_path(ctx, instance.module)
    relative_instance_path = paths.relativize(instance.directory_path, module_root_directory)
    if relative_instance_path == instance.directory_path:
        relative_instance_path = "."
    else:
        relative_instance_path = "./" + relative_instance_path

    _make_output_producing_action(
        ctx,
        cue_command,
        mnemonic,
        description,
        augment_args,
        instance.module.module_file,
        relative_instance_path,
        instance.package_name,
    )

def add_common_source_consuming_attrs_to(attrs):
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

def _replacer_if_stamping(stamping_policy):
    # NB: We can't access the "_cue_config" attribute here.
    return Label("//tools/cmd/replace-stamps") if stamping_policy != "Never" else None

def add_common_output_producing_attrs_to(attrs):
    attrs.update({
        "_cue_config": attr.label(
            default = "//cue:cue_config",
        ),
        "_replacer": attr.label(
            default = _replacer_if_stamping,
            executable = True,
            allow_single_file = True,
            cfg = "exec",
        ),
        "list": attr.bool(
            doc = "Concatenate multiple objects into a list.",
        ),
        # Unfortunately, we can't use a private attribute for an
        # implicit dependency here, because we can't fix the default
        # label value.
        "cue_run": attr.label(
            executable = True,
            allow_files = True,
            cfg = "exec",
            mandatory = True,
        ),
        "expression": attr.string(
            doc = "CUE expression selecting a single value to export.",
            default = "",
        ),
        "inject": attr.string_dict(
            doc = "keys and values of tagged fields.",
        ),
        "inject_shorthand": attr.string_list(
            doc = "shorthand values of tagged fields.",
        ),
        "inject_vars": attr.bool(
            doc = "whether to inject the predefined set of system variables into tagged fields",
        ),
        "merge": attr.bool(
            doc = "merge non-CUE files.",
            default = True,
        ),
        "package": attr.string(
            doc = "package name for non-CUE files",
        ),
        "path": attr.string_list(
            doc = """Elements of CUE path at which to place top-level values.
Each entry for an element may nominate either a CUE field, ending with
either ":" for a regular fiield or "::" for a definition, or a CUE
expression, both variants evaluated within the value, unless
"with_context" is true.""",
        ),
        "stamping_policy": attr.string(
            doc = """Whether to stamp tagged field values before injection.

If "Allow," stamp tagged field values only when the "--stamp" flag is
active.

If "Force," stamp tagged field values unconditionally, even if the
"--stamp" flag is inactive.

If "Prevent," never stamp tagged field values, even if the "--stamp"
flag is active.""",
            values = [
                "Allow",
                "Force",
                "Prevent",
            ],
            default = "Allow",
        ),
        "with_context": attr.bool(
            doc = """Evaluate "path" elements within a struct of contextual data.
Instead of evaluating these elements in the context of the value being
situated, instead evaluate them within a struct identifying the source
data, file name, record index, and record count.""",
        ),
    })
    return attrs

def add_common_instance_consuming_attrs_to(attrs):
    attrs.update({
        "instance": attr.label(
            doc = """CUE instance to export.

This value must refer either to a target using the cue_instance rule
or another rule that yields a CUEInstanceInfo provider.""",
            providers = [CUEInstanceInfo],
            mandatory = True,
        ),
    })
    return attrs

def call_rule_after(name, rule_fn, prepare_fns = [], **kwargs):
    for f in prepare_fns:
        kwargs = f(
            name = name,
            **kwargs
        )
    rule_fn(
        name = name,
        **kwargs
    )
