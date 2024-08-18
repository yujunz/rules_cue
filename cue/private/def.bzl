"cue_def rule forked from https://github.com/seh/rules_cue/blob/main/cue/cue.bzl"

load("//cue/private:factory.bzl", "add_common_instance_consuming_attrs_to", "add_common_output_producing_attrs_to", "call_rule_after", "make_instance_consuming_action")
load("//cue/private:instance.bzl", "prepare_instance_consuming_rule")

def _prepare_def_output_rule(name, **kwargs):
    result = kwargs.pop("result", name + ".cue")
    return kwargs | {
        "result": result,
    }

def _cue_def_impl(ctx):
    make_instance_consuming_action(
        ctx,
        "def",
        "CUEDef",
        "def prints consolidated configuration as a single file.",
        None,
    )

_cue_def = rule(
    implementation = _cue_def_impl,
    attrs = add_common_output_producing_attrs_to(add_common_instance_consuming_attrs_to({
        "result": attr.output(
            doc = "The built result.",
            mandatory = True,
        ),
    })),
    toolchains = ["//cue:toolchain_type"],
)

def cue_def(name, **kwargs):
    call_rule_after(
        name,
        _cue_def,
        [
            prepare_instance_consuming_rule,
            _prepare_def_output_rule,
        ],
        **kwargs
    )
