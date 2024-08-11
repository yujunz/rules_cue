"cue_export rule forked from https://github.com/seh/rules_cue/blob/main/cue/cue.bzl"

load("//cue/private:factory.bzl", "add_common_instance_consuming_attrs_to", "add_common_output_producing_attrs_to", "call_rule_after", "make_instance_consuming_action")
load("//cue/private:instance.bzl", "prepare_instance_consuming_rule")

def _augment_export_output_args(ctx, args):
    if ctx.attr.escape:
        args.add("--escape")
    args.add("--out", ctx.attr.out)

def _add_common_export_output_attrs_to(attrs):
    attrs = add_common_output_producing_attrs_to(attrs)
    attrs.update({
        "escape": attr.bool(
            doc = "use HTML escaping.",
            default = False,
        ),
        "out": attr.string(
            doc = "output format",
            default = "json",
            values = [
                "cue",
                "json",
                "text",
                "yaml",
            ],
        ),
        "result": attr.output(
            doc = """The built result in the format specified in the "out" attribute.""",
            mandatory = True,
        ),
    })
    return attrs

def _prepare_exported_output_rule(name, **kwargs):
    extension_by_format = {
        "cue": "cue",
        "json": "json",
        "text": "txt",
        "yaml": "yaml",
    }
    output_format = kwargs.get("out", "json")
    result = kwargs.pop("result", name + "." + extension_by_format[output_format])
    return kwargs | {
        "result": result,
    }

def _cue_export_impl(ctx):
    make_instance_consuming_action(
        ctx,
        "export",
        "CUEExport",
        "export evaluates the configuration found in the current directory and prints the emit value to stdout.",
        _augment_export_output_args,
    )

_cue_export = rule(
    implementation = _cue_export_impl,
    attrs = _add_common_export_output_attrs_to(add_common_instance_consuming_attrs_to({})),
    toolchains = ["//cue:toolchain_type"],
)

def cue_export(name, **kwargs):
    call_rule_after(
        name,
        _cue_export,
        [
            prepare_instance_consuming_rule,
            _prepare_exported_output_rule,
        ],
        **kwargs
    )
